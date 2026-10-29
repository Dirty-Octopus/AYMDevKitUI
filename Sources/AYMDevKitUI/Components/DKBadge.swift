import SwiftUI

public enum DKBadgeStyle {
    /// Tinted background with a readable tone-coloured label. The default.
    case tinted
    /// Solid tone background with contrast-checked text.
    case solid
    /// Transparent background with a tone-coloured outline.
    case outline
}

/// A compact status label. Badges never wrap; long text should become a notice
/// or a caption instead.
public struct DKBadge: View {
    @DKThemeValue private var theme

    private let text: String
    private let symbol: String?
    private let tone: DKTone
    private let style: DKBadgeStyle
    private let compact: Bool

    public init(
        _ text: String,
        systemImage: String? = nil,
        tone: DKTone = .accent,
        style: DKBadgeStyle = .tinted,
        compact: Bool = false
    ) {
        self.text = text
        self.symbol = systemImage
        self.tone = tone
        self.style = style
        self.compact = compact
    }

    public var body: some View {
        HStack(spacing: compact ? 4 : 5) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: compact ? 8.5 : 10, weight: .bold))
            }
            Text(text)
                .font(.system(size: compact ? 9.5 : 10.5, weight: .bold, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 3.5 : 4.5)
        .background(background)
        .clipShape(Capsule())
        .overlay(outline)
        .accessibilityElement(children: .combine)
    }

    private var toneColor: Color {
        theme.color(for: tone)
    }

    private var foreground: Color {
        switch style {
        case .tinted, .outline:
            return toneColor
        case .solid:
            return DKColorMath.ensureContrast(.white, on: theme.fill(for: tone), target: 4.5)
        }
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .tinted:
            Capsule().fill(theme.tint(for: tone))
        case .solid:
            Capsule().fill(theme.fill(for: tone))
        case .outline:
            Capsule().fill(theme.surface.opacity(0.6))
        }
    }

    @ViewBuilder private var outline: some View {
        switch style {
        case .tinted:
            Capsule().strokeBorder(toneColor.opacity(0.14), lineWidth: 1)
        case .solid:
            Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
        case .outline:
            Capsule().strokeBorder(toneColor.opacity(0.42), lineWidth: 1)
        }
    }
}

/// A small filled dot for dense status rows.
public struct DKStatusDot: View {
    @DKThemeValue private var theme

    private let tone: DKTone
    private let size: CGFloat

    public init(tone: DKTone = .success, size: CGFloat = 8) {
        self.tone = tone
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(theme.color(for: tone))
            .frame(width: size, height: size)
            .overlay(
                Circle().strokeBorder(theme.color(for: tone).opacity(0.18), lineWidth: size * 0.5)
            )
            .accessibilityHidden(true)
    }
}

/// A pulsing dot used for "live", "recording" and "connected" states. The pulse
/// stops when Reduce Motion is enabled.
public struct DKLiveDot: View {
    @DKThemeValue private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let tone: DKTone
    private let size: CGFloat

    @State private var pulse = false

    public init(tone: DKTone = .success, size: CGFloat = 8) {
        self.tone = tone
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(theme.color(for: tone).opacity(0.18))
                .frame(width: size * 2.2, height: size * 2.2)
                .scaleEffect(pulse ? 1.45 : 0.75)
                .opacity(pulse ? 0 : 1)
            Circle()
                .fill(theme.color(for: tone))
                .frame(width: size, height: size)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 2.2).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
        .accessibilityHidden(true)
    }
}
