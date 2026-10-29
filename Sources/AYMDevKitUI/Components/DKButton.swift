import SwiftUI

/// The six button roles in the system. Every clickable action in a DevKit app
/// must use one of these; ad-hoc buttons drift in height, radius and feedback.
public enum DKButtonVariant: String, CaseIterable, Identifiable {
    /// One per surface. The single most important action.
    case primary
    /// Neutral surface with an outline. Secondary actions.
    case secondary
    /// Brand-tinted surface. Contextual actions that belong to the accent.
    case tonal
    /// Text-only action with a quiet outline. Tertiary actions.
    case ghost
    /// Destructive actions. Never the default action of a confirmation.
    case destructive
    /// Inline text link. Used inside notices and prose.
    case link

    public var id: String { rawValue }
}

/// The framework button. Height, padding, radius and press feedback are fixed
/// per `DKControlSize` so buttons align across panels and toolbars.
public struct DKButton: View {
    private let title: String
    private let symbol: String?
    private let variant: DKButtonVariant
    private let size: DKControlSize
    private let fullWidth: Bool
    private let isLoading: Bool
    private let action: () -> Void

    @State private var hovering = false

    public init(
        _ title: String,
        systemImage: String? = nil,
        variant: DKButtonVariant = .primary,
        size: DKControlSize = .regular,
        fullWidth: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = systemImage
        self.variant = variant
        self.size = size
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DKSpacing.x6) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: size.iconSize, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                    .lineLimit(1)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
        }
        .buttonStyle(
            DKButtonStyle(
                variant: variant,
                size: size,
                hovering: hovering
            )
        )
        .onHover { inside in
            withAnimation(DKMotion.quick) {
                hovering = inside
            }
        }
        .accessibilityLabel(Text(title))
    }
}

struct DKButtonStyle: ButtonStyle {
    let variant: DKButtonVariant
    let size: DKControlSize
    let hovering: Bool

    func makeBody(configuration: Configuration) -> some View {
        DKButtonChrome(
            configuration: configuration,
            variant: variant,
            size: size,
            hovering: hovering
        )
    }
}

private struct DKButtonChrome: View {
    @DKThemeValue private var theme
    @Environment(\.isEnabled) private var isEnabled

    let configuration: ButtonStyleConfiguration
    let variant: DKButtonVariant
    let size: DKControlSize
    let hovering: Bool

    var body: some View {
        let pressed = configuration.isPressed
        let height = variant == .link ? CGFloat(24) : size.height

        configuration.label
            .foregroundStyle(foreground)
            .padding(.horizontal, variant == .link ? 2 : size.horizontalPadding)
            .frame(height: height)
            .background(fill(pressed: pressed))
            .clipShape(Capsule())
            .overlay(stroke)
            .shadow(
                color: variant == .primary ? theme.brand.primary.opacity(pressed ? 0.16 : 0.28) : .clear,
                radius: pressed ? 6 : 12,
                x: 0,
                y: pressed ? 3 : 6
            )
            .scaleEffect(pressed ? 0.975 : (hovering ? 1.012 : 1))
            .opacity(isEnabled ? 1 : 0.45)
            .animation(DKMotion.quick, value: pressed)
            .animation(DKMotion.quick, value: hovering)
            .contentShape(Capsule())
    }

    private var foreground: Color {
        switch variant {
        case .primary: return .white
        case .secondary: return theme.textPrimary
        case .tonal, .link: return theme.primary
        case .ghost: return theme.textSecondary
        case .destructive: return theme.danger
        }
    }

    @ViewBuilder private func fill(pressed: Bool) -> some View {
        switch variant {
        case .primary:
            Capsule().fill(theme.primaryGradient)
        case .secondary:
            Capsule().fill(hovering ? theme.surfaceHigh : theme.surface)
        case .tonal:
            Capsule().fill(theme.primaryContainer.opacity(hovering ? 1 : 0.72))
        case .ghost:
            Capsule().fill(hovering || pressed ? theme.surfaceLow : .clear)
        case .destructive:
            Capsule().fill(theme.danger.opacity(hovering || pressed ? 0.16 : 0.09))
        case .link:
            Color.clear
        }
    }

    @ViewBuilder private var stroke: some View {
        switch variant {
        case .primary:
            Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
        case .secondary:
            Capsule().strokeBorder(hovering ? theme.outlineStrong : theme.outline, lineWidth: 1)
        case .tonal:
            Capsule().strokeBorder(theme.primary.opacity(0.18), lineWidth: 1)
        case .ghost:
            Capsule().strokeBorder(hovering ? theme.outlineStrong : theme.outline, lineWidth: 1)
        case .destructive:
            Capsule().strokeBorder(theme.danger.opacity(0.20), lineWidth: 1)
        case .link:
            EmptyView()
        }
    }
}

/// A circular icon button with hover feedback and a native tooltip. The `help`
/// string is also the accessibility label.
public struct DKIconButton: View {
    @DKThemeValue private var theme

    private let symbol: String
    private let help: String
    private let tint: Color?
    private let size: CGFloat
    private let showsBackground: Bool
    private let action: () -> Void

    @State private var hovering = false

    public init(
        systemImage symbol: String,
        help: String,
        tint: Color? = nil,
        size: CGFloat = 34,
        showsBackground: Bool = true,
        action: @escaping () -> Void
    ) {
        self.symbol = symbol
        self.help = help
        self.tint = tint
        self.size = size
        self.showsBackground = showsBackground
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(tint ?? theme.textSecondary)
                .frame(width: size, height: size)
                .background(
                    Circle().fill(backgroundColor)
                )
                .overlay(
                    Circle().strokeBorder(showsBackground ? theme.outline : .clear, lineWidth: 1)
                )
                .scaleEffect(hovering ? 1.06 : 1)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { inside in
            withAnimation(DKMotion.quick) {
                hovering = inside
            }
        }
        .help(help)
        .accessibilityLabel(Text(help))
    }

    private var backgroundColor: Color {
        if let tint {
            return tint.opacity(hovering ? 0.16 : 0.09)
        }
        if !showsBackground {
            return hovering ? theme.surfaceLow : .clear
        }
        return hovering ? theme.surfaceHigh : theme.surfaceLow
    }
}
