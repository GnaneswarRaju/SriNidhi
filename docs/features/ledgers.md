# Inventory and money contracts

These are design contracts for future milestones, not posting functions available in V0.1.

## Inventory

Authoritative movements: OPENING_STOCK, PURCHASE, SALE, SALE_RETURN, PURCHASE_RETURN, DAMAGE, ADJUSTMENT_IN/OUT and TRANSFER_IN/OUT. Positive exact quantity and separate direction; always base unit. Each references tenant/branch/product/source item, actor, occurred_at, unit cost, reason and immutable ID. No `product.stock = ...` source of truth.

Balance is signed movement sum. A projection can optimize reads, updated in the posting transaction and reconciled regularly. Opening 10 + purchase 5 − sale 3 + return 1 − damage 1 = 12. Unit conversion uses numerator/denominator or fixed exact decimal; reject incompatible dimensions. Transfers post both branches atomically and require both permissions.

## Money and credit

Use exact money; round at explicit document line/tax boundaries with a versioned calculation rule. Confirm tax/invoice policy with the business before financial implementation; the foundation does not claim statutory compliance.

Post sale 10,000; cash 3,000; UPI 4,000; customer receivable 3,000. Customer debt derives from debit/credit ledger entries, not editable customer balance. Customer account payment 12,000 against 30,000 outstanding leaves 18,000; allocations conserve payment value and cannot overpay an invoice. Allow explicit unallocated credit only through a documented account-level entry.

Journals balance debit/credit at transaction end. Cash, UPI, bank, card, receivable, payable, revenue, purchase/inventory, expense and tax accounts have stable identity. Supplier transactions use equivalent controls. Lock invoice/payment rows for concurrent allocation and enforce limits in the server transaction. Roles restrict cost/profit views and manual adjustments.

All posting functions validate permissions and tenant-consistent foreign keys, acquire locks in deterministic order, write every required effect and audit event, then commit. Failure rolls back all effects. Reversal retains original lines and links opposite movements/entries; no silent posted document edits/deletes. Returns cap cumulative returned quantity against original posting. Credit overrides require permission and reason and remain auditable.
