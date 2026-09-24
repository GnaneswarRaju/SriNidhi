# ADR-002: PostgreSQL and Supabase

Accepted: PostgreSQL transactions, constraints and RLS enforce correctness; Supabase provides Auth/Storage and managed access. Critical operations are database RPCs; Edge Functions only for server logic not reasonably expressed in SQL. All schema changes are immutable versioned migrations after release. Local SQL tests supplement, never replace, full Supabase CI.
