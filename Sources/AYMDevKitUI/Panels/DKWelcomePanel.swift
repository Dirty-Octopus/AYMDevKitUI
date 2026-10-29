import SwiftUI

/// Host overrides for the unified welcome panel. Every string is optional: nil
/// falls back to the library copy, resolved through the selected language.
public struct DKWelcomeConfiguration {
    public var eyebrow: String?
    public var title: String?
    public var subtitle: String?
    /// Short value statements shown in the brand column. Empty hides the list.
    public var highlights: [String]?
    public var footnote: String?
    public var startTitle: String?
    public var showsLanguage: Bool
    public var showsAppearance: Bool
    public var showsWindowPreset: Bool
    /// Called after the welcome version is marked complete.
    public var onFinish: (() -> Void)?

    public init(
        eyebrow: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        highlights: [String]? = nil,
        footnote: String? = nil,
        startTitle: String? = nil,
        showsLanguage: Bool = true,
        showsAppearance: Bool = true,
        showsWindowPreset: Bool = true,
        onFinish: (() -> Void)? = nil
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.highlights = highlights
        self.footnote = footnote
        self.startTitle = startTitle
        self.showsLanguage = showsLanguage
        self.showsAppearance = showsAppearance
        self.showsWindowPreset = showsWindowPreset
        self.onFinish = onFinish
    }
}

/// The framework welcome panel.
///
/// Layout: a brand column on the left, a setup column on the right. Setup is a
/// fixed order — language, appearance, window size — and every app that adopts
/// DevKit shows the same panel, only the identity and copy change.
public struct DKWelcomePanel: View {
    @DKThemeValue private var theme

    private let info: DKAppInfo
    @ObservedObject private var settings: DKAppSettings
    private let configuration: DKWelcomeConfiguration
    private let scrolls: Bool

    public init(
        info: DKAppInfo = .current,
        settings: DKAppSettings,
        configuration: DKWelcomeConfiguration = .init(),
        scrolls: Bool = true
    ) {
        self.info = info
        self._settings = ObservedObject(wrappedValue: settings)
        self.configuration = configuration
        self.scrolls = scrolls
    }

    public var body: some View {
        Group {
            if scrolls {
                ScrollView {
                    panel
                }
                .scrollIndicators(.hidden)
            } else {
                panel
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var panel: some View {
        HStack(spacing: 0) {
            brandColumn
                .frame(width: 330)
                .frame(maxHeight: .infinity)

            DKHairline(vertical: true)

            setupColumn
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: 940)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .strokeBorder(theme.outline, lineWidth: 1)
        )
        .shadow(color: theme.shadow, radius: 34, x: 0, y: 20)
        .padding(.horizontal, 40)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Brand column

    private var brandColumn: some View {
        ZStack {
            theme.softGradient
            theme.primaryContainer.opacity(theme.isDark ? 0.34 : 0.52)

            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(theme.brand.primary.opacity(theme.isDark ? 0.30 : 0.18))
                        .frame(width: 300, height: 300)
                        .blur(radius: 42)
                        .offset(x: proxy.size.width * 0.55, y: -90)

                    Circle()
                        .fill(theme.brand.secondary.opacity(theme.isDark ? 0.20 : 0.12))
                        .frame(width: 240, height: 240)
                        .blur(radius: 46)
                        .offset(x: -70, y: proxy.size.height - 60)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                DKMarkView(info.mark, size: 66, style: .gradient, showsGlow: true)

                Spacer().frame(height: 24)

                Text("[ \(eyebrow) ]")
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(theme.primary)
                    .lineLimit(1)

                Text(title)
                    .font(.system(size: 31, weight: .heavy, design: .rounded))
                    .tracking(-0.6)
                    .foregroundStyle(theme.textPrimary)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)

                if !highlights.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(highlights.enumerated()), id: \.offset) { _, item in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundStyle(theme.primary)
                                    .frame(width: 16, height: 16)
                                    .background(Circle().fill(theme.primaryContainer))
                                Text(item)
                                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.textSecondary)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 26)
                }

                Spacer(minLength: 26)

                DKASCIIRule()

                HStack(spacing: 8) {
                    Text("v\(info.versionText)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(theme.textTertiary)
                    Spacer(minLength: 0)
                    Text("[ \(DKFrameworkInfo.shortName) ]")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(theme.primary)
                }
                .padding(.top, 14)
            }
            .padding(30)
        }
        .clipped()
    }

    // MARK: - Setup column

    private var setupColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text("[ \(DKL10n.t("welcome.setup.eyebrow").uppercased()) ]")
                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(theme.textTertiary)
                Text(DKL10n.t("welcome.setup.title"))
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
            }

            if configuration.showsLanguage {
                languageSection
            }

            if configuration.showsLanguage && (configuration.showsAppearance || configuration.showsWindowPreset) {
                DKASCIIRule()
            }

            if configuration.showsAppearance {
                appearanceSection
            }

            if configuration.showsAppearance && configuration.showsWindowPreset {
                DKASCIIRule()
            }

            if configuration.showsWindowPreset {
                windowSection
            }

            if configuration.showsLanguage || configuration.showsAppearance || configuration.showsWindowPreset {
                DKASCIIRule()
            }

            footer
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DKStepHeader(
                index: "01",
                title: DKL10n.t("welcome.language.title"),
                subtitle: DKL10n.t("welcome.language.subtitle"),
                symbol: "globe"
            )

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

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DKStepHeader(
                index: "02",
                title: DKL10n.t("welcome.appearance.title"),
                subtitle: DKL10n.t("welcome.appearance.subtitle"),
                symbol: "circle.lefthalf.filled"
            )

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

    private var windowSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DKStepHeader(
                index: "03",
                title: DKL10n.t("welcome.window.title"),
                subtitle: DKL10n.t("welcome.window.subtitle"),
                symbol: "rectangle.on.rectangle"
            )

            HStack(spacing: 10) {
                ForEach(DKWindowPreset.allCases) { preset in
                    DKChoiceCard(
                        title: DKL10n.t(preset.titleKey),
                        subtitle: preset.sizeText,
                        leading: .window(preset),
                        selected: settings.windowPreset == preset,
                        compact: true
                    ) {
                        settings.windowPreset = preset
                    }
                }
            }
        }
    }

    private var footer: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(DKL10n.t("welcome.ready.title"))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text(footnote)
                    .font(.system(size: 9.5, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            DKButton(
                startTitle,
                systemImage: "arrow.right",
                variant: .primary,
                size: .large,
                action: finish
            )
            .keyboardShortcut(.defaultAction)
        }
    }

    // MARK: - Copy

    private var eyebrow: String {
        configuration.eyebrow ?? info.name.uppercased()
    }

    private var title: String {
        configuration.title ?? String(format: DKL10n.t("welcome.title"), info.name)
    }

    private var subtitle: String {
        configuration.subtitle ?? DKL10n.t("welcome.subtitle")
    }

    private var highlights: [String] {
        if let highlights = configuration.highlights {
            return highlights
        }
        return [
            DKL10n.t("welcome.highlight.1"),
            DKL10n.t("welcome.highlight.2"),
            DKL10n.t("welcome.highlight.3")
        ]
    }

    private var footnote: String {
        configuration.footnote ?? DKL10n.t("welcome.footnote")
    }

    private var startTitle: String {
        configuration.startTitle ?? DKL10n.t("welcome.start")
    }

    private func finish() {
        withAnimation(DKMotion.standard) {
            settings.completeWelcome()
        }
        configuration.onFinish?()
    }
}
