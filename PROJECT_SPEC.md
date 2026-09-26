# Project specification

## Product and boundaries

Serve one hardware store initially; retain business and branch identity from the first migration. One Flutter codebase targets Android, iOS and browser. Web is the initial desktop target; mobile signing and app-store release are later gates. Currency initially INR, display timezone Asia/Kolkata, stored timestamps UTC.

## Invariants

1. Stock movements, receivable/payable entries and journals are append-only authoritative histories. Balances are derived projections.
2. Posted documents are immutable. Corrections reference originals through reversals, returns or explicit adjustments.
3. Server posting functions validate membership, role, tenant-consistent references and amounts in one database transaction. Any failure rolls back every effect.
4. Client-generated immutable UUIDs and payload hashes make retries idempotent; a reused ID with a changed payload is a conflict.
5. OCR produces editable drafts only. Human confirmation is required before a posting RPC.
6. RLS protects every exposed business table. UI visibility never substitutes for authorization.
7. Money uses integer minor units or fixed PostgreSQL decimals; quantities and conversions use fixed precision. Never binary floating-point money.
8. No fabricated business metrics, secret keys, tokens, invoice images or personal details in analytics/logs.

## Foundation acceptance

Configured users can sign in/out, restore a session, load authorized branches and roles, select a branch, navigate Overview/Workspace/Settings responsively, and receive actionable loading/error/empty states. Unconfigured installs explain setup. Signed-out users cannot enter protected routes. Branch access is checked by PostgreSQL. Local storage contains only non-sensitive foundation preferences; transactional offline writes start in V0.11.

## V0.2 first slice acceptance

Authorized maintainers can add, edit, deactivate and reactivate business-wide products from the selected branch. Every assigned branch role can search by name/SKU/barcode prefix, page through results and view details. Required name/SKU/base unit/selling price, optional barcode/category/brand/HSN/MRP/description, and a default reorder threshold are validated in the client and server. No stock quantity is implied by the threshold. Duplicate SKU/barcode, stale edits, permission loss and uncertain saves have explicit outcomes. Base units cannot change after creation.

This slice does not complete V0.2: purchase/sale unit conversions, opening stock, stock movements/balances, adjustments and low-stock evaluation remain separate gates. The user approved local design previews on 2026-09-26 because Figma Starter tool quota was exhausted; synchronize the catalogue to Figma when available.

## Module plan

| Version | Modules |
|---|---|
| 0.1 | auth, dashboard shell, settings, core |
| 0.2 | products, categories, brands, units, inventory, stock, alerts |
| 0.3 | customers, representatives, suppliers |
| 0.4 | purchases, supplier payments/returns |
| 0.5 | bill_scanner: vendor invoice extraction/review |
| 0.6 | sales/POS, mixed payments, invoices, returns |
| 0.7 | customer_credit, allocation, due dates, credit controls |
| 0.8 | bill_scanner: handwritten/printed customer bills |
| 0.9 | accounting, expenses, daily closing |
| 0.10 | reports and exports |
| 0.11 | durable offline transaction queue and conflict resolution |
| 0.12 | beta analytics and real-store trials |
| 1.0 | production deployment, backup recovery, signed releases |

The original master brief is preserved in `docs/project/master-development-prompt.md` as the detailed feature checklist. Milestone scope does not weaken its integrity requirements.
