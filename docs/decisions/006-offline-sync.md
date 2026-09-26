# ADR-006: Local persistence now, durable transaction sync later

Accepted: Drift/SQLite from foundation; offline posting/outbox in V0.11 after server invariants exist. Scope user/tenant data, persist queues atomically, deduplicate in the same server transaction, and surface conflicts. A network indicator is not proof of synchronization. See `docs/architecture/offline-sync.md`.
