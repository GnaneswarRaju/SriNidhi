# ADR-004: Modular monolith

Accepted: feature-first UI/controller/domain/repository/data boundaries, one deployable client and one database. Avoid speculative abstractions and microservices. A feature folder is created only when implemented. All direct Supabase SDK usage belongs in bootstrap/providers or data adapters.
