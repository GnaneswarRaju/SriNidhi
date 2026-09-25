-- Follow-up after hosted Supabase advisor review. Safe on local stacks that
-- do not include Supabase's optional automatic RLS event trigger.
begin;

do $$
begin
  if to_regprocedure('public.rls_auto_enable()') is not null then
    execute 'revoke all on function public.rls_auto_enable() from public, anon, authenticated';
  end if;
end;
$$;

create index audit_actor_idx on public.audit_logs(actor_id);
create index membership_creator_idx on public.business_memberships(created_by);
create index user_roles_membership_idx on public.user_roles(business_id, user_id);
create index user_roles_creator_idx on public.user_roles(created_by);

commit;
