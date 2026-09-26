-- Disposable fixtures; every mutation rolls back. Never run on production.
begin;
insert into auth.users(id) values
 ('a1000000-0000-0000-0000-000000000001'),('a1000000-0000-0000-0000-000000000002'),
 ('a1000000-0000-0000-0000-000000000003');
insert into public.businesses(id,name) values
 ('a2000000-0000-0000-0000-000000000001','Catalogue A'),('a2000000-0000-0000-0000-000000000002','Catalogue B');
insert into public.branches(id,business_id,name,code) values
 ('a3000000-0000-0000-0000-000000000001','a2000000-0000-0000-0000-000000000001','A','A'),
 ('a3000000-0000-0000-0000-000000000002','a2000000-0000-0000-0000-000000000002','B','B');
insert into public.business_memberships(business_id,user_id) values
 ('a2000000-0000-0000-0000-000000000001','a1000000-0000-0000-0000-000000000001'),
 ('a2000000-0000-0000-0000-000000000001','a1000000-0000-0000-0000-000000000002'),
 ('a2000000-0000-0000-0000-000000000002','a1000000-0000-0000-0000-000000000003');
insert into public.user_roles(business_id,branch_id,user_id,role) values
 ('a2000000-0000-0000-0000-000000000001','a3000000-0000-0000-0000-000000000001','a1000000-0000-0000-0000-000000000001','OWNER'),
 ('a2000000-0000-0000-0000-000000000001','a3000000-0000-0000-0000-000000000001','a1000000-0000-0000-0000-000000000002','CASHIER'),
 ('a2000000-0000-0000-0000-000000000002','a3000000-0000-0000-0000-000000000002','a1000000-0000-0000-0000-000000000003','OWNER');
set local role authenticated;
select set_config('request.jwt.claim.sub','a1000000-0000-0000-0000-000000000001',true);
do $$
declare d jsonb := '{"name":"Hammer","sku":"hm-001","barcode":"8901234","category":"Tools","brand":"Example","base_unit":"PCS","description":"Fixture only","hsn_code":"8205","sale_price":"120.25","mrp":"150","reorder_quantity":"2","active":true}';
 p jsonb; q jsonb; bad jsonb; rows jsonb; count_before bigint;
