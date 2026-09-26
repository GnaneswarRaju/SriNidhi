# Product catalogue — INV-001

Business-wide product details are accessed through an active branch membership. OWNER, ADMIN, MANAGER and STOCK_MANAGER can maintain products. CASHIER and ACCOUNTANT have read-only access. A branch role in another business gives no access. The server checks current membership/branch state on each request.

## Data and mutation contract

- Name, SKU, base unit, selling price and reorder threshold are required. Barcode, category, brand, HSN, description and MRP are optional. SKU is trimmed/uppercased and unique per business; barcode is case-sensitive and unique per business. Category/brand names reuse trimmed, case-insensitive identities.
- Selling price/MRP accept 12 whole digits and at most 2 fractional digits. Thresholds accept 14 whole digits and at most 6 fractional digits; count units require whole quantities. Values travel as JSON strings and are compared as BigInt/fixed PostgreSQL numeric. Negative, exponent, NaN, overflow and excess precision are rejected rather than rounded. MRP cannot be below selling price.
- Creates require a UUID generated once when the form opens. Same actor/business/UUID/canonical payload is an idempotent retry. The original payload is retained privately even after edits. A retry returns the current row, never the old values. Changed-payload reuse produces an explicit conflict.
- Edits require the version that was loaded. Competing saves serialize and only the first expected-version match succeeds. Stale edits require closing/refreshing. Base unit cannot change, even before any stock exists, to establish a durable quantity interpretation.
- Product, category/brand resolution, original create request and payload-free audit record are one transaction. Validation, duplicate or permission failures roll everything back. No client DELETE or direct table INSERT/UPDATE is granted. Deactivation preserves history and can be reversed.

## Reading and UI

`catalogue_products` returns exact decimal strings with category/brand names. The page limit is 30; one extra sentinel identifies the next page. Ordering and cursor are `(name_key,id)`, supporting equal names without ambiguous pagination. Search matches a literal, case-insensitive name/SKU/barcode prefix; `%`, `_` and backslashes are escaped. Previous pages retain only cursors. Changing search, inactive filter or branch resets pagination. Concurrent renames can move a product between pages; Refresh starts a fresh traversal.

Forms show validation, duplicate, conflict, permission and network outcomes. Network failures retain the request UUID and lock input until retry or close/refresh, avoiding accidental changed-payload retries. Read-only users can inspect full details. Loading failures remove old content and offer retry. Account changes invalidate the catalogue and dismiss the form. No product payload or SDK response is logged.

## Explicit limits

This is online-only maintenance. There is no durable draft/outbox, camera barcode scanning, bulk import, stock balance, purchase/sale conversion, tax calculation, price history, stock cost, sales or accounting posting. Catalogue prices will be copied into immutable document lines by future posting modules. Reorder threshold only stores a default for future alerts. No analytics are enabled.
