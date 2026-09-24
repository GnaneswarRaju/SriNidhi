# Figma design foundation

[Design file](https://www.figma.com/design/cKRnPv2HAhhmYjsZ8iWPoW)

Page: `01 · Foundation`. Sign in: Phone `4:2401`, Tablet `4:2430`, Desktop `4:2458`. Overview: Phone `5:50`, Tablet `5:64`, Desktop `5:80`.

Discovery: repository began empty (no Code Connect files); target page had no screens. Material 3 Design Kit is available. Its Button and Text field component sets were imported and instantiated in sign-in layouts. Roboto follows Flutter Material typography; no paid font dependency. Input labels and errors remain accessible, controls at least 48 px.

Palette: canvas #F7F6FA, ink #282333, primary #6750A4, muted #49454F, white cards. Spacing 8/12/16/24/32/48/56, card radius 16, button radius 12. Breakpoints: <600 bottom navigation; 600–1023 rail; >=1024 expanded sidebar and split sign-in composition. Widths checked: 320/390/834/1440.

Reusable Flutter primitives: Material form fields/buttons/navigation, `InfoCard`, `PageContent`, theme and ARB strings. Figma holds Material library instances; custom store token variables and a full component/variant library are still planned. The overview frames are layout references with sample copy describing where verified branch data belongs; they are not screenshots of live financial data.

Parity notes: Flutter adds password visibility, validation/loading/error states, actual branch cards and storage/offline information. The Figma sign-in button instance currently renders at intrinsic width while Flutter uses a full-width touch target. Track these differences explicitly before the final design review; do not imply pixel parity. Later screen design precedes each major module and its PR links the relevant node plus actual screenshots.

## Inspected implementation previews

Rendered on 2026-09-25 with explicit Roboto and Material icon fonts. Synthetic fixtures are confined to the test harness. Phone 390×844, tablet 834×1112, desktop 1440×900; overview content scrolls below the viewport.

| Size | Sign in | Overview |
|---|---|---|
| Phone | [Preview](screenshots/sign-in-390.png) | [Preview](screenshots/overview-390.png) |
| Tablet | [Preview](screenshots/sign-in-834.png) | [Preview](screenshots/overview-834.png) |
| Desktop | [Preview](screenshots/sign-in-1440.png) | [Preview](screenshots/overview-1440.png) |
