# Components

Every public component is listed here. If a screen needs something that is not
here, compose it from these primitives or propose an addition; do not create a
one-off control inside an app.

## Foundations

| Type | Purpose |
| --- | --- |
| `DKBrand` | six-colour app identity, with `aurora`, `ocean`, `graphite` presets |
| `DKTheme` | appearance-aware tokens derived from a brand |
| `DKThemeValue` | environment property wrapper for `DKTheme` |
| `DKColorMath` / `DKContrast` | sRGB mixing, luminance, contrast, readable tints |
| `DKTone` | `accent`, `success`, `warning`, `danger`, `info`, `neutral` |
| `DKTextStyle` / `DKText` | the type scale and a styled text view |
| `DKSpacing`, `DKRadius`, `DKControlSize` | the metric system |
| `DKElevation`, `DKMotion` | shadows and animation vocabulary |

```swift
@DKThemeValue private var theme

Text("Hello")
    .foregroundStyle(theme.textPrimary)
    .background(theme.surface)
```

`DKText`:

```swift
DKText("welcome.title", style: .titleXL)       // localised library key
DKText(verbatim: "v1.0.0", style: .mono, color: .tertiary)
```

## Surfaces

### `DKCard`

```swift
DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
    VStack(alignment: .leading, spacing: 12) { … }
}
```

One logical group, one outline, one shadow. Do not nest cards.

### `DKInset`

Recessed block for rows, previews and sidebars. No shadow.

### `DKHairline`, `DKASCIIRule`

`DKHairline` is a 1px separator. `DKASCIIRule` prints a dashed monospaced line;
use it in the welcome panel and other ambient contexts, not between dense rows.

### `DKAppBackground`

The brand-tinted canvas plus the ASCII field. `fieldIntensity` scales the glyph
opacity (`1.0` default, `0.42` in settings).

### `DKASCIIField`

The animated dense code field on its own. Use only as a background layer; it is
non-interactive and hidden from accessibility. Characters re-roll on a staggered
clock. Pointer movement writes a size-decaying wake through the shared
`DKAmbient`; clicks add expanding rings with their own alphabet. Neither
interaction blocks hit testing.

### `DKOrb`, `DKMarkView`

`DKOrb` is a decorative layered ring for heroes and empty states.
`DKMarkView` renders a `DKMark` (automatic app icon, symbol, monogram, image or
asset) at a consistent radius and gradient.

## Controls

### `DKButton`

```swift
DKButton("Save", systemImage: "checkmark", variant: .primary) { save() }
DKButton("Cancel", variant: .ghost) { cancel() }
DKButton("Delete", systemImage: "trash", variant: .destructive) { delete() }
DKButton("Details", variant: .link, size: .small) { showDetails() }
```

Variants: `primary`, `secondary`, `tonal`, `ghost`, `destructive`, `link`.
Sizes: `small`, `regular`, `large`. `fullWidth` and `isLoading` are supported.

### `DKIconButton`

Circular icon action with tooltip and accessibility label.

```swift
DKIconButton(systemImage: "gearshape", help: "Settings") { openSettings() }
```

### `DKChoiceCard`

Large selection card for language, appearance and window size. Leading artwork
can be a badge, an SF Symbol, a `DKWindowPreview` or a `DKMark`.

```swift
DKChoiceCard(
    title: "English",
    subtitle: "Continue in English",
    leading: .badge("EN"),
    selected: settings.language == .english
) {
    settings.language = .english
}
```

### `DKSegmentedControl`

```swift
DKSegmentedControl(
    selection: $mode,
    items: [
        DKSegmentedItem(value: "grid", title: "Grid", symbol: "square.grid.2x2"),
        DKSegmentedItem(value: "list", title: "List", symbol: "list.bullet")
    ]
)
```

Matched-geometry pill; use for view modes, not for rich options.

### `DKMenuPicker`

