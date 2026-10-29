<h1 align="center">
  <img src="./docs/icon.png" alt="AYMDevKitUI" width="120" />
  <br>
  AYMDevKitUI
</h1>

<h3 align="center">Andy Yu's macOS Development Kit for UI</h3>

<p align="center">
  <a href="./README.md">English</a> ·
  <a href="./README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <img alt="macOS 14+" src="https://img.shields.io/badge/macOS-14%2B-000000?style=flat-square">
  <img alt="Swift 5.9+" src="https://img.shields.io/badge/Swift-5.9%2B-F05138?style=flat-square">
  <img alt="SwiftPM" src="https://img.shields.io/badge/SwiftPM-compatible-4B8BBE?style=flat-square">
  <img alt="MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square">
</p>

AYMDevKitUI — **AYMDKUI** for short — is a SwiftUI design system and app-framework kit for native macOS apps. It packages a brand-derived visual language, the two panels every app needs, and the interaction rules that keep them consistent, behind a small API.

Apps built with it share one colour language, one type scale, one motion vocabulary, one ASCII ambient background, one welcome flow and one settings panel. Only the identity changes.

## Preview

| Light | Dark |
| --- | --- |
| ![Light preview](./docs/preview-light.jpg) | ![Dark preview](./docs/preview-dark.jpg) |

## Window chrome

The native traffic lights float directly over the app canvas. There is no title, no opaque titlebar strip and no system-grey band: the brand gradient and the ASCII field continue to the top edge, and the whole window — chrome included — fades during a light/dark switch.

| Light | Dark |
| --- | --- |
| ![Window chrome, light](./docs/chrome-light.jpg) | ![Window chrome, dark](./docs/chrome-dark.jpg) |

## What stays identical

- **One colour language.** `DKBrand` is six colours. `DKTheme` derives every surface, outline, readable tint and gradient from them for both appearances.
- **System appearance by default.** Light, dark and system follow the OS until the user chooses otherwise; the choice is persisted.
- **One motion vocabulary.** Quick feedback, standard layout springs, emphasized state changes, and a library-owned crossfade for appearance changes in both directions — content and titlebar fade together.
- **One interaction hierarchy.** Ambient background → surface → control → feedback → panel. Hover, press, selection and disabled states are shared.
- **Two framing panels.** The welcome panel gathers language, appearance and window size in a fixed order. The settings panel mirrors the same choices and appends host-specific sections.
- **ASCII ambience.** Every background is a dense, live code field driven by nested sine waves, Perlin noise, click rings and a pointer wake.
- **Seamless window chrome.** Native traffic lights float directly over the app canvas: full-size content, transparent titlebar, hidden title. There is no grey system strip and no title text. Presets resize in place around the current top-left corner and never re-centre or jump to a stale position.

## Welcome

The first-run panel is a gate, not a tour: one card, three steps, one primary action. The order is always **language → appearance → window size**.

| English | 简体中文 |
| --- | --- |
| ![Welcome, English](./docs/welcome-light.jpg) | ![Welcome, 简体中文](./docs/welcome-zh.jpg) |

The same panel in dark appearance:

![Welcome, dark](./docs/welcome-dark.jpg)

Every string has an English and Simplified Chinese translation. Host apps can override the eyebrow, title, subtitle, highlights, footnote and primary action without replacing the panel.

## Settings

Settings uses the same `[01] … [03]` section rhythm, the same option cards and the same labels as the welcome panel. Host apps append `DKSettingsSection` groups; they do not reorder the core.

<p align="center">
  <img src="./docs/settings-light.jpg" alt="Settings panel" width="420" />
</p>

- `[01] Language` — English / 简体中文.
- `[02] Appearance` — system / light / dark, with a library-provided crossfade.
- `[03] Window size` — compact 1040 × 720, standard 1180 × 820, large 1380 × 920.
- `[04] About` — version, build, bundle id, licence, links, and “show the welcome panel again”.

