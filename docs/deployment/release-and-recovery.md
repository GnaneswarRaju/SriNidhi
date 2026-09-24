# Release and recovery

## V0.1 release gates

Private GitHub repository and linked foundation issue; feature PR; passing Flutter CI and full Supabase Database CI; tested development sign-in/restoration/revocation; screenshots checked against Figma. No release tag until all pass. No production backend was created in this step.

Set branch protection for `main`: PR required, no force-push/deletion, required Flutter CI/Database CI. Restrict deployment credentials to protected environments. GitHub Actions use read-only repository permissions. Pin action revisions before production release; Flutter is pinned and pubspec.lock committed.

Build web with public configuration and `APP_VERSION`/`GIT_SHA`; host HTTPS with correct WASM type and cache immutable assets by build. Test refresh/deep links, keyboard navigation and session expiry. PWA installation is not an offline transaction guarantee. Android requires a signed release on an SDK-equipped host; iOS requires macOS, entitlements and signing. No native build success is claimed from a Windows web-only validation.

## Backup and restore plan

Before production: define an owner, retention, RPO/RTO and storage budget. Export schema and data using Supabase-supported `db dump`/PostgreSQL backup procedures. Store encrypted backups separately with restricted access; never in Git. Include Auth configuration, migration history, private Storage objects and their linkage hashes. A database dump alone does not back up uploaded bill images.

Restore into an isolated non-production project, apply only missing migrations, reconcile counts and ledger sums, verify RLS and sample documents, then rehearse cutover. Record restore duration and recovery point. Rehearse before V1.0 and periodically afterwards. Do not treat an untested backup as recoverable.

Later data exports: products, parties, representatives, documents/items, payments/allocations, stock, receivables and payables as UTF-8 CSV with schema version, UTC timestamps and exact decimals. Export posted IDs and reversal links; never silently export only cached balances. Spreadsheet cells beginning with formula characters must be neutralized. Document retention/deletion requirements with the store owner before production.

## Rollback

Client: deploy previous reviewed build if schema remains compatible. Database: never delete shipped migration files; prefer a forward corrective migration. Restore a backup only with an explicit recovery plan for transactions since the backup. V0.1 rollback of an unused development database can recreate the local stack; it is not a production procedure.
