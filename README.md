# Andy Yu's MacOS Development Kit for UI

An Electron-based macOS interface kit and application shell, using the Portfolio visual language: fixed red/yellow/blue identity, pixel marks, SVG CRT curvature, phosphor texture, tactile controls and coordinated panel motion.

[简体中文](README.zh-CN.md) · [Build and implementation notes](desktop/README.md)

## Run

```sh
cd desktop
npm ci
npm run build
npm run desktop:dev
```

Build an Apple Silicon macOS app with `npm run desktop:build`. The local, unsigned bundle is `desktop/release/mac-arm64/AYM DevKit.app`. Assets and fonts are bundled; the application works offline.

## Interface

- Source-derived 2.5-second welcome construction and queued panel transitions.
- One application window with an embedded settings panel, Escape to close and Command-comma to open.
- Chinese/English with language-only ASCII text transitions and reserved bilingual layout dimensions.
- System/light/dark appearance, defaulting to the system, with animated color changes.
- Classic blue, high contrast and grayscale treatments; configurable motion, interface sound, CRT and softness.
- Preselection and click feedback on enabled interactive controls, page-switch sound, and 56 px scroll detents with ruler and sound.
- Blue `#164BFF` for utilities, yellow `#FFE500` for entertainment and red `#F22A30` for other software. Marks use a 16 × 16 foreground: white on blue/red, black on yellow.

## Tests

```sh
cd desktop
npm test
npx playwright install chromium
npm run dev
# In another terminal, from desktop:
npm run test:browser
```

Tests cover the curve's coordinate inverse, preferences, physical-pointer interactions, audio playback startup, entry/queued navigation, scrolling, language layout stability and appearance changes. Visual and audio behavior still merits testing on target Macs before distribution. The component gallery is a working migration foundation; a separately published web-component package is not yet provided.

## Repository

- `desktop/`: active Electron application, frontend and tests.
- `Sources/`, `Tests/`, `Package.swift`: retained SwiftUI implementation and its SwiftPM tests. Its older native rendering approach is not the active desktop runtime.
- `docs/`: historical SwiftUI documentation and screenshots; these do not represent the current Electron design.

The reference motion, generated background and interface sounds were ported from the author's Portfolio project. No portfolio video/audio catalogue is included. See `desktop/README.md` for source mappings and adaptations.
