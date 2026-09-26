-- INV-001: catalogue only. Product maintenance never posts stock or money.
begin;

create table public.product_units (
  code text primary key,
  name text not null,
  quantity_scale smallint not null check (quantity_scale between 0 and 6)
);
insert into public.product_units(code,name,quantity_scale) values
 ('PCS','Piece',0), ('BOX','Box',0), ('PACK','Pack',0), ('BAG','Bag',0),
 ('SET','Set',0), ('ROLL','Roll',0), ('KG','Kilogram',6), ('G','Gram',6),
 ('M','Metre',6), ('CM','Centimetre',6), ('FT','Foot',6), ('L','Litre',6), ('ML','Millilitre',6);

create table public.product_categories (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  name text not null check (length(btrim(name)) between 1 and 80),
  name_key text generated always as (lower(btrim(name))) stored,
  unique(business_id,id), unique(business_id,name_key)
);
create table public.product_brands (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  name text not null check (length(btrim(name)) between 1 and 80),
  name_key text generated always as (lower(btrim(name))) stored,
  unique(business_id,id), unique(business_id,name_key)
);
create table public.products (
  id uuid primary key,
  business_id uuid not null references public.businesses(id),
  name text not null check (length(btrim(name)) between 1 and 160),
  name_key text generated always as (lower(btrim(name))) stored,
  sku text not null check (sku ~ '^[A-Z0-9][A-Z0-9._/-]{0,47}$'),
  barcode text check (barcode ~ '^[A-Za-z0-9._/-]{1,80}$'),
  category_id uuid,
  brand_id uuid,
  base_unit text not null references public.product_units(code),
  description text not null default '' check (length(description) <= 2000),
  hsn_code text check (hsn_code ~ '^[0-9]{4,8}$'),
  sale_price numeric(14,2) not null check (sale_price >= 0 and sale_price < 1000000000000),
  mrp numeric(14,2) check (mrp >= sale_price and mrp < 1000000000000),
  reorder_quantity numeric(20,6) not null default 0 check (reorder_quantity >= 0 and reorder_quantity < 100000000000000),
  active boolean not null default true,
  version integer not null default 1 check (version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(business_id,id), unique(business_id,sku), unique(business_id,barcode),
  foreign key (business_id,category_id) references public.product_categories(business_id,id),
  foreign key (business_id,brand_id) references public.product_brands(business_id,id)
);
create index products_name_page_idx on public.products(business_id,name_key,id);
create index products_name_prefix_idx on public.products(business_id,name_key text_pattern_ops);
create index products_sku_prefix_idx on public.products(business_id,lower(sku) text_pattern_ops);
create index products_barcode_prefix_idx on public.products(business_id,lower(barcode) text_pattern_ops);
create index products_category_idx on public.products(business_id,category_id);
create index products_brand_idx on public.products(business_id,brand_id);
create index products_unit_idx on public.products(base_unit);

-- Preserve the original create payload even after later edits. Same request ID
-- and payload return the existing product; changed payload never creates again.
create table private.product_create_requests (
  product_id uuid primary key references public.products(id),
  business_id uuid not null,
  actor_id uuid not null references auth.users(id),
  payload jsonb not null,
  created_at timestamptz not null default now(),
  foreign key(business_id,product_id) references public.products(business_id,id)
);
create index product_requests_business_idx on private.product_create_requests(business_id,product_id);
create index product_requests_actor_idx on private.product_create_requests(actor_id);
alter table private.product_create_requests enable row level security;
revoke all on private.product_create_requests from public,anon,authenticated;

create function private.can_read_catalogue(target_business uuid) returns boolean
language sql stable security definer set search_path='' as $$
  select auth.uid() is not null and exists (
    select 1 from public.user_roles r
    where r.business_id=target_business and r.user_id=(select auth.uid())
      and private.has_branch_role(r.business_id,r.branch_id)
  );
$$;
revoke all on function private.can_read_catalogue(uuid) from public,anon,authenticated;
grant execute on function private.can_read_catalogue(uuid) to authenticated;

alter table public.product_units enable row level security;
alter table public.product_categories enable row level security;
alter table public.product_brands enable row level security;
alter table public.products enable row level security;
create policy units_read on public.product_units for select to authenticated using(true);
create policy categories_read on public.product_categories for select to authenticated
 using(private.can_read_catalogue(business_id));
create policy brands_read on public.product_brands for select to authenticated
 using(private.can_read_catalogue(business_id));
create policy products_read on public.products for select to authenticated
 using(private.can_read_catalogue(business_id));
revoke all on public.product_units,public.product_categories,public.product_brands,public.products from public,anon,authenticated;
grant select on public.product_units,public.product_categories,public.product_brands,public.products to authenticated;

create function private.product_json(product public.products) returns jsonb
language sql stable security invoker set search_path='' as $$
 select to_jsonb(product) || jsonb_build_object(
  'sale_price',product.sale_price::text,'mrp',product.mrp::text,
  'reorder_quantity',product.reorder_quantity::text,
  'category',coalesce((select c.name from public.product_categories c where c.id=product.category_id),''),
  'brand',coalesce((select b.name from public.product_brands b where b.id=product.brand_id),'')
 );
$$;
revoke all on function private.product_json(public.products) from public,anon,authenticated;
grant execute on function private.product_json(public.products) to authenticated;

create function public.catalogue_products(p_branch_id uuid,p_query text default '',
 p_show_inactive boolean default false,p_after_name text default null,
 p_after_id uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security invoker set search_path='' as $$
declare target_business uuid; pattern text; result jsonb;
begin
 select business_id into target_business from public.branches where id=p_branch_id;
 if target_business is null or not private.has_branch_role(target_business,p_branch_id) then
  raise exception 'CATALOGUE_FORBIDDEN' using errcode='42501';
 end if;
 if p_query is null or length(p_query)>80 or p_limit is null or p_limit not between 1 and 50
  or (p_after_name is null) <> (p_after_id is null) then
  raise exception 'CATALOGUE_INVALID' using errcode='22023';
 end if;
 pattern:=replace(replace(replace(lower(btrim(p_query)),E'\\',E'\\\\'),'%',E'\\%'),'_',E'\\_') || '%';
 select coalesce(jsonb_agg(rows.item order by rows.name_key,rows.id),'[]'::jsonb) into result
 from (select p.name_key,p.id,private.product_json(p) as item from public.products p
  where p.business_id=target_business and (p.active or coalesce(p_show_inactive,false))
   and (p.name_key like pattern or lower(p.sku) like pattern or lower(p.barcode) like pattern)
   and (p_after_id is null or (p.name_key,p.id)>(p_after_name,p_after_id))
  order by p.name_key,p.id limit p_limit+1) rows;
 return result;
end;
$$;

create function private.save_catalogue_product(p_branch_id uuid,p_product_id uuid,
 p_expected_version integer,p_data jsonb) returns jsonb
language plpgsql security definer set search_path='' as $$
declare
 target_business uuid; old_product public.products; saved public.products;
 category uuid; brand uuid; item_name text; item_sku text; item_barcode text;
 category_name text; brand_name text; unit_code text; item_description text; hsn text;
 price numeric; maximum_price numeric; reorder numeric; enabled boolean;
 request private.product_create_requests; normalized jsonb; scale_limit integer;
begin
 select business_id into target_business from public.branches where id=p_branch_id;
 if auth.uid() is null or target_business is null or not private.has_branch_role(target_business,p_branch_id,
  array['OWNER','ADMIN','MANAGER','STOCK_MANAGER']::public.app_role[]) then
  raise exception 'CATALOGUE_FORBIDDEN' using errcode='42501';
 end if;
 if p_product_id is null or p_data is null or jsonb_typeof(p_data)<>'object'
  or p_expected_version is not null and p_expected_version<1 then
  raise exception 'CATALOGUE_INVALID' using errcode='22023';
 end if;
 if exists(select 1 from jsonb_object_keys(p_data) k where k not in
  ('name','sku','barcode','category','brand','base_unit','description','hsn_code','sale_price','mrp','reorder_quantity','active')) then
  raise exception 'CATALOGUE_INVALID' using errcode='22023';
 end if;
 -- All editable decimals arrive as strings; reject precision loss, exponents,
 -- NaN, Infinity, negatives, arrays and extra keys before typmod can round.
 if exists(select 1 from jsonb_each(p_data) e where e.key<>'active' and jsonb_typeof(e.value) not in ('string','null'))
  or jsonb_typeof(p_data->'active') is distinct from 'boolean' then
  raise exception 'CATALOGUE_INVALID' using errcode='22023';
 end if;
 item_name:=btrim(p_data->>'name'); item_sku:=upper(btrim(p_data->>'sku'));
 item_barcode:=nullif(btrim(p_data->>'barcode'),'');
 category_name:=nullif(btrim(p_data->>'category'),''); brand_name:=nullif(btrim(p_data->>'brand'),'');
 unit_code:=upper(btrim(p_data->>'base_unit')); item_description:=coalesce(btrim(p_data->>'description'),'');
 hsn:=nullif(btrim(p_data->>'hsn_code'),''); enabled:=(p_data->>'active')::boolean;
 if item_name is null or length(item_name) not between 1 and 160
  or item_sku is null or item_sku !~ '^[A-Z0-9][A-Z0-9._/-]{0,47}$'
  or item_barcode is not null and item_barcode !~ '^[A-Za-z0-9._/-]{1,80}$'
  or length(category_name)>80 or length(brand_name)>80 or length(item_description)>2000
  or hsn is not null and hsn !~ '^[0-9]{4,8}$'
  or coalesce(p_data->>'sale_price','') !~ '^[0-9]{1,12}(\.[0-9]{1,2})?$'
  or coalesce(p_data->>'reorder_quantity','') !~ '^[0-9]{1,14}(\.[0-9]{1,6})?$'
  or nullif(p_data->>'mrp','') is not null and (p_data->>'mrp') !~ '^[0-9]{1,12}(\.[0-9]{1,2})?$' then
  raise exception 'CATALOGUE_INVALID' using errcode='22023';
 end if;
 select quantity_scale into scale_limit from public.product_units where code=unit_code;
 if scale_limit is null then raise exception 'CATALOGUE_INVALID' using errcode='22023'; end if;
 price:=(p_data->>'sale_price')::numeric; maximum_price:=nullif(p_data->>'mrp','')::numeric;
 reorder:=(p_data->>'reorder_quantity')::numeric;
 if maximum_price<price or reorder<>trunc(reorder,scale_limit) then
  raise exception 'CATALOGUE_INVALID' using errcode='22023';
 end if;
 normalized:=jsonb_build_object('name',item_name,'sku',item_sku,'barcode',item_barcode,
  'category',lower(category_name),'brand',lower(brand_name),'base_unit',unit_code,
  'description',item_description,'hsn_code',hsn,'sale_price',price,'mrp',maximum_price,
  'reorder_quantity',reorder,'active',enabled);
 -- Serialize a create/retry or competing edits for the same stable UUID.
 perform pg_advisory_xact_lock(hashtextextended(p_product_id::text,0));
 select * into old_product from public.products where id=p_product_id for update;
 if p_expected_version is null then
  if old_product.id is not null then
   select * into request from private.product_create_requests where product_id=p_product_id;
   if request.business_id=target_business and request.actor_id=auth.uid() and request.payload=normalized then
    return private.product_json(old_product);
   end if;
   raise exception 'CATALOGUE_REQUEST_CONFLICT' using errcode='P0001';
  end if;
 else
  if old_product.id is null or old_product.business_id<>target_business then
   raise exception 'CATALOGUE_FORBIDDEN' using errcode='42501';
  end if;
  if old_product.version<>p_expected_version then
   raise exception 'CATALOGUE_EDIT_CONFLICT' using errcode='P0001';
  end if;
  if old_product.base_unit<>unit_code then
   raise exception 'CATALOGUE_UNIT_IMMUTABLE' using errcode='22023';
  end if;
 end if;
 if category_name is not null then
  insert into public.product_categories(business_id,name) values(target_business,category_name)
   on conflict(business_id,name_key) do update set name=public.product_categories.name returning id into category;
 end if;
 if brand_name is not null then
  insert into public.product_brands(business_id,name) values(target_business,brand_name)
   on conflict(business_id,name_key) do update set name=public.product_brands.name returning id into brand;
 end if;
 if p_expected_version is null then
  insert into public.products(id,business_id,name,sku,barcode,category_id,brand_id,base_unit,
   description,hsn_code,sale_price,mrp,reorder_quantity,active)
   values(p_product_id,target_business,item_name,item_sku,item_barcode,category,brand,unit_code,
   item_description,hsn,price,maximum_price,reorder,enabled) returning * into saved;
  insert into private.product_create_requests(product_id,business_id,actor_id,payload)
   values(saved.id,target_business,auth.uid(),normalized);
 else
  update public.products set name=item_name,sku=item_sku,barcode=item_barcode,category_id=category,brand_id=brand,
   description=item_description,hsn_code=hsn,sale_price=price,mrp=maximum_price,reorder_quantity=reorder,
   active=enabled,version=version+1,updated_at=now() where id=p_product_id returning * into saved;
 end if;
 insert into public.audit_logs(business_id,branch_id,actor_id,action,entity,entity_id)
  values(target_business,p_branch_id,auth.uid(),case when p_expected_version is null then 'PRODUCT_CREATE' else 'PRODUCT_UPDATE' end,'products',saved.id);
 return private.product_json(saved);
end;
$$;

create function public.save_catalogue_product(p_branch_id uuid,p_product_id uuid,
 p_expected_version integer,p_data jsonb) returns jsonb
language sql security invoker set search_path='' as $$
 select private.save_catalogue_product(p_branch_id,p_product_id,p_expected_version,p_data);
$$;
revoke all on function private.save_catalogue_product(uuid,uuid,integer,jsonb),
 public.save_catalogue_product(uuid,uuid,integer,jsonb),
 public.catalogue_products(uuid,text,boolean,text,uuid,integer) from public,anon,authenticated;
grant execute on function private.save_catalogue_product(uuid,uuid,integer,jsonb),
 public.save_catalogue_product(uuid,uuid,integer,jsonb),
 public.catalogue_products(uuid,text,boolean,text,uuid,integer) to authenticated;

comment on table public.products is 'Business-wide catalogue. No stock balance. Base unit immutable; deactivate instead of deleting.';
comment on column public.products.reorder_quantity is 'Business default threshold in base units; branch thresholds and low-stock evaluation follow in stock milestone.';
commit;
