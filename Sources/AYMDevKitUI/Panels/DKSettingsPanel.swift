import SwiftUI
import AppKit

/// Host-provided settings section. Use it to add app-specific preferences
/// without breaking the visual rhythm of the framework panel.
public struct DKSettingsSection: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let symbol: String
    public let content: AnyView

    public init<Content: View>(
        id: String,
        title: String,
        subtitle: String? = nil,
        symbol: String = "slider.horizontal.3",
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.content = AnyView(content())
    }
}

/// The framework settings panel.
///
/// Sections are fixed: language, appearance, window size, host extras, about.
/// The panel is designed for a 640 × 680 window and scrolls when the host adds
/// extra sections.
public struct DKSettingsPanel: View {
    @DKThemeValue private var theme

    private let info: DKAppInfo
    private let brand: DKBrand
    @ObservedObject private var settings: DKAppSettings
    private let extraSections: [DKSettingsSection]
    private let showsWindowSection: Bool
    private let showsAboutSection: Bool
    private let onClose: (() -> Void)?
    private let scrolls: Bool

    public init(
        info: DKAppInfo = .current,
        brand: DKBrand = .default,
        settings: DKAppSettings,
        extraSections: [DKSettingsSection] = [],
        showsWindowSection: Bool = true,
        showsAboutSection: Bool = true,
        scrolls: Bool = true,
        onClose: (() -> Void)? = nil
    ) {
        self.info = info
        self.brand = brand
        self._settings = ObservedObject(wrappedValue: settings)
        self.extraSections = extraSections
        self.showsWindowSection = showsWindowSection
        self.showsAboutSection = showsAboutSection
        self.scrolls = scrolls
        self.onClose = onClose
    }

    public var body: some View {
        ZStack {
            DKAppBackground(fieldIntensity: 0.42)

            if scrolls {
                ScrollView {
                    content
                }
                .scrollIndicators(.hidden)
            } else {
                content
            }
        }
        .frame(width: 640)
        .frame(height: scrolls ? 680 : nil)
        .dkBrand(brand)
        .environment(\.locale, settings.language.locale)
        .dkAmbientRipples()
        .background {
            DKWindowAccessor { window in
                guard let window else { return }
                DKWindowManager.shared.styleAuxiliary(window)
            }
            .frame(width: 0, height: 0)
        }
    }

