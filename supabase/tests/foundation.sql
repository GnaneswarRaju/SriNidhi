-- Run with ON_ERROR_STOP. Uses actual roles/JWT subject/RLS, not owner-only reads.
begin;
insert into auth.users(id) values
 ('10000000-0000-0000-0000-000000000001'),
 ('10000000-0000-0000-0000-000000000002');
insert into public.businesses(id, name) values
 ('20000000-0000-0000-0000-000000000001', 'Test A'),
 ('20000000-0000-0000-0000-000000000002', 'Test B');
insert into public.branches(id, business_id, name, code) values
 ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'A1', 'A1'),
 ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'A2', 'A2'),
 ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000002', 'B1', 'B1');
insert into public.business_memberships(business_id, user_id) values
 ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001'),
 ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002');
insert into public.user_roles(business_id, branch_id, user_id, role) values
 ('20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'CASHIER'),
 ('20000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', 'OWNER');

-- Composite tenant references reject a role referencing another business's branch.
do $$ begin
  begin
    insert into public.user_roles values ('20000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'OWNER', now(), null);
    raise exception 'Cross-tenant reference was accepted';
  exception when foreign_key_violation then null; end;
end $$;

set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000001', true);
do $$ begin
  if (select count(*) from public.businesses) <> 1 then raise exception 'Tenant isolation failed'; end if;
  if (select count(*) from public.branches) <> 1 then raise exception 'Branch isolation failed'; end if;
  if (select count(*) from public.my_branch_memberships()) <> 1 then raise exception 'RPC scope failed'; end if;
  if exists (select 1 from public.audit_logs) then raise exception 'Cashier can read audit'; end if;
  if private.has_branch_role('20000000-0000-0000-0000-000000000001',
    '30000000-0000-0000-0000-000000000001', array['OWNER']::public.app_role[]) then
    raise exception 'Cashier has owner role'; end if;
  begin
    update public.user_roles set role = 'OWNER';
    raise exception 'Role escalation was accepted';
  exception when insufficient_privilege then null; end;
  begin
    insert into public.audit_logs(business_id, action, entity)
    values ('20000000-0000-0000-0000-000000000001', 'FAKE', 'test');
    raise exception 'Client audit write was accepted';
  exception when insufficient_privilege then null; end;
end $$;

select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000002', true);
do $$ begin
  if (select count(*) from public.audit_logs) <> 1 then raise exception 'Owner audit scope failed'; end if;
  if (select branch_name from public.my_branch_memberships()) <> 'B1' then raise exception 'Second user scope failed'; end if;
end $$;

reset role;
update public.business_memberships set active = false
where user_id = '10000000-0000-0000-0000-000000000002';
set local role authenticated;
do $$ begin
  if exists (select 1 from public.my_branch_memberships()) then raise exception 'Revoked member retains access'; end if;
end $$;
reset role;

do $$ begin
  begin
    delete from public.audit_logs;
    raise exception 'Audit deletion allowed';
  exception when sqlstate '55000' then null; end;
  begin
    truncate public.audit_logs;
    raise exception 'Audit truncation allowed';
  exception when sqlstate '55000' then null; end;
end $$;

set local role anon;
do $$ begin
  begin
    perform * from public.businesses;
    raise exception 'Anonymous data access allowed';
  exception when insufficient_privilege then null; end;
  begin
    perform * from public.my_branch_memberships();
    raise exception 'Anonymous RPC allowed';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
rollback;
select 'Foundation RLS, tenant constraints, revocation and immutable audit checks passed' as result;
