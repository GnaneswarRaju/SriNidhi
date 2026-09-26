-- V0.1: authorization and tenancy only. No financial posting yet.
begin;

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create type public.app_role as enum (
  'OWNER', 'ADMIN', 'MANAGER', 'CASHIER', 'STOCK_MANAGER', 'ACCOUNTANT'
);

create table public.businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(btrim(name)) between 1 and 160),
  currency text not null default 'INR' check (currency = 'INR'),
  timezone text not null default 'Asia/Kolkata',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.branches (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  name text not null check (length(btrim(name)) between 1 and 160),
  code text not null check (length(btrim(code)) between 1 and 32),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, id),
  unique (business_id, code)
);
create table public.profiles (
  id uuid primary key references auth.users(id),
  display_name text not null default '' check (length(display_name) <= 160),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.business_memberships (
  business_id uuid not null references public.businesses(id),
  user_id uuid not null references auth.users(id),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  primary key (business_id, user_id)
);
create index membership_user_idx on public.business_memberships(user_id, business_id);
create table public.user_roles (
  business_id uuid not null,
  branch_id uuid not null,
  user_id uuid not null,
  role public.app_role not null,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  primary key (business_id, branch_id, user_id, role),
  foreign key (business_id, branch_id) references public.branches(business_id, id),
  foreign key (business_id, user_id) references public.business_memberships(business_id, user_id)
);
create index user_roles_user_idx on public.user_roles(user_id, branch_id);
create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  branch_id uuid,
  actor_id uuid references auth.users(id),
  action text not null check (length(btrim(action)) between 1 and 80),
  entity text not null,
  entity_id uuid,
  correlation_id uuid not null default gen_random_uuid(),
  reason text,
  created_at timestamptz not null default now(),
  foreign key (business_id, branch_id) references public.branches(business_id, id)
);
create index audit_scope_time_idx on public.audit_logs(business_id, branch_id, created_at desc, id);

create function private.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end;
$$;
create trigger businesses_updated before update on public.businesses
for each row execute function private.touch_updated_at();
create trigger branches_updated before update on public.branches
for each row execute function private.touch_updated_at();
create trigger profiles_updated before update on public.profiles
for each row execute function private.touch_updated_at();

create function private.active_member(target_business uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.business_memberships m
    join public.businesses b on b.id = m.business_id
    where m.business_id = target_business and m.user_id = (select auth.uid())
      and m.active and b.active
  );
$$;
create function private.has_branch_role(target_business uuid, target_branch uuid,
  allowed public.app_role[] default enum_range(null::public.app_role)) returns boolean
language sql stable security definer set search_path = '' as $$
  select private.active_member(target_business) and exists (
    select 1 from public.user_roles r
    join public.branches b on b.id = r.branch_id and b.business_id = r.business_id
    where r.business_id = target_business and r.branch_id = target_branch
      and r.user_id = (select auth.uid()) and r.role = any(allowed) and b.active
  );
$$;

alter table public.businesses enable row level security;
alter table public.branches enable row level security;
alter table public.profiles enable row level security;
alter table public.business_memberships enable row level security;
alter table public.user_roles enable row level security;
alter table public.audit_logs enable row level security;

create policy businesses_read on public.businesses for select to authenticated
  using (private.active_member(id));
create policy branches_read on public.branches for select to authenticated
  using (private.has_branch_role(business_id, id));
create policy profiles_self on public.profiles for select to authenticated
  using (id = (select auth.uid()));
create policy memberships_self on public.business_memberships for select to authenticated
  using (user_id = (select auth.uid()) and private.active_member(business_id));
create policy roles_self on public.user_roles for select to authenticated
  using (user_id = (select auth.uid()) and private.has_branch_role(business_id, branch_id));
create policy audit_managers on public.audit_logs for select to authenticated
  using (branch_id is not null and private.has_branch_role(business_id, branch_id,
    array['OWNER', 'ADMIN', 'MANAGER']::public.app_role[]));

create function public.my_branch_memberships()
returns table(business_id uuid, business_name text, branch_id uuid, branch_name text,
  branch_code text, roles public.app_role[])
language sql stable security invoker set search_path = '' as $$
  select b.id, b.name, br.id, br.name, br.code, array_agg(r.role order by r.role)
  from public.businesses b
  join public.branches br on br.business_id = b.id
  join public.user_roles r on r.business_id = b.id and r.branch_id = br.id
  where r.user_id = (select auth.uid())
  group by b.id, b.name, br.id, br.name, br.code
  order by b.name, br.name, br.id;
$$;

create function private.reject_audit_mutation() returns trigger
language plpgsql set search_path = '' as $$
begin raise exception 'AUDIT_IMMUTABLE' using errcode = '55000'; end;
$$;
create trigger audit_immutable before update or delete on public.audit_logs
for each row execute function private.reject_audit_mutation();
create trigger audit_no_truncate before truncate on public.audit_logs
for each statement execute function private.reject_audit_mutation();

create function private.audit_role_change() returns trigger
language plpgsql security definer set search_path = '' as $$
declare record_data record;
begin
  if TG_OP = 'DELETE' then record_data := old; else record_data := new; end if;
  insert into public.audit_logs (business_id, branch_id, actor_id, action, entity, entity_id, reason)
  values (record_data.business_id, record_data.branch_id, auth.uid(), 'ROLE_' || TG_OP,
    'user_roles', record_data.user_id, record_data.role::text);
  return null;
end;
$$;
create trigger role_change_audit after insert or update or delete on public.user_roles
for each row execute function private.audit_role_change();

create function private.audit_membership_change() returns trigger
language plpgsql security definer set search_path = '' as $$
declare record_data record;
begin
  if TG_OP = 'DELETE' then record_data := old; else record_data := new; end if;
  insert into public.audit_logs (business_id, actor_id, action, entity, entity_id, reason)
  values (record_data.business_id, auth.uid(), 'MEMBERSHIP_' || TG_OP,
    'business_memberships', record_data.user_id, 'active=' || record_data.active::text);
  return null;
end;
$$;
create trigger membership_change_audit after insert or update or delete on public.business_memberships
for each row execute function private.audit_membership_change();

revoke all on public.businesses, public.branches, public.profiles,
  public.business_memberships, public.user_roles, public.audit_logs from anon, authenticated;
grant select on public.businesses, public.branches, public.profiles,
  public.business_memberships, public.user_roles, public.audit_logs to authenticated;
revoke all on all functions in schema private from public, anon, authenticated;
grant execute on function private.active_member(uuid),
  private.has_branch_role(uuid, uuid, public.app_role[]) to authenticated;
revoke all on function public.my_branch_memberships() from public, anon;
grant execute on function public.my_branch_memberships() to authenticated;
grant usage on type public.app_role to authenticated;

comment on table public.audit_logs is 'Append-only, payload-free foundation audit. Null branch events are admin-only.';
commit;
