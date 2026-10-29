# Interaction specification

The interaction layer is shared so a user can move between any two DevKit apps
without relearning how a card, a toggle or a window behaves.

## 1. The hierarchy

| Level | What lives here | Owns |
| --- | --- | --- |
| 0 — Ambient | `DKAppBackground`, `DKASCIIField`, `DKAmbient` | water-ripple motion, click ripples |
| 1 — Surface | `DKAppShell`, `DKCard`, `DKInset`, `DKSidebar` | window layout, depth, selection containers |
| 2 — Control | `DKButton`, `DKIconButton`, `DKChoiceCard`, `DKSegmentedControl`, `DKTextField`, `DKToggleRow`, `DKMenuPicker` | hover, press, focus, selection |
| 3 — Feedback | `DKBadge`, `DKNotice`, `DKProgressBar`, `DKProgressRing`, `DKEmptyState` | state communication |
| 4 — Panel | `DKWelcomePanel`, `DKSettingsPanel` | one-time setup and persistent preferences |

Rules:

- A higher level never invents its own control. Panels are assembled from level
  2 and 3 primitives.
- One level-2 control owns one interaction. A button does not also act as a
  drag handle; a choice card does not open a menu.
- Feedback is inline whenever possible. A blocking alert is a last resort and is
  not part of the library.

## 2. State model

| State | Visual rule |
| --- | --- |
| Rest | `surface` / `surfaceLow`, 1pt `outline` |
| Hover | scale ≤ 1.012, border brightens, background steps up one surface |
| Pressed | scale 0.975, shadow shrinks, background may deepen |
| Focused | 1.5pt `primary` border, accent icon |
| Selected | `primaryContainer`, 1.5–1.6pt accent border, filled check |
| Disabled | 0.45 opacity, no hover/press response |

No control may have a hover state that changes its layout size (no width jumps).
Hover is feedback, not information: the same control must be usable without a
pointer.

## 3. Controls

### Buttons

- `primary` — exactly one per surface. The welcome panel's “Get started”, a
  form's submit action.
- `secondary` — neutral actions that should not compete.
- `tonal` — contextual actions that belong to the accent.
- `ghost` — tertiary actions; often paired with a primary on the opposite side.
- `destructive` — deletion. Never the default action of a confirmation.
- `link` — inline actions inside notices and prose.

All roles use the same size scale, pill shape, press scale and disabled opacity.
Icon-only buttons add `.help` and an accessibility label.

### Selection

- **Choice cards** (`DKChoiceCard`) — language, appearance, window size. Used
  when each option needs a title, a subtitle and artwork. The whole card is the
  target; the check is an indicator, not a separate control.
- **Segmented control** (`DKSegmentedControl`) — view modes and compact filters.
  Selection moves with a matched-geometry pill.
- **Menu picker** (`DKMenuPicker`) — more than four options, or options that only
  need a label. Native keyboard navigation.

Never mix selection patterns in one group. A list of radio cards does not get a
segmented control above it.

### Inputs

- Labels sit above the field, help text below it; errors replace help.
- The clear button only appears while focused and non-empty.
- Secure fields use the same geometry as plain fields.
- `DKToggleRow` makes the entire row clickable. The switch is never the only
  target.

### Feedback

- `DKNotice` is inline and non-blocking, with exactly one optional action.
- Progress is determinate whenever possible (`DKProgressBar` /
  `DKProgressRing`).
- `DKEmptyState` explains what will appear and offers one next action.

## 4. The panel flow

The welcome panel is a gate:

1. The app launches and shows the panel when `hasCompletedWelcome == false`.
2. The user chooses language, appearance and window size. Choices apply
   immediately and persist.
3. “Get started” marks the current `welcomeVersion` complete and cross-fades to
   the app content.
4. Bumping `welcomeVersion` shows the panel again after a redesign.

The settings panel mirrors the same choices:

- `[01] Language`
- `[02] Appearance`
- `[03] Window size`
- host sections (`DKSettingsSection`) appended after the core
- `[04+] About`

There is no Apply button. Every change applies immediately. The panel never
reorders its core sections; hosts append.

## 5. Window behaviour

### Chrome

`DKWindowManager.attach(_:)` applies the shared chrome:

- Seamless native titlebar: `.fullSizeContentView`, transparent titlebar,
  hidden title, no separator.
- Traffic lights float directly over the app canvas; the ASCII field and brand
  gradient continue to the top edge. There is no grey system strip.
