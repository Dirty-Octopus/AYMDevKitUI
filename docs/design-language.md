# Design language

This document is the contract for the visual side of AYMDevKitUI. Components are
allowed to look different from each other only when their role differs; they are
never allowed to invent a new colour, radius, type size or motion curve.

## 1. Principles

1. **One identity, many apps.** A host declares six brand colours. The library
   derives every other token for light and dark.
2. **System first.** The default appearance is `system`. DevKit only owns the
   pixels it draws; native menus, traffic lights and sheets follow macOS.
3. **Structure over decoration.** Surfaces communicate depth, not importance.
   Elevation is reserved for cards and floating actions.
4. **Ambient, not noisy.** The ASCII field is a background layer. It must never
   reduce the contrast of text or compete with a card.
5. **Motion explains change.** Feedback is fast, layout changes are springy, and
   state changes the user initiated get the most emphasis.
6. **ASCII is texture, not a gimmick.** Mono labels, bracketed indices and the
   ripple field share one visual grammar. Do not sprinkle ASCII characters into
   body copy.

## 2. Brand → theme

`DKBrand` is deliberately small:

| Token | Role |
| --- | --- |
| `primary` | vivid fill, gradient start, app mark |
| `primaryDeep` | gradient end, pressed states |
| `primarySoft` | readable accent in dark mode |
| `secondary`, `secondaryDeep` | expressive gradients and highlights |
| `success`, `warning`, `danger`, `info` | semantic states |
| `lightBase`, `darkBase` | neutral bases the surfaces are mixed from |

`DKTheme(scheme:brand:)` resolves the rest:

| Theme token | Light | Dark |
| --- | --- | --- |
| `canvas` | `lightBase` mixed with `primary` ≈ 3.5% | `darkBase` mixed with `primary` ≈ 4.5% |
| `surface` | white | `darkBase` mixed with white ≈ 4.5% |
| `surfaceLow` | white + `primary` ≈ 5.5% | `darkBase` + `primary` ≈ 11% |
| `surfaceHigh` | white + `primary` ≈ 10% | `darkBase` + `primary` ≈ 17% |
| `outline` | ink at 9% | white at 10% |
| `textPrimary` | `#1A1424` | `#F9F5FF` |
| `textSecondary` | `#574E66` | `#C6BBD6` |
| `textTertiary` | `#6E647D` | `#A69AB8` |
| `primary` | `ensureContrast(primary, surface, 4.5)` | `ensureContrast(primarySoft, surface, 4.5)` |
| `primaryContainer` | white + `primary` ≈ 12% | `surface` + `primary` ≈ 26% |
| `success` / `warning` / `danger` / `info` | brand hue, nudged until 4.5:1 | same rule |

Two accent roles exist for a reason:

- `accentFill` / `theme.fill(for:)` is the vivid colour. Use it for filled
  surfaces with white text.
- `theme.primary` is the readable accent. Use it for text, icons and strokes.

Never use `brand.primary` for small text on a surface. Never use `theme.primary`
as a large fill with white text without checking the fill's contrast; use the
gradient or `accentFill` instead.

### Gradients

- `primaryGradient` — the app mark, primary buttons, the welcome hero.
- `expressiveGradient` — only for the drop-zone target and the welcome orb.
- `softGradient` — the welcome brand column and empty-state orbs.

### Semantic tones

`DKTone` is the only vocabulary for status: `accent`, `success`, `warning`,
`danger`, `info`, `neutral`. Badges, notices, live dots and progress rings all
consume it. A new status must map onto one of these; it must not add a colour.

## 3. Typography

All type is the system rounded design, except mono labels. The scale is fixed:

| Style | Size / weight | Tracking | Use |
| --- | --- | --- | --- |
| `display` | 48 heavy | -1.2 | marketing hero only |
| `titleXL` | 34 heavy | -0.6 | welcome title, page hero |
| `titleL` | 25 heavy | -0.4 | gallery section title |
| `title` | 19 bold | -0.2 | panel section title |
| `headline` | 15 bold | 0 | card heading |
| `body` | 13 medium | 0 | body copy |
| `bodySmall` | 11.5 medium | 0 | dense descriptions |
| `label` | 12.5 semibold | 0 | field labels |
| `button` | 14 bold | 0 | button labels |
| `caption` | 10.5 medium | 0 | metadata |
| `micro` | 9.5 medium | 0 | smallest metadata |
| `eyebrow` | 11 bold, uppercase | 1.8 | section eyebrows |
| `mono` | 10.5 monospaced | 0 | versions, indices, paths |
| `monoSmall` | 9.5 monospaced | 0 | dense technical metadata |

Rules:

- Use `DKText` with a style; do not write `.font(.system(size:))` in a
  component unless the size comes from `DKControlSize`.
- Eyebrows are always uppercase and tracked. `[01]`, `[ SETUP ]` and
  `v1.0.0 (1)` are mono.
- Line spacing: display/title 2, body 3, caption 2. Use the style, not ad-hoc
  spacing.

## 4. Space, radius, controls

Spacing is a 4pt rhythm with half-steps: 2, 4, 6, 8, 10, 12, 14, 16, 18, 20,
24, 28, 32, 36, 40, 48, 56, 64 (`DKSpacing`).

Radii (`DKRadius`): 8, 12, 16, 20, 24, 28, 36, and `pill` (999). Pills are for
controls; cards use 24–28; hero cards use 34–36.

