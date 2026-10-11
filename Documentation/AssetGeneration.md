# Automated Asset & Token Generator

`UniversalDesignSystem` includes a Python 3 CLI tool (`scripts/generate_design_system.py`) that parses JSON design token definitions and Xcode Asset Catalogs to produce strongly typed, namespaced Swift 6 accessors.

---

## Running the Generator

Execute from the package root:

```bash
python3 scripts/generate_design_system.py
```

### CLI Flags

- `--tokens-dir`: Directory containing `colors.json`, `typography.json`, and `spacing.json` (default: `DesignTokens`).
- `--assets-dir`: Path to Xcode Asset Catalog (default: `Sources/UDSResources/Resources.xcassets`).
- `--icons-dir`: Separate custom icon image catalog (default: `Sources/UDSResources/Icons.xcassets`). Imagesets in this catalog are emitted as `UDSImage` accessors.
- `--symbols-file`: JSON map of common semantic icon names to SF Symbol names (default: `Sources/UDSResources/symbols.json`). These are emitted as typed `UDSIconToken` constants such as `.search` and `.checkmark`.
- `--check`: Validate inputs and fail if generated Swift accessors are missing or outdated.
- `--report`: Output detailed report of generated accessors and files.

## Adding Icons

Add common system icon names to `Sources/UDSResources/symbols.json`, mapping a
stable semantic name to an SF Symbol name. For example, `"search":
"magnifyingglass"` generates the typed token `.search`. Use it directly in a button
(`UDSButton(title: "Search", icon: .search) { ... }`) or render it with
`Image.udsIcon(.search)` in SwiftUI. UIKit button initializers accept the same token.

For custom artwork, add a regular Xcode imageset under
`Sources/UDSResources/Icons.xcassets` with its image file and `Contents.json`,
then run `python3 scripts/generate_design_system.py`. The generator adds
SwiftUI and UIKit accessors such as `UDSImage.brandMark` and
`UDSImage.uiKit.brandMark`. Keep these custom images in `Icons.xcassets`; color
tokens remain in the separate `Resources.xcassets` catalog.

---

## File Safety & Idempotency

- **Swift 6 Identifier Normalization**: Converts names (e.g. `elevated-surface` or `3d_view`) into valid Swift camelCase identifiers.
- **Reserved Keyword Safety**: Wraps Swift keywords (e.g. `default`, `public`) in backticks (`` `default` ``).
- **Collision Detection**: Detects post-normalization name collisions and halts with readable error tracebacks.
- **Deterministic Writes**: Only writes to disk if content has changed, preserving modification timestamps.