`⌘,` opens the standard Settings scene. `DKSettingsPanel` is designed for a 640 × 680 window and scrolls when hosts add sections.

## Components

![Components](./docs/components-light.jpg)

![Foundations](./docs/foundations-light.jpg)

The full catalogue is in [`docs/components.md`](./docs/components.md). At a glance:

| Layer | Types |
| --- | --- |
| Foundation | `DKBrand`, `DKTheme`, `DKColor`, `DKTone`, `DKText`, `DKTextStyle`, `DKSpacing`, `DKRadius`, `DKControlSize`, `DKMotion` |
| Surfaces | `DKCard`, `DKInset`, `DKHairline`, `DKASCIIRule`, `DKAppBackground`, `DKASCIIField`, `DKOrb` |
| Controls | `DKButton`, `DKIconButton`, `DKChoiceCard`, `DKSegmentedControl`, `DKMenuPicker`, `DKTextField`, `DKSearchField`, `DKToggleRow` |
| Feedback | `DKBadge`, `DKNotice`, `DKProgressBar`, `DKProgressRing`, `DKEmptyState`, `DKSpinner`, `DKStatusDot`, `DKLiveDot` |
| Data | `DKInfoRow`, `DKStatTile`, `DKAvatar` |
| Navigation | `DKSidebar`, `DKTopBar`, `DKAppShell`, `DKDragArea` |
| Files | `DKDropZone` |
| Panels | `DKWelcomePanel`, `DKSettingsPanel` |
| Framework | `DKAppRoot`, `DKAppSettings`, `DKAppInfo`, `DKAppCommands`, `DKWindowManager`, `DKAppearanceTransition`, `DKAmbient` |

## ASCII ambience

`DKAppBackground` renders a monospaced glyph field instead of a flat gradient or dot grid:

- A 10 × 10pt grid of monospaced code glyphs (8.5pt). The baseline is drawn one text row per scanline, which keeps the field dense without thousands of text layouts.
- **The characters themselves move.** Every cell re-rolls its glyph on a staggered 1.35s clock; the ambient field is never static. Baseline colour stays in the primary brand hue.
- The water surface is two crossing travelling sine waves; depth comes from three octaves of deterministic 2D Perlin noise (`DKNoise`). Crests brighten without changing hue.
- **Hover is a wake in the field, not a separate overlay.** Pointer points are rasterised into the same grid; neighbouring cells switch to the trail alphabet and the accent hue, and the wake scales from 8.5pt at its tail to 13.5pt near the pointer — a size decay, not a flat line.
- **Click is a different interaction.** A tap (`.dkAmbientRipples()`, applied by `DKAppRoot`) creates an expanding ring that uses its own ripple alphabet and accent hue for 2.4s.
- The field runs at 6 fps while idle and 12 fps while moving or rippling, uses `Canvas`, and pauses when the window is inactive or Reduce Motion is on. `DKAppRoot(backgroundFieldIntensity:)` can lower or disable it.

## Requirements

- macOS 14 or later.
- Swift 5.9 or later.
- Xcode 15 or later (SwiftUI macros require the full Xcode toolchain; Command Line Tools alone is not enough).

## Installation

Add the package to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Dirty-Octopus/AYMDevKitUI.git", from: "1.0.0")
]
```

Until the first tagged release, use `branch: "main"`.

Then add one of the two products to your target:

```swift
.product(name: "AYMDevKitUI", package: "AYMDevKitUI")
// or the short alias:
.product(name: "AYMDKUI", package: "AYMDevKitUI")
```

```swift
import AYMDevKitUI
// or: import AYMDKUI
```

Both products expose the same public surface; `AYMDKUI` simply re-exports the canonical module.

## Quick start

```swift
import SwiftUI
import AYMDevKitUI

