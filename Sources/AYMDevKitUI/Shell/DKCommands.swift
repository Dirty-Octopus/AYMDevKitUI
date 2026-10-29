import SwiftUI

/// Standard menu commands for a DevKit app: Settings, language, appearance and
/// "show the welcome panel again".
///
/// Add the command set to the app scene and provide a `Settings` scene that
/// contains `DKSettingsPanel`:
///
/// ```swift
/// WindowGroup { DKAppRoot(...) { ... } }
///     .commands { DKAppCommands(settings: settings) }
///
/// Settings { DKSettingsPanel(info: .current, settings: settings) }
/// ```
public struct DKAppCommands: Commands {
    @ObservedObject private var settings: DKAppSettings
    private let info: DKAppInfo

    public init(settings: DKAppSettings, info: DKAppInfo = .current) {
        self._settings = ObservedObject(wrappedValue: settings)
        self.info = info
    }

    public var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            SettingsLink {
                Text(DKL10n.t("menu.settings"))
            }
            .keyboardShortcut(",", modifiers: .command)
        }

        CommandMenu(DKL10n.t("menu.view")) {
            Picker(
                DKL10n.t("menu.appearance"),
                selection: Binding(
                    get: { settings.appearance },
                    set: { settings.appearance = $0 }
                )
            ) {
                ForEach(DKAppearance.allCases) { appearance in
                    Text(DKL10n.t(appearance.titleKey)).tag(appearance)
                }
            }

            Menu(DKL10n.t("menu.language")) {
                ForEach(DKLanguage.allCases) { language in
                    Button {
                        settings.language = language
                    } label: {
                        if settings.language == language {
                            Label(language.displayName, systemImage: "checkmark")
                        } else {
                            Text(language.displayName)
                        }
                    }
                }
            }

            Divider()

            Button(DKL10n.t("menu.resetWelcome")) {
                settings.resetWelcome()
            }
        }

        CommandGroup(replacing: .appInfo) {
            Button(DKL10n.t("menu.aboutApp", info.name)) {
                NSApp.orderFrontStandardAboutPanel(nil)
            }
        }
    }
}
