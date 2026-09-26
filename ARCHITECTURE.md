# Architecture

## Modular monolith, feature-first

`Widget → Riverpod controller → application service → repository → local/remote data source → Drift/Supabase`.

Feature folders contain `domain`, `data`, and `presentation`; add `application` only for a real use case. Core contains configuration, database, logging and errors. Shared UI has no business posting logic. No empty speculative services or microservices.

Authentication is an adapter over Supabase Auth. A Riverpod session stream drives route guards. Branch membership is loaded from a tenant-filtered RPC. A local selected-branch preference is scoped by user and validated against current server memberships; it is never an authorization grant. Sign-out invalidates membership and selection state. Membership/network errors fail closed.

## Data authority

PostgreSQL owns posted business documents and ledger history. Local SQLite owns drafts, preferences and (V0.11) the durable outbox. Cached remote data includes freshness and scope. No direct UI write to ledger, stock balance, journal or payment tables.

Each future posting RPC acquires locks in deterministic product/account order; verifies tenant and branch, document status, quantities, prices and permission; inserts document/items, movements, payments, ledger/journal lines and audit record; and commits atomically. A unique tenant/operation/idempotency key prevents duplicate effects. Reports use indexed projections reconciled to ledgers.

## Access

Business membership and explicit branch roles are separate. A role on branch A grants nothing on branch B. OWNER/ADMIN/MANAGER/CASHIER/STOCK_MANAGER/ACCOUNTANT are database-enforced enums. V0.1 allows only read access via RLS and a membership RPC; provisioning is a trusted administration operation. No public sign-up or client-side role mutation is exposed.

## Catalogue slice

`ProductsScreen / ProductForm → ProductRepository → Supabase RPC` uses Riverpod for loading and session invalidation. Pure domain validation compares decimal strings as BigInt minor units. PostgreSQL remains authoritative. The business-wide catalogue is accessed through an authorized selected branch; maintainers are OWNER/ADMIN/MANAGER/STOCK_MANAGER, while other assigned roles can read. Base units are immutable. Normalized categories/brands are resolved in the same transaction as product and audit writes.

Creates use a stable UUID and a private original-payload record; equal retries return the current product without overwriting later edits. Advisory transaction locks serialize creates; row/version checks reject competing edits. The client retains its request ID and locks the draft after an uncertain network response. Search uses literal case-insensitive prefixes and `(name_key,id)` keyset pages of 30 plus a sentinel. Product data is online-only and not persisted to Drift; offline draft/outbox work remains V0.11. Catalogue changes never post stock or money.

## Shared behavior

Structured exceptions carry stable error codes. Logging accepts an explicit allowlist of context IDs and never serializes SDK error bodies, request payloads or credentials. UI text lives in ARB files; English ships first, Telugu/Hindi translation remains a tracked gate. Responsive breakpoints: compact below 600, medium 600–1023, expanded 1024 and above. Keyboard focus, labels, 48 px controls and text scaling are part of acceptance.

## Plans and decisions

See `docs/decisions/`, `docs/architecture/offline-sync.md`, `docs/features/ocr.md`, `docs/features/ledgers.md`, and `docs/architecture/analytics.md`. Introduce financial and offline posting only with their transaction/security tests.
