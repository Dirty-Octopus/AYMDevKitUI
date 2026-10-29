# AYM DevKit — Electron

Andy Yu's MacOS Development Kit for UI. The active application is a sandboxed Electron 45 frontend with locally bundled assets and fonts. SwiftUI sources remain in the repository for existing consumers and reference.

## Build and run

```sh
cd desktop
npm ci
npm run build
npm run desktop:dev
npm run desktop:build
```

The Apple Silicon bundle is `release/mac-arm64/AYM DevKit.app`. It is for local testing, without distribution signing or notarization. `npm run dev` starts the optional Vite server on localhost:1420. `AYM_DEV_URL=http://127.0.0.1:1420 npm run desktop:dev` loads that server; ordinary launches load the packaged frontend offline.

## Behavior

- Fixed identity colors: utility blue `#164BFF`, entertainment yellow `#FFE500`, other red `#F22A30`. True 16 × 16 marks are white on blue/red and black on yellow.
- SVG curve and quantized inverse pointer mapping, mapped scrolling, an inset content area, CRT bloom, scanlines and configurable softness.
- Welcome-only ASCII, followed by the source construction timeline and continuous transfer into the actual hero. No completion-triggered text scramble.
- In-app settings with trigger-to-panel motion, keyboard focus containment, Escape and Command-comma. There is no separate settings window or background music option.
- All enabled interactive controls play preselection and click cues; the scanner cue belongs only to page changes. Scroll motion settles to 56 px detents with a ruler and clack sound.
- Chinese and English with an ASCII text transition only on language changes. Both languages are measured using their own locale; controls reserve the larger width and wrapping copy the larger height. Explicit line boxes prevent CJK fallback metrics from changing the layout. Measurements update after font loading, navigation and resizing.
- Persisted system/light/dark appearance, defaulting to system. System changes apply live only in system mode. Colors interpolate over 480 ms and respect reduced motion. Classic blue/high-contrast/grayscale treatments remain independent of light/dark appearance.

## Reference code

The user-authorized reference is the author's `Portfolio4Music_副本` repository:

| Module | Port |
| --- | --- |
| `vendor/portal-assembly.js` | Byte-identical source construction clock and FLIP animation. A pixel-mark adapter implements its logo transfer hooks. |
| `vendor/interface.js` | Source retraction, height interpolation, incoming masks, stagger, queued navigation and reduced-motion settlement, bound to kit pages. |
| `vendor/settings.js` | Original settings choreography, with native titlebar-safe bounds. |
| `vendor/crt.js` | Original displacement image and inverse coordinates; AYM storage key and mapped wheel dispatch added. |
| `vendor/background.js` | Source 140 px grain, dot texture and pointer parallax; light texture added. |
| `vendor/tactile.js` | Source scroll and screen-noise functions, using the main application scroll container. |
| `vendor/text-transition.js` | Original ASCII text transition, invoked only by language changes. |
| `vendor/reference.css`, `replica.css` | Source navigation geometry, scroll ruler and SVG strata styling, adapted to the vertical application sidebar. |

Fonts use the source Barlow Condensed 500/600 and IBM Plex Mono 400 packages. Five interface WAVs are copied from the reference; no portfolio media catalogue is included. Fullscreen terrain/media functionality is outside this component gallery. The abandoned Tauri experiment is ignored locally and is not an Electron dependency.

## Verification

```sh
npm test
npx playwright install chromium
npm run dev
# In a second terminal:
npm run test:browser
```

An existing Chromium can be selected using `PLAYWRIGHT_CHROMIUM_EXECUTABLE=/absolute/path/to/chromium`.

Node tests cover the curve inverse and preference validation. Chromium tests cover real pointer coordinates, text entry, slider dragging, settings, queued transitions, entry without a second scramble, actual audio playback startup, scroll detents, bilingual geometry, appearance persistence and live system changes. Playback startup is verified programmatically; subjective listening and performance on target Macs remain manual release checks.

Electron uses context isolation, no Node integration in the renderer, and a restrictive local content policy. Local interface audio is allowed before the first gesture so hover feedback works immediately. No commit includes generated app bundles or dependency caches.
