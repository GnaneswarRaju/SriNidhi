# Offline and sync architecture

V0.1 includes Drift for user-scoped preferences and verifies persistence. It does not accept offline sales. V0.11 adds transactional offline writes after server posting contracts are tested.

## Durable outbox

Draft creation and queue insertion share one SQLite transaction. Queue record: immutable client UUID, business, branch, actor, operation/schema version, canonical payload/hash, created_at, attempt_count, next_attempt_at, lease expiry and state. States: PENDING, IN_FLIGHT, SYNCED, FAILED, CONFLICT. Recover expired leases after restart; never discard pending work on sign-out.

Server unique key `(business_id, operation, client_transaction_id)` plus payload hash: same key/hash returns original durable result; changed hash yields a visible conflict. Request deduplication and all stock/payment/debt/journal effects are inside the same PostgreSQL transaction. A client timeout after server commit is safe to retry.

Use bounded exponential backoff with jitter for transient failures; authentication/permission/validation/conflict failures require attention. Reauthenticate as the original actor and verify current branch membership. The client never turns a failed authorization into an anonymous upload. Multiple devices cannot guarantee offline stock availability; mark stock provisional and require a configured resolution on server rejection. Never silently rewrite posted totals or debt to resolve a conflict.

UI shows pending/failed counts and per-document state; it does not claim synced from network connectivity alone. Test disconnect before/after commit, restart, concurrent retry, duplicate responses, membership revocation, multi-tab behavior, storage eviction and schema migration with a populated queue.