Control heights (`DKControlSize`):

| Size | Height | Font | Horizontal padding | Icon |
| --- | --- | --- | --- | --- |
| `small` | 32 | 12.5 | 12 | 11 |
| `regular` | 42 | 14 | 18 | 13 |
| `large` | 48 | 15 | 22 | 14 |

The window presets are part of the visual language:

| Preset | Content size |
| --- | --- |
| Compact | 1040 × 720 |
| Standard | 1180 × 820 |
| Large | 1380 × 920 |

The minimum window is 1040 × 680. Presets are clamped to the visible screen.

## 5. Surfaces and elevation

| Component | Use | Elevation |
| --- | --- | --- |
| `DKCard` | one logical group | `.low` normally, `.medium` for hero/floating |
| `DKInset` | rows inside a card, sidebars, previews | none |
| `DKHairline` | separation inside a card | none |
| `DKASCIIRule` | ambient separator in welcome/settings | none |
| `DKAppBackground` | the window | none |

Rules:

- Never nest a `DKCard` inside another `DKCard` for visual effect.
- Every card gets exactly one outline. Shadows are not borders.
- An active/selected card uses `primaryContainer` and a 1.5pt accent border.
- Rows in a sidebar or settings list use `DKInset` or a 12pt radius, not a card.

## 6. The ASCII ambient background

`DKAppBackground` draws `DKASCIIField` over the brand-tinted canvas:

- Grid: 10 × 10pt cells, 8.5pt monospaced code glyphs from a deterministic
  alphabet (`0–9`, `a–f`, `x`, `+ - = / \ | < > { } [ ] ; : . # % &`).
- Baseline: one text row per scanline at 0.075 opacity in dark and 0.06 in light. This keeps the field dense
  while shaping a whole row at once instead of thousands of isolated glyphs.
- **The baseline characters themselves animate.** Each cell has a staggered
  1.35s generation clock; the alphabet is re-rolled per generation. The baseline
  colour never changes — it stays in the primary hue.
- Surface: two travelling sine waves crossing at different angles.
- Depth: `DKNoise.fbm(x, y, octaves: 3)` — deterministic Perlin noise.
- Crests: brighten the baseline glyph in the primary hue. Water is not an
  interaction, so it does not introduce the accent colour. The field itself is
  monochrome per appearance; only click rings and the hover wake bring in the
  accent.
- Click ripple: a normalised centre plus timestamp; the field draws an expanding
  ring (`radius = age × 0.42`, band width 0.07) for 2.4 seconds using a dedicated
  ripple alphabet (`~ = + * #`) and the accent hue.
- Hover trail: pointer points are stored at most every 25ms and 2.5pt of
  movement, then rasterised into a wake map with a 2.8-cell radius. There is no
  separate trail view; the wake is part of the same character field. Trail cells
  use the trail alphabet (`0 1 2 < > /`) and the accent hue. The influence
  radius per trail point decays with age (2.8 cells near the pointer to 0.8 at
  the tail); the glyph size is constant, so only the footprint shrinks.
- Timing: 6fps idle, 12fps while the trail or a ripple is active. Paused when
  the window is inactive or Reduce Motion is enabled.
- Intensity: `1.0` in the welcome/gallery, `0.42` in Settings. Pass
  `backgroundFieldIntensity: 0` to `DKAppRoot` to remove it.

The field is decorative: it is `allowsHitTesting(false)`, `accessibilityHidden`,
and must stay behind opaque surfaces. Text is never placed directly on it.

## 7. Motion

| Token | Curve | Use |
| --- | --- | --- |
| `instant` | linear 0.12s | clear buttons, tiny state flips |
| `quick` | spring response 0.24, damping 0.86 | hover, press, toggle |
| `standard` | spring response 0.32, damping 0.80 | selection, layout |
| `emphasized` | spring response 0.42, damping 0.74 | welcome → app |
| `gentle` | easeInOut 0.22s | cross-fades between screens |
| `appearanceDuration` | 0.34s crossfade | light/dark switch |
| `windowResizeDuration` | 0.26s | preset resize |

Rules:

- Hover: scale ≤ 1.012, border or background change, never both a shadow jump
  and a scale jump.
- Press: scale 0.975, shadow shrinks.
- Selection: matched-geometry pill in sidebars/segmented controls.
- Reduce Motion disables the pulse, the ASCII animation, the appearance
  crossfade and the window animation. It does not remove state changes.

## 8. Contrast and accessibility

The test suite asserts:

- `textPrimary` on `surface` ≥ 7:1 (AAA).
- `textSecondary`, `textTertiary`, `primary`, `onPrimaryContainer` and every
  `DKTone` on `surface` ≥ 4.5:1 (AA).
- `textTertiary` on `canvas` ≥ 4.5:1.
- Solid badges pick a foreground via `DKColorMath.ensureContrast`.

Do not lower these. If a new brand breaks them, adjust the brand or the
derivation, not the test.

Other rules:

- Every icon-only button has `.help` and an accessibility label.
- Every choice card exposes `.isSelected` when selected.
- Reduce Motion is honoured by `DKMotion.resolve`, `DKLiveDot`, the ASCII field,
  `DKWindowManager` and `DKAppearanceTransition`.
- Decorative ASCII is hidden from accessibility.