@main
struct MyApp: App {
    private let info = DKAppInfo(
        name: "MyApp",
        tagline: "A small native tool",
        version: "1.0.0",
        bundleIdentifier: "app.myapp",
        mark: .monogram("MA")
    )

    @StateObject private var settings = DKAppSettings(welcomeVersion: "1")

    var body: some Scene {
        WindowGroup {
            DKAppRoot(info: info, brand: .aurora, settings: settings) {
                DKAppShell(info: info) {
                    ContentView()
                }
            }
        }
        .commands {
            DKAppCommands(settings: settings, info: info)
        }

        Settings {
            DKSettingsPanel(info: info, settings: settings)
        }
    }
}
```

`DKAppRoot` installs the background, the welcome gate, the brand and locale environment, the appearance preference, the ambient ripple feed and window attachment. `DKAppShell` adds the top bar and drag region.

### Use a different identity

```swift
DKBrand.ocean      // cool blue / teal
DKBrand.graphite   // quiet, near-monochrome
```

Pass the brand to `DKAppRoot` and to `DKSettingsPanel` (it is a separate scene). Every surface, outline, tint and gradient is then derived from that brand.

## Design and interaction contracts

- [`docs/design-language.md`](./docs/design-language.md) — colour derivation, type scale, spacing, surfaces, ASCII field and motion.
- [`docs/interaction-spec.md`](./docs/interaction-spec.md) — hierarchy, hover/press/selection, window resizing and dragging, appearance transition, accessibility.
- [`docs/panels.md`](./docs/panels.md) — welcome and settings anatomy, configuration, localisation and versioning.
- [`docs/components.md`](./docs/components.md) — component catalogue and usage rules.

## Localisation

The package ships `en.lproj` and `zh-Hans.lproj`. Add a case to `DKLanguage`, a `.lproj` folder with the same keys, and the welcome and settings panels pick it up automatically.

```swift
public enum DKLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    // add Japanese = "ja" and a ja.lproj folder
}
```

`DKL10n.t(_:)` resolves for AppKit contexts (window titles, menu copy); `DKL10n.text(_:)` resolves through SwiftUI's environment locale.

## Development

```bash
# Build the library, alias and demo
swift build

# Run the unit tests
swift test

# Open the component gallery
swift run AYMDevKitUIDemo

# Regenerate the README snapshots
swift run AYMDevKitUIDemo --snapshot docs
```

If `swift` resolves to Command Line Tools, point it at Xcode:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```

`--snapshot` renders welcome, settings, gallery and foundation images offscreen with `ImageRenderer`. The panels are rendered without their scroll views so the complete content is captured; the app itself scrolls normally.

## Repository layout

```
Sources/
  AYMDevKitUI/
    Core/        brand, theme, colour, type, metrics, settings, window, appearance
    Components/  surfaces, controls, feedback, data, navigation, ASCII field, drop zone
    Panels/      unified welcome and settings panels
    Shell/       app root, shell, top bar, commands, window accessor
    Resources/   en + zh-Hans copy
  AYMDKUI/       short alias that re-exports the canonical module
  AYMDevKitUIDemo/
Tests/
  AYMDevKitUITests/
docs/
```

## Contributing

Issues and pull requests are welcome. Please keep the framework contracts in mind:

- New colours must come from `DKBrand` / `DKTheme`; do not introduce ad-hoc hex values in components.
- New controls must use `DKControlSize`, `DKRadius`, `DKMotion` and the shared text styles.
- New panels must keep the `language → appearance → window` order.
- New copy needs both `en` and `zh-Hans` entries.

## Acknowledgement

- [Seal](https://github.com/Dirty-Octopus/seal) — the original macOS app whose visual language and welcome/settings flow were extracted.
- [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) — README layout inspiration.
- SwiftUI and AppKit.
- Material 3 Expressive for some of the surface and motion ideas that Seal already carried.

AYMDevKitUI is not affiliated with Apple.

## License

MIT. See [LICENSE](./LICENSE).