- Auxiliary windows (Settings, sheets) receive the same treatment through
  `DKWindowManager.styleAuxiliary(_:)`.
- Minimum content size 1040 × 680.
- `DKDragArea` behind the top bar makes the empty top-bar area drag the window.

### Presets resize in place

`DKWindowManager.apply(_:animated:)` preserves the window's current top-left
corner:

1. Compute the frame size for the preset content size.
2. Keep the current `frame.origin.x` and set
   `origin.y = oldFrame.maxY - newFrame.height`.
3. Clamp the result to the visible screen.
4. Animate with `setFrame` over 0.26s, or apply instantly under Reduce Motion.

It never calls `center()` after launch, and it never snaps the window back to a
stale origin. A user can also resize freely from any edge; the preset is only
re-applied when the user explicitly chooses a preset.

### Appearance crossfade

`NSApp.appearance` changes instantly, so `DKAppearanceTransition` provides the
transition:

1. Snapshot every visible window's content view.
2. Lay each snapshot over the new content in a click-through overlay.
3. Apply the appearance.
4. After one run-loop turn, fade the overlays out over 0.34s.

The old frame covers the new layout while it settles, so the user never sees a
half-rendered colour scheme. The snapshot is taken from the theme frame, so the
titlebar and traffic lights fade with the content in both directions — light →
dark and dark → light use the same path. `DKAppSettings.appearance` calls this
automatically for every change; launch uses the instant path. Reduce Motion
switches instantly.

## 6. Ambient ripples

- `DKAppRoot` applies `.dkAmbientRipples()` to the full window.
- A tap creates a normalised ripple in `DKAmbient`; the coordinates are relative
  to the window, so a ripple created in the Settings window also appears in the
  main window's field.
- At most 8 ripples are retained; each lasts 2.4s.
- The field draws an expanding ring at `radius = age × 0.42`, with a narrow band
  and an exponential fade, using the ripple alphabet and the accent hue.
- Pointer movement creates trail points (throttled to 25ms / 2.5pt). Each point
  becomes a local wake in the same cell grid, so nearby code glyphs switch to the
  trail alphabet and the accent hue instead of a second trail being drawn on
  top. Each trail point’s influence radius decays with age (2.8 cells near the
  pointer to 0.8 cells at the tail) while the glyph size stays constant, so the
  trail’s footprint shrinks over 0.9s.
- Ripples and trail points do not block clicks, change layout or affect
  accessibility.

Because the gesture is `simultaneous`, buttons, cards and text selection keep
working while the ambient layer receives the same tap.

## 7. Keyboard and menus

- `⌘,` — opens the Settings scene (`SettingsLink` in `DKAppCommands`).
- `Return` — the welcome panel's primary action is the default action.
- `Escape` — closes sheets and the Settings window using the system behaviour.
- Native text fields keep standard focus, selection and submit behaviour.
- The View menu contains Appearance, Language and “Show Welcome Again”.
- The App menu's About item is standard.

Custom choice cards and segmented controls are pointer-first; they expose
selection traits but do not impose a custom arrow-key model over macOS.

## 8. Persistence

| Key | Value |
| --- | --- |
| `aymdk.language` | `en` / `zh-Hans` |
| `aymdk.appearance` | `system` / `light` / `dark` |
| `aymdk.window.preset` | `compact` / `standard` / `large` |
| `aymdk.welcome.version` | completed welcome version |
| `aymdk.welcome.completed` | boolean mirror for diagnostics |

`DKAppSettings` writes on every change. A host that needs a separate defaults
suite can create its own instance with `DKAppSettings(defaults:welcomeVersion:)`.

## 9. Accessibility

- Icon-only controls have labels; choice cards expose `.isSelected`.
- Decorative ASCII is hidden from accessibility.
- Reduce Motion disables the pulse, the ASCII timeline, the appearance crossfade
  and window animation.
- The contrast tests enforce WCAG AA for every tone and both appearances.
- Text remains selectable in inspector rows; copy actions are available without
  a context menu.

## 10. Do not

- Do not add a second primary button to one card.
- Do not use colour alone to communicate state; pair it with an icon or label.
- Do not animate layout and shadow at the same time on hover.
- Do not put the ASCII field behind body text.
- Do not re-centre the window when applying a preset.
- Do not replace the appearance transition with an instant `NSApp.appearance`
  assignment in an adopting app.
