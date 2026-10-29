import SwiftUI
import AYMDevKitUI

struct DemoPanels: View {
    @DKThemeValue private var theme
    @EnvironmentObject private var settings: DKAppSettings
    @Environment(\.openSettings) private var openSettings

    @State private var showsSettingsSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            HStack(alignment: .top, spacing: 16) {
                welcomeCard
                settingsCard
            }
            HStack(alignment: .top, spacing: 16) {
                rules
                configuration
            }
        }
        .sheet(isPresented: $showsSettingsSheet) {
            DKSettingsPanel(
                info: Demo.info,
                brand: .aurora,
                settings: settings,
                onClose: { showsSettingsSheet = false }
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Panels")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(theme.textPrimary)
            Text("The welcome and settings panels are the framework contract: every app that adopts DevKit starts and configures itself the same way.")
                .font(.system(size: 11.5, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var welcomeCard: some View {
        DKCard(padding: 20, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    DKMarkView(.monogram("DK"), size: 38, style: .gradient, showsGlow: true)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Welcome panel")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary)
                        Text("First run · once per welcome version")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textTertiary)
                    }
                }

                Text("A brand column plus a three-step setup card. Language, appearance and window size are chosen once, then remembered.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 5) {
                    DKBadge("01 Language", tone: .accent, compact: true)
                    DKBadge("02 Appearance", tone: .info, compact: true)
                    DKBadge("03 Window", tone: .neutral, compact: true)
                }

                DKButton("Show welcome", systemImage: "sparkles") {
                    settings.resetWelcome()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var settingsCard: some View {
        DKCard(padding: 20, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    DKMarkView(.symbol("gearshape.fill"), size: 38, style: .tinted)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Settings panel")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary)
                        Text("⌘, · separate Settings scene")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textTertiary)
                    }
                }

                Text("The same language and appearance controls, plus window size and an about section. Hosts append sections without reordering the core.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 5) {
                    DKBadge("640 × 680", tone: .neutral, compact: true)
                    DKBadge("Scrolls", tone: .neutral, compact: true)
                    DKBadge("⌘,", tone: .neutral, compact: true)
                }

                HStack(spacing: 8) {
                    DKButton("Open settings", variant: .tonal, action: { openSettings() })
                    DKButton("Preview sheet", variant: .ghost) {
                        showsSettingsSheet = true
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var rules: some View {
        DKCard(padding: 20, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Panel invariants", subtitle: "What every adopting app gets for free.")
                invariant("01", "The welcome panel is a gate, not a tour.", "One card, three choices, one primary action.")
                invariant("02", "Setup order never changes.", "Language, appearance, window size — always.")
                invariant("03", "Settings mirrors the welcome choices.", "Same option cards, same labels, same tones.")
                invariant("04", "Choices apply immediately.", "No Apply button; everything is persisted on change.")
                invariant("05", "Hosts append, never reorder.", "DKSettingsSection adds app-specific groups below the core.")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var configuration: some View {
        DKCard(padding: 20, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Welcome configuration", subtitle: "Copy and steps are opt-in overrides.")
                DKInset(padding: 12, radius: DKRadius.md) {
                    VStack(alignment: .leading, spacing: 6) {
                        codeRow("showsLanguage", "true")
                        codeRow("showsAppearance", "true")
                        codeRow("showsWindowPreset", "true")
                        codeRow("eyebrow", "info.name")
                        codeRow("onFinish", "completeWelcome()")
                    }
                }

                Text("Library copy lives in `en.lproj` and `zh-Hans.lproj`. The panel resolves the selected language, and every host string is optional.")
                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func invariant(_ index: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Text(index)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.primary)
                .frame(width: 20, height: 20)
                .background(Circle().fill(theme.primaryContainer))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text(detail)
                    .font(.system(size: 9.5, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func codeRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(key)
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(theme.primary)
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(theme.textSecondary)
        }
    }
}
