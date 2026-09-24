-- Trusted development administration only. Supply auth_user_id, store_name,
-- branch_name and branch_code via psql -v; NEVER embed passwords here.
-- Creates a new store. Do not rerun for an existing store.
begin;
insert into public.businesses(name) values (:'store_name') returning id as business_id \gset
insert into public.branches(business_id, name, code)
values (:'business_id', :'branch_name', :'branch_code') returning id as branch_id \gset
insert into public.business_memberships(business_id, user_id)
values (:'business_id', :'auth_user_id');
insert into public.user_roles(business_id, branch_id, user_id, role)
values (:'business_id', :'branch_id', :'auth_user_id', 'OWNER');
commit;