begin
 p:=public.save_catalogue_product('a3000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000001',null,d);
 if p->>'sale_price'<>'120.25' or p->>'sku'<>'HM-001' or p->>'version'<>'1' then raise exception 'Exact create failed'; end if;
 q:=public.save_catalogue_product('a3000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000001',null,d);
 if q<>p or (select count(*) from public.products)<>1 then raise exception 'Create retry duplicated'; end if;
 select count(*) into count_before from public.audit_logs where entity='products';
 if count_before<>1 then raise exception 'Retry duplicated audit'; end if;
 begin
  perform public.save_catalogue_product('a3000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000001',null,d||'{"name":"Changed"}');
  raise exception 'Changed request accepted';
 exception when sqlstate 'P0001' then if sqlerrm<>'CATALOGUE_REQUEST_CONFLICT' then raise; end if; end;
 for bad in select value from jsonb_array_elements('[{"sale_price":"1.001"},{"sale_price":"NaN"},{"sale_price":"-1"},{"sale_price":1.25},{"sale_price":"1e3"},{"sale_price":"1000000000000"},{"mrp":"1"},{"reorder_quantity":"1.5"},{"active":null},{"business_id":"foreign"},{"base_unit":"UNKNOWN"}]') loop
  begin
   perform public.save_catalogue_product('a3000000-0000-0000-0000-000000000001',gen_random_uuid(),null,d||bad);
   raise exception 'Invalid data accepted';
  exception when invalid_parameter_value then null; end;
 end loop;
 begin
  perform public.save_catalogue_product('a3000000-0000-0000-0000-000000000001',gen_random_uuid(),null,d||'{"category":"Must rollback"}');
  raise exception 'Duplicate SKU accepted';
 exception when unique_violation then null; end;
 if exists(select 1 from public.product_categories where name='Must rollback') then raise exception 'Partial save survived'; end if;
 perform public.save_catalogue_product('a3000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000002',null,
  d||'{"sku":"HM-002","barcode":"8901235","category":"tools","brand":"example"}');
 if (select count(*) from public.product_categories)<>1 or (select count(*) from public.product_brands)<>1 then raise exception 'Reference normalization failed'; end if;
 rows:=public.catalogue_products('a3000000-0000-0000-0000-000000000001','ham',false,null,null,1);
 if jsonb_array_length(rows)<>2 then raise exception 'Pagination sentinel missing'; end if;
 rows:=public.catalogue_products('a3000000-0000-0000-0000-000000000001','',false,'hammer','a4000000-0000-0000-0000-000000000001',1);
 if jsonb_array_length(rows)<>1 or rows->0->>'sku'<>'HM-002' then raise exception 'Cursor order failed'; end if;
 if jsonb_array_length(public.catalogue_products('a3000000-0000-0000-0000-000000000001','8901234'))<>1 then raise exception 'Barcode search failed'; end if;
 if jsonb_array_length(public.catalogue_products('a3000000-0000-0000-0000-000000000001','%'))<>0 then raise exception 'Search wildcard not escaped'; end if;
 q:=public.save_catalogue_product('a3000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000001',1,d||'{"active":false}');
 if q->>'version'<>'2' or (q->>'active')::boolean then raise exception 'Deactivate failed'; end if;
 if jsonb_array_length(public.catalogue_products('a3000000-0000-0000-0000-000000000001'))<>1 then raise exception 'Inactive filtering failed'; end if;
 if jsonb_array_length(public.catalogue_products('a3000000-0000-0000-0000-000000000001','',true))<>2 then raise exception 'Inactive toggle failed'; end if;
 -- Retrying original create after an edit must not overwrite the current row.
 q:=public.save_catalogue_product('a3000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000001',null,d);
 if q->>'version'<>'2' then raise exception 'Create replay overwrote edit'; end if;
 begin
  perform public.save_catalogue_product('a3000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000001',1,d);
  raise exception 'Stale edit accepted';
 exception when sqlstate 'P0001' then if sqlerrm<>'CATALOGUE_EDIT_CONFLICT' then raise; end if; end;
 begin
  perform public.save_catalogue_product('a3000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000001',2,d||'{"base_unit":"KG"}');
  raise exception 'Base unit changed';
 exception when invalid_parameter_value then null; end;
 begin update public.products set sale_price=0; raise exception 'Direct mutation allowed'; exception when insufficient_privilege then null; end;
 begin delete from public.products; raise exception 'Deletion allowed'; exception when insufficient_privilege then null; end;
end $$;
select set_config('request.jwt.claim.sub','a1000000-0000-0000-0000-000000000002',true);
do $$ begin
 if (select count(*) from public.products)<>2 then raise exception 'Cashier read failed'; end if;
 begin perform public.save_catalogue_product('a3000000-0000-0000-0000-000000000001',gen_random_uuid(),null,'{}'); raise exception 'Cashier write allowed'; exception when insufficient_privilege then null; end;
end $$;
select set_config('request.jwt.claim.sub','a1000000-0000-0000-0000-000000000003',true);
do $$ begin
 if exists(select 1 from public.products) or exists(select 1 from public.product_categories) or exists(select 1 from public.product_brands) then raise exception 'Tenant leak'; end if;
 begin perform public.catalogue_products('a3000000-0000-0000-0000-000000000001'); raise exception 'Foreign branch RPC allowed'; exception when insufficient_privilege then null; end;
end $$;
reset role;
update public.business_memberships set active=false where user_id='a1000000-0000-0000-0000-000000000001';
set local role authenticated;
select set_config('request.jwt.claim.sub','a1000000-0000-0000-0000-000000000001',true);
do $$ begin
 if exists(select 1 from public.products) then raise exception 'Revoked catalogue read'; end if;
 begin perform public.catalogue_products('a3000000-0000-0000-0000-000000000001'); raise exception 'Revoked RPC allowed'; exception when insufficient_privilege then null; end;
end $$;
reset role;
set local role anon;
do $$ begin
 begin perform * from public.products; raise exception 'Anonymous read allowed'; exception when insufficient_privilege then null; end;
 begin perform public.save_catalogue_product(null,null,null,'{}'); raise exception 'Anonymous RPC allowed'; exception when insufficient_privilege then null; end;
end $$;
reset role;
rollback;
select 'Catalogue exact decimals, idempotency, conflicts, filtering, permissions and rollback passed' as result;
