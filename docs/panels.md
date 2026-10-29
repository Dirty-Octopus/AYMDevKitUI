# Panels

The welcome and settings panels are the framework's public face. They are not
sample screens: adopting apps use them directly, so their order, spacing and
copy are part of the contract.

## Welcome panel

`DKWelcomePanel` is a gate shown once per `welcomeVersion`. It has two columns:

- **Brand column (330pt)** — app mark, `[ APP NAME ]`, “Welcome to …”, a short
  promise, three value statements, a dashed ASCII rule and `v…` + `[ AYMDEVKUI ]`.
- **Setup column** — `[ SETUP ]`, “Make it yours”, then three numbered steps in a
  fixed order:
  1. `[01] Language`
  2. `[02] Appearance`
  3. `[03] Window size`
  and the primary action.

The whole panel is one surface: 940pt max width, 34pt radius, 40/32pt outer
padding, 28/26pt inner padding, and a single shadow. It scrolls only when the
window is shorter than the content.

### Behaviour

- Every choice applies immediately; there is no Apply button.
- Language changes re-resolve the panel copy in place.
- Appearance uses the library crossfade (`DKAppearanceTransition`).
- Window size resizes the host window in place around its top-left corner.
- “Get started” calls `settings.completeWelcome()`, then `configuration.onFinish`,
  and `DKAppRoot` cross-fades to the app content.
- Bumping `welcomeVersion` (for example from `"1"` to `"2"`) shows the panel
  again for every existing install.

### Configuration

```swift
var config = DKWelcomeConfiguration()
config.eyebrow = "MYAPP"
config.title = "Welcome to MyApp"
config.subtitle = "Two minutes of setup, then never again."
config.highlights = [
    "Local-first by default",
    "One workspace for every project",
    "Native macOS behaviour"
]
config.footnote = "Change any of this later in Settings."
config.startTitle = "Open workspace"
config.showsLanguage = true
config.showsAppearance = true
config.showsWindowPreset = true

DKWelcomePanel(
    info: .current,
    settings: settings,
    configuration: config
)
```

Every string is optional. `nil` falls back to the library copy, resolved through
the selected language. Empty `highlights` hides the list.

### Copy keys

| Key | English |
| --- | --- |
| `welcome.title` | `Welcome to %@` |
| `welcome.subtitle` | A consistent place to start… |
| `welcome.setup.eyebrow` | `Setup` |
| `welcome.setup.title` | `Make it yours` |
| `welcome.language.title` / `.subtitle` | Language / Pick the language… |
| `welcome.appearance.title` / `.subtitle` | Appearance / Match the system… |
| `welcome.window.title` / `.subtitle` | Window size / Choose a starting size… |
| `welcome.ready.title` | `Ready when you are` |
| `welcome.footnote` | Everything here can be changed later… |
| `welcome.start` | `Get started` |
| `welcome.highlight.1…3` | value statements |

`welcome.title` receives the app name through `String(format:)`.

### Direct use

`DKAppRoot` shows the panel automatically. For a custom scene:

```swift
ZStack {
    DKAppBackground()
    DKWelcomePanel(info: info, settings: settings)
}
.dkBrand(.aurora)
.environment(\.locale, settings.language.locale)
```

## Settings panel

`DKSettingsPanel` is designed for a 640 × 680 window. It is the canonical
Settings scene for every DevKit app.

### Anatomy

1. **Header** — app mark, `[ PREFERENCES ]`, “Settings”, app name + version, and
   an optional close button.
2. `[01] Language` — the same two choice cards as the welcome panel.
3. `[02] Appearance` — system / light / dark, same cards, same crossfade.
4. `[03] Window size` — three rows with miniature window previews, exact size
   text and a selection check.
5. **Host sections** — zero or more `DKSettingsSection`, appended in order.
6. `[0n] About` — version, build, bundle id (copyable), licence, website /
   repository, “Welcome panel” reset.
7. `DKASCIIRule` and a mono footer with the framework version and copyright.

The panel scrolls; the width is fixed so opening and closing it never changes
the host's layout.

### Host sections

```swift
let general = DKSettingsSection(
    id: "general",
    title: "General",
    subtitle: "How this app behaves.",
    symbol: "switch.2"
) {
    VStack(spacing: 8) {
        DKToggleRow(
            "Launch at login",
            subtitle: "Start in the background",
            systemImage: "power",
            isOn: $launchAtLogin
        )
        DKToggleRow(
            "Show menu bar item",
            subtitle: "Always available",
            systemImage: "menubar.rectangle",
            isOn: $showMenuBar
        )
    }
}

DKSettingsPanel(
    info: info,
    brand: .aurora,
    settings: settings,
    extraSections: [general]
)
```

`DKSettingsSection` is identified by `id`. It owns its content, but it does not
own its chrome: the panel supplies the card, index, icon and spacing.

### Presentation

Use the standard Settings scene:

```swift
Settings {
    DKSettingsPanel(info: info, brand: .aurora, settings: settings)
}
```

`DKAppCommands` replaces the App menu's Settings item with a `SettingsLink`
bound to `⌘,`. No close button is needed in this presentation; pass `onClose:`
only when showing the panel as a sheet:

```swift
.sheet(isPresented: $showingSettings) {
    DKSettingsPanel(
        info: info,
        settings: settings,
        onClose: { showingSettings = false }
    )
}
```

### Reset

“Show welcome” calls `settings.resetWelcome()`. `DKAppRoot` notices the change
and cross-fades back to the welcome panel. The rest of the settings are kept.

## Consistency checklist

Before shipping a new app:

- [ ] The welcome panel is reachable from Settings → “Show welcome”.
- [ ] The core order is language → appearance → window.
- [ ] The same `DKBrand` is passed to `DKAppRoot`, `DKSettingsPanel` and any
      standalone `DKWelcomePanel`.
- [ ] `welcomeVersion` is bumped when the first-run flow changes.
- [ ] New sections are appended, never inserted before `[03]`.
- [ ] New copy exists in both `en.lproj` and `zh-Hans.lproj`.
- [ ] The panel is checked at 1040 × 680 and 1380 × 920.
- [ ] The panel is checked in light, dark and 简体中文.
- [ ] The window preset changes in place; the window does not move.
- [ ] The appearance switch crossfades every visible window.