Native menu, styled as a settings row. Use when options only need a label or
when there are more than four.

### `DKTextField`, `DKSearchField`

Labels above, help/error below; clear button while focused; secure entry.

```swift
DKTextField(
    label: "API key",
    placeholder: "sk-…",
    text: $apiKey,
    systemImage: "key",
    isSecure: true,
    help: "Stored in the keychain."
)
```

### `DKToggleRow`

Whole-row boolean control with a custom switch and a tinted icon orb. Use for
settings, not for destructive confirmations.

## Feedback

| Component | Use |
| --- | --- |
| `DKBadge` | compact status; tinted, solid or outline |
| `DKNotice` | inline message with one optional action |
| `DKProgressBar` | determinate linear progress |
| `DKProgressRing` | determinate circular progress with a percentage |
| `DKEmptyState` | empty list explanation + one next action |
| `DKSpinner` | small spinner with a label |
| `DKStatusDot` | static status dot |
| `DKLiveDot` | pulsing live dot; stops under Reduce Motion |

```swift
DKNotice(
    "The archive is ready to install.",
    title: "Build complete",
    tone: .success,
    actionTitle: "Reveal"
) { reveal() }
```

## Data

- `DKInfoRow` — label/value row with selectable text and an optional copy button.
- `DKStatTile` — label, value, detail, icon, tone and optional delta.
- `DKAvatar` — monogram circle.

## Navigation

### `DKSidebar`

Generic over its selection ID:

```swift
DKSidebar(
    title: "Gallery",
    selection: $screen,
    items: DemoScreen.allCases.map {
        DKSidebarItem(id: $0, title: $0.title, systemImage: $0.symbol)
    }
)
```

34pt rows, 12pt radius, matched-geometry selection pill.

### `DKTopBar`, `DKAppShell`

`DKTopBar` reserves a compact leading inset, renders the mark, name and tagline,
and hosts trailing actions. Its empty background is a `DKDragArea`.

```swift
DKAppShell(
    info: info,
    showsTopBar: true,
    leadingInset: DKLayout.topBarLeadingInset,
    topBarStyle: .material
) {
    content
}
```

`DKAppShell` draws the background only when `drawsBackground: true`; `DKAppRoot`
already draws it.

## Files

### `DKDropZone`

Dashed target, drag highlight, multi-select and a browse fallback.

```swift
DKDropZone(
    title: "Drop a build here",
    subtitle: "ZIP, DMG or APP",
    allowsMultiple: true,
    allowedContentTypes: [.zip, .diskImage, .application]
) { urls in
    enqueue(urls)
}
```

The callback runs on the main queue after all providers finish loading. The
drop zone never executes files; it only returns URLs.

## Panels and framework

| Type | Purpose |
| --- | --- |
| `DKWelcomePanel` | first-run gate |
| `DKSettingsPanel` | standard Settings scene |
| `DKWelcomeConfiguration` | copy/step overrides |
| `DKSettingsSection` | host section appended to Settings |
| `DKAppRoot` | background, welcome gate, brand, locale, appearance, ripples, window |
| `DKAppSettings` | persisted language, appearance, preset, welcome version |
| `DKAppInfo` | app name, version, bundle id, links, mark |
| `DKAppCommands` | Settings / View / About menu items |
| `DKWindowManager` | chrome and in-place preset resizing |
| `DKAppearanceTransition` | crossfade for light/dark changes |
| `DKAmbient` | shared ripple state |
| `DKNoise` | deterministic Perlin noise used by the field |

## Rules

1. Compose, do not fork. If a screen needs a new look, add a variant to the
   existing component.
2. Use `DKSpacing`, `DKRadius`, `DKControlSize` and `DKTextStyle`; no magic
   numbers in app views.
3. Colours come from `DKTheme`; fills use `fill(for:)` / gradients, text uses
   `color(for:)`.
4. One primary action per surface.
5. Every new component needs a light/dark preview and a contrast check.
