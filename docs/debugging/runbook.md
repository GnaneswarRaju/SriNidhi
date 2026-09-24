# Debugging runbook

1. Record application version and build commit from Settings, platform, sanitized module/operation/error code and relevant correlation UUID. Never paste tokens, passwords, invoice payloads or personal data into issues.
2. Authentication: verify public configuration, URL/redirect policy, Auth user status and session expiry. Do not add a service-role key to bypass RLS.
3. Branch access: inspect active business, membership, branch and exact branch roles as an authorized administrator. Test `my_branch_memberships()` as the affected JWT subject. A selected-branch SQLite preference grants no access.
4. Local storage: check browser persistence, WASM/worker HTTP responses and MIME type. Preserve device data before troubleshooting; do not erase an outbox when future versions introduce it.
5. Posting (future): locate client transaction UUID, idempotency record and server result; reconcile document, stock, money, debt, journal and audit entries. Check rollback before attempting repairs. Never manually patch balances.
6. Sync (future): inspect queued state, lease, attempts, last error and payload hash. Retrying must reuse the same immutable key/payload.
7. Reproduce with sanitized fixtures; add a regression test, link introducing commit if known, inspect CI coverage and create a fix PR.

V0.1 logging emits timestamp, severity, fixed module/operation/error code, build version/commit and an optional validated correlation UUID. It intentionally omits arbitrary exception strings and SDK payloads. A remote log collector and operational alerting are not yet installed.
