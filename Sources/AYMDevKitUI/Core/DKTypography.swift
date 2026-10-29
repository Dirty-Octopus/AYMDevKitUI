import SwiftUI

/// The type scale. Every DevKit view uses one of these styles; ad-hoc font sizes
/// are a design bug because they break the visual rhythm between panels.
public enum DKTextStyle: String, CaseIterable, Identifiable {
    case display
    case titleXL
    case titleL
    case title
    case headline
    case body
    case bodySmall
    case label
    case button
    case caption
    case micro
    case eyebrow
    case mono
    case monoSmall

    public var id: String { rawValue }

    public var font: Font {
        switch self {
        case .display: return .system(size: 48, weight: .heavy, design: .rounded)
        case .titleXL: return .system(size: 34, weight: .heavy, design: .rounded)
        case .titleL: return .system(size: 25, weight: .heavy, design: .rounded)
        case .title: return .system(size: 19, weight: .bold, design: .rounded)
        case .headline: return .system(size: 15, weight: .bold, design: .rounded)
        case .body: return .system(size: 13, weight: .medium, design: .rounded)
        case .bodySmall: return .system(size: 11.5, weight: .medium, design: .rounded)
        case .label: return .system(size: 12.5, weight: .semibold, design: .rounded)
        case .button: return .system(size: 14, weight: .bold, design: .rounded)
        case .caption: return .system(size: 10.5, weight: .medium, design: .rounded)
        case .micro: return .system(size: 9.5, weight: .medium, design: .rounded)
        case .eyebrow: return .system(size: 11, weight: .bold, design: .rounded)
        case .mono: return .system(size: 10.5, weight: .medium, design: .monospaced)
        case .monoSmall: return .system(size: 9.5, weight: .medium, design: .monospaced)
        }
    }

    public var tracking: CGFloat {
        switch self {
        case .display: return -1.2
        case .titleXL: return -0.6
        case .titleL: return -0.4
        case .title: return -0.2
        case .eyebrow: return 1.8
        default: return 0
        }
    }

    public var lineSpacing: CGFloat {
        switch self {
        case .display, .titleXL: return 2
        case .titleL, .title: return 2
        case .body, .bodySmall: return 3
        case .caption, .micro: return 2
        default: return 0
        }
    }

    public var isEyebrow: Bool { self == .eyebrow }
}

/// Colour roles for `DKText`. Roles resolve through the current theme.
public enum DKTextColor {
    case primary
    case secondary
    case tertiary
    case accent
    case success
    case warning
    case danger
    case info
    case onAccent
    case inherit

    func resolve(_ theme: DKTheme) -> Color {
        switch self {
        case .primary: return theme.textPrimary
        case .secondary: return theme.textSecondary
        case .tertiary: return theme.textTertiary
        case .accent: return theme.primary
        case .success: return theme.success
        case .warning: return theme.warning
        case .danger: return theme.danger
        case .info: return theme.info
        case .onAccent: return .white
        case .inherit: return theme.textPrimary
        }
    }
}

/// A text view with a design-system style applied. Localised strings resolve in
/// the DevKit resource bundle so every adopting app gets the same copy without
/// duplicating translations.
public struct DKText: View {
    @DKThemeValue private var theme

    private let content: Text
    private let style: DKTextStyle
    private let color: DKTextColor

    /// Localised library copy. The key lives in `Resources/*.lproj`.
    public init(
        _ key: LocalizedStringKey,
        style: DKTextStyle = .body,
        color: DKTextColor = .primary
    ) {
        self.content = Text(key, bundle: .module)
        self.style = style
        self.color = color
    }

    /// Host-provided copy (file names, user content, already-localised strings).
    public init(
        verbatim text: String,
        style: DKTextStyle = .body,
        color: DKTextColor = .primary
    ) {
        self.content = Text(verbatim: text)
        self.style = style
        self.color = color
    }

    public var body: some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
            .foregroundStyle(color.resolve(theme))
            .textCase(style.isEyebrow ? .uppercase : nil)
    }
}

// MARK: - Common text components

public struct DKEyebrow: View {
    private let text: Text

    public init(_ key: LocalizedStringKey) {
        self.text = Text(key, bundle: .module)
    }

    public init(verbatim: String) {
        self.text = Text(verbatim: verbatim)
    }

    public var body: some View {
        DKTextStyleView(text: text, style: .eyebrow, color: .tertiary)
    }
}

/// Two-line section header used by settings, welcome steps and cards.
public struct DKSectionHeader: View {
    private let title: Text
    private let subtitle: Text?

    public init(_ titleKey: LocalizedStringKey, subtitle subtitleKey: LocalizedStringKey? = nil) {
        self.title = Text(titleKey, bundle: .module)
        self.subtitle = subtitleKey.map { Text($0, bundle: .module) }
    }

    public init(verbatim title: String, subtitle: String? = nil) {
        self.title = Text(verbatim: title)
        self.subtitle = subtitle.map(Text.init(verbatim:))
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DKSpacing.x4) {
            DKTextStyleView(text: title, style: .title, color: .primary)
            if let subtitle {
                DKTextStyleView(text: subtitle, style: .bodySmall, color: .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Internal helper so the text components can pass a `Text` through the same
/// styling pipeline without exposing a second public type.
struct DKTextStyleView: View {
    @DKThemeValue private var theme

    let text: Text
    let style: DKTextStyle
    let color: DKTextColor

    var body: some View {
        text
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
            .foregroundStyle(color.resolve(theme))
            .textCase(style.isEyebrow ? .uppercase : nil)
    }
}

public extension View {
    /// Applies a type-scale style without creating another view wrapper.
    func dkTextStyle(_ style: DKTextStyle) -> some View {
        font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}
