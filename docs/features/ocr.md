# OCR document center

One module handles PURCHASE_VENDOR_BILL, CUSTOMER_HANDWRITTEN_SALE, CUSTOMER_PRINTED_SALE and OTHER_DOCUMENT. Provider adapters are replaceable; prefer an on-device/free option where it meets accuracy needs. Paid providers require an explicit cost/alternative/replacement decision. No OCR service or key is introduced in V0.1.

Pipeline: capture/upload → safe image validation/compression → OCR → parse → candidate product matching → field confidence → human review → explicit confirmation → normal posting use case/RPC. OCR can only create a draft. A review screen never writes stock or debt directly.

Vendor fields: supplier, invoice number/date, lines, units, quantity, unit price, tax and totals. Detect duplicate supplier invoice/source hash before posting. Handwritten customer fields additionally include exact observed bill time where legible, customer, representative, paid amount, balance, payment mode and notes. Do not invent missing timestamps or infer paid totals as facts.

Store original private image with content hash, extraction provider/version, raw results behind restricted access, editable normalized fields, confidence and review history. Unknown confidence is unknown, not 100%. Highlight missing/inconsistent fields and require totals/payment reconciliation. Candidate matching uses catalogue search and auditable product aliases. Low-confidence names never silently create products.

Confirmation revalidates every line and server permissions, uses a client transaction UUID and posts atomically. Save reviewed_by/at and attach the original document to the transaction. Handwritten extraction must pass real store bill trials (multiple scripts, poor lighting and ambiguous decimals) before V0.8 acceptance. Tests explicitly prove extraction alone has zero ledger effects.
