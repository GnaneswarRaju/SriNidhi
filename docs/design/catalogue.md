# Catalogue local design and Figma follow-up

On 2026-09-26 the Figma Starter tool quota rejected the attempt to create the catalogue page before execution. No catalogue nodes were created. The user explicitly answered **“Use local previews; sync Figma later”** to the design dependency question.

The [HTML preview](catalogue-preview.html) establishes list, search/inactive filter, empty state, pagination and product form layouts using the foundation purple/neutral palette and Material controls. It contains labeled synthetic examples. Actual Flutter renders in `screenshots/catalogue-*.png` and `screenshots/product-form-*.png` use test-only product/branch fixtures; these are never loaded by the production entry point.

Flutter reuses the existing responsive rail/bottom navigation and page cards. Forms use two columns when space/text size allows, one column on phones and enlarged text, scroll within a bounded dialog, keep labels/errors visible, and provide touch-sized actions. Exact pricing, role permissions and base-unit immutability are represented in the actual application, including error states beyond the static preview.

Pending Figma sync: create `02 · Catalogue`, add phone/tablet/desktop list and form frames, reuse foundation/library controls, add empty/loading/error/read-only/conflict/inactive states, and link this implementation. Existing [foundation file](https://www.figma.com/design/cKRnPv2HAhhmYjsZ8iWPoW) remains unchanged by this slice. This documented exception does not authorize bypassing future design gates for unrelated modules.

Tracked as [DESIGN-002 / issue #5](https://github.com/GnaneswarRaju/SriNidhi/issues/5).