    private var content: some View {
        VStack(spacing: 16) {
            header
            languageSection
            appearanceSection
            if showsWindowSection { windowSection }
            ForEach(Array(extraSections.enumerated()), id: \.element.id) { index, section in
                sectionCard(
                    index: String(format: "%02d", 4 + index),
                    title: section.title,
                    subtitle: section.subtitle,
                    symbol: section.symbol
                ) {
                    section.content
                }
            }
            if showsAboutSection { aboutSection }
            DKASCIIRule()
            footer
        }
        .frame(maxWidth: 620)
        .padding(.horizontal, 24)
        .padding(.top, 34)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: DKSpacing.x14) {
            DKMarkView(info.mark, size: 38, style: .gradient, showsGlow: true)

            VStack(alignment: .leading, spacing: 2) {
                Text("[ PREFERENCES ]")
                    .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(theme.textTertiary)
                Text(DKL10n.t("settings.title"))
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text(info.nameAndVersion)
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(theme.textTertiary)
            }

            Spacer(minLength: 0)

            if let onClose {
                DKIconButton(
                    systemImage: "xmark",
                    help: DKL10n.t("common.close"),
                    size: 30,
                    action: onClose
                )
            }
        }
        .padding(.bottom, 2)
    }

    // MARK: - Language

    private var languageSection: some View {
        sectionCard(
            index: "01",
            title: DKL10n.t("settings.language.title"),
            subtitle: DKL10n.t("settings.language.subtitle"),
            symbol: "globe"
        ) {
            HStack(spacing: 10) {
                ForEach(DKLanguage.allCases) { language in
                    DKChoiceCard(
                        title: language.displayName,
                        subtitle: DKL10n.t(language.subtitleKey),
                        leading: .badge(language.badgeText),
                        selected: settings.language == language,
                        compact: true
                    ) {
                        settings.language = language
                    }
                }
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        sectionCard(
            index: "02",
            title: DKL10n.t("settings.appearance.title"),
            subtitle: DKL10n.t("settings.appearance.subtitle"),
            symbol: "circle.lefthalf.filled"
        ) {
            HStack(spacing: 10) {
                ForEach(DKAppearance.allCases) { appearance in
                    DKChoiceCard(
                        title: DKL10n.t(appearance.titleKey),
                        subtitle: DKL10n.t(appearance.subtitleKey),
                        leading: .symbol(appearance.systemImage),
                        selected: settings.appearance == appearance,
                        compact: true
                    ) {
                        settings.appearance = appearance
                    }
                }
            }
        }
    }

    // MARK: - Window

    private var windowSection: some View {
        sectionCard(
            index: "03",
            title: DKL10n.t("settings.window.title"),
            subtitle: DKL10n.t("settings.window.subtitle"),
            symbol: "macwindow"
        ) {
            VStack(spacing: 4) {
                ForEach(DKWindowPreset.allCases) { preset in
                    windowRow(preset)
                }
            }
        }
    }

    private func windowRow(_ preset: DKWindowPreset) -> some View {
        let selected = settings.windowPreset == preset
        return Button {
            settings.windowPreset = preset
        } label: {
            HStack(spacing: DKSpacing.x10) {
                DKWindowPreview(preset: preset, width: 38)

                VStack(alignment: .leading, spacing: 1) {
                    Text(DKL10n.t(preset.titleKey))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                    Text(preset.sizeText)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(theme.textTertiary)
                }

                Spacer(minLength: 0)

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(selected ? theme.primary : theme.textTertiary.opacity(0.35))
            }
            .padding(.horizontal, DKSpacing.x10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                    .fill(selected ? theme.primaryContainer.opacity(0.42) : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                    .strokeBorder(selected ? theme.primary.opacity(0.2) : theme.outline.opacity(0.5), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: - About

    private var aboutSection: some View {
        sectionCard(
            index: String(format: "%02d", 4 + extraSections.count),
            title: DKL10n.t("settings.about.title"),
            subtitle: DKL10n.t("settings.about.subtitle"),
            symbol: "info.circle"
        ) {
            VStack(spacing: 9) {
                DKInfoRow(DKL10n.t("settings.about.version"), value: info.versionText)
                if let build = info.build, !build.isEmpty {
                    DKInfoRow(DKL10n.t("settings.about.build"), value: build, monospaced: true)
                }
                DKInfoRow(
                    DKL10n.t("settings.about.bundle"),
                    value: info.bundleIdentifier,
                    monospaced: true,
                    copyable: true
                )
                DKInfoRow(DKL10n.t("settings.about.license"), value: info.license)

                if let website = info.website {
                    linkRow(title: DKL10n.t("settings.about.website"), url: website)
                }
                if let repository = info.repository {
                    linkRow(title: DKL10n.t("settings.about.repository"), url: repository)
                }

                DKHairline()
                    .padding(.vertical, 2)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(DKL10n.t("settings.resetWelcome.title"))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textPrimary)
                        Text(DKL10n.t("settings.resetWelcome.subtitle"))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textTertiary)
                    }
                    Spacer(minLength: 0)
                    DKButton(
                        DKL10n.t("settings.resetWelcome"),
                        systemImage: "arrow.counterclockwise",
                        variant: .ghost,
                        size: .small
                    ) {
                        settings.resetWelcome()
                    }
                }
            }
        }
    }

    private func linkRow(title: String, url: URL) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DKSpacing.x12) {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textTertiary)
                .frame(width: 92, alignment: .leading)

            Button {
                NSWorkspace.shared.open(url)
            } label: {
                HStack(spacing: 4) {
                    Text(url.host ?? url.absoluteString)
                        .font(.system(size: 11.5, weight: .medium, design: .rounded))
                        .lineLimit(1)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(theme.primary)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(url.absoluteString)

            Spacer(minLength: 0)
        }
    }

    private var footer: some View {
        HStack(spacing: DKSpacing.x10) {
            Text("[ \(DKFrameworkInfo.name) \(DKFrameworkInfo.version) ]")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(theme.primary)
            Spacer(minLength: 0)
            Text(info.copyright)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textTertiary)
                .lineLimit(1)
        }
        .padding(.top, 2)
    }

    // MARK: - Section chrome

    private func sectionCard<Content: View>(
        index: String,
        title: String,
        subtitle: String?,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top, spacing: DKSpacing.x10) {
                    Text("[\(index)]")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(theme.primary)
                        .frame(width: 34, alignment: .leading)
                        .padding(.top, 8)

                    Image(systemName: symbol)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(theme.primary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(theme.primaryContainer))
                        .overlay(Circle().strokeBorder(theme.primary.opacity(0.14), lineWidth: 1))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 12.5, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Spacer(minLength: 0)
                }

                content()
            }
        }
    }
}
