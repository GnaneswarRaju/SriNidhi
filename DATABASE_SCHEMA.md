# Database schema

## V0.1 implemented schema

| Table | Key / purpose |
|---|---|
| businesses | UUID, name, currency, timezone, active |
| branches | UUID + business_id, name, code, active; unique business/code |
| profiles | auth.users UUID, display_name |
| business_memberships | business_id/user_id primary key, active |
| user_roles | business_id/branch_id/user_id/role; composite FKs prevent cross-business grants |
| audit_logs | UUID, business/branch, actor, action, entity, correlation, timestamp; immutable |

All exposed tables use RLS. Authenticated clients receive SELECT only. Audit access is restricted to owner/admin/manager in the relevant branch. No anonymous table privileges. A private helper checks current membership and branch activity; its search_path is fixed and execution grants explicit. `my_branch_memberships()` exposes only the caller's active branches/roles. Provisioning requires the SQL administration path and is not embedded in Flutter.

## Planned normalized entities (not migrated yet)

Hosted development migration history: `20260925032304_foundation.sql` and `20260925032910_harden_foundation_access.sql`. The first migration was renamed from `20260924000100` without SQL changes to match the version assigned by its first hosted application; it had not shipped in a release. The hardening migration adds actor/creator/membership foreign-key indexes and revokes client execution of Supabase's pre-existing `rls_auto_enable()` event-trigger function when present.

Catalogue: products, categories, brands, units, unit_conversions, product_aliases, product_prices. Products carry SKU/barcode, category/subcategory, HSN/GST, base/purchase/sale units, exact conversion ratios, fixed prices, reorder values, rack, supplier and active status.

Parties: customers, customer_representatives, suppliers. Sales reference representatives with a composite customer constraint. Credit limits, periods, addresses and GSTIN are protected personal/business data.

Documents: sales/sale_items/sale_payments/sale_returns/sale_return_items; purchases/purchase_items/purchase_payments/purchase_returns/purchase_return_items. UUID identity, business, branch, creator, occurred_at, posted_at, DRAFT/POSTED/VOIDED, source and idempotency key. Invoice numbers are separately assigned and unique per branch/fiscal series.

Inventory: stock_movements, stock_balances, stock_adjustments. Movement quantity `numeric(20,6)` positive with direction ±1, base unit, unit cost, source document/item, reason, actor and UTC timestamp. Composite tenant FKs everywhere. Unique source/item/movement type rejects duplicate posting. Balances can be rebuilt by summing signed movements.

Accounting: accounts, journal_entries, journal_lines, customer_ledger, supplier_ledger, customer_payment_allocations, supplier_payment_allocations, expenses. Money `numeric(20,2)`; rates/conversions use higher fixed precision. Journal debit equals credit enforced at transaction end. Ledger entries reference journals and source documents. Allocation totals cannot exceed payment or invoice outstanding; lock affected rows and recheck within RPC.

OCR: ocr_documents, ocr_extractions, ocr_document_items, ocr_product_matches. Private storage, tenant-scoped paths, extraction version, field confidence, reviewed_by/at, immutable original image hash. No storage bucket is made public.

Operations: alerts, notifications, sync_events, posting_requests (unique business/operation/client UUID, canonical payload hash, durable result).

## Index and lifecycle policy

Every tenant table: business/branch indexes and composite foreign keys. Documents: `(business_id, branch_id, occurred_at desc, id)` for keyset pagination. Product search uses normalized indexed SKU/barcode and bounded text search. Posted/audit/ledger deletion is prohibited; inactive parties remain referentially valid. All migration changes are additive after release; restore/reversal procedures replace silent rewrites.
