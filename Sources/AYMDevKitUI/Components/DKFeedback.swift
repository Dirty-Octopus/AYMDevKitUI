import SwiftUI

/// Inline, non-blocking message. Notices are the only feedback surface that can
/// appear inside a card; blocking problems belong in a dedicated panel.
public struct DKNotice: View {
    @DKThemeValue private var theme

    private let tone: DKTone
    private let title: String?
    private let message: String
    private let symbol: String?
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        _ message: String,
        title: String? = nil,
        tone: DKTone = .info,
        systemImage: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.title = title
        self.tone = tone
        self.symbol = systemImage ?? Self.defaultSymbol(for: tone)
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DKSpacing.x10) {
            Image(systemName: symbol ?? "info.circle.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.color(for: tone))
                .frame(width: 24, height: 24)
                .background(Circle().fill(theme.color(for: tone).opacity(0.12)))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                if let title {
                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                }
                Text(message)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let actionTitle, let action {
                DKButton(actionTitle, variant: .link, size: .small, action: action)
            }
        }
        .padding(DKSpacing.x12)
        .background(
            RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous)
                .fill(theme.tint(for: tone, strength: theme.isDark ? 0.10 : 0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous)
                .strokeBorder(theme.color(for: tone).opacity(0.16), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private static func defaultSymbol(for tone: DKTone) -> String {
        switch tone {
        case .accent: return "sparkles"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.octagon.fill"
        case .info: return "info.circle.fill"
        case .neutral: return "circle.dashed"
        }
    }
}

public struct DKProgressBar: View {
    @DKThemeValue private var theme

    private let value: Double
    private let tone: DKTone
    private let height: CGFloat

    public init(value: Double, tone: DKTone = .accent, height: CGFloat = 6) {
        self.value = value
        self.tone = tone
        self.height = height
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.surfaceHigh)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.fill(for: tone).opacity(0.82),
                                theme.fill(for: tone)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: proxy.size.width * clamped)
            }
        }
        .frame(height: height)
        .animation(DKMotion.standard, value: clamped)
        .accessibilityElement(children: .ignore)
        .accessibilityValue(Text("\(Int(clamped * 100))%"))
    }

    private var clamped: Double {
        min(max(value, 0), 1)
    }
}

public struct DKProgressRing: View {
    @DKThemeValue private var theme

    private let value: Double
    private let tone: DKTone
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let showsLabel: Bool

    public init(
        value: Double,
        tone: DKTone = .accent,
        size: CGFloat = 74,
        lineWidth: CGFloat = 6,
        showsLabel: Bool = true
    ) {
        self.value = value
        self.tone = tone
        self.size = size
        self.lineWidth = lineWidth
        self.showsLabel = showsLabel
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(theme.surfaceHigh, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, clamped))
                .stroke(
                    AngularGradient(
                        colors: [
                            theme.fill(for: tone).opacity(0.7),
                            theme.fill(for: tone),
                            theme.fill(for: tone).opacity(0.7)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(DKMotion.standard, value: clamped)

            if showsLabel {
                Text("\(Int(clamped * 100))%")
                    .font(.system(size: size * 0.22, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                    .monospacedDigit()
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityValue(Text("\(Int(clamped * 100))%"))
    }

    private var clamped: Double {
        min(max(value, 0), 1)
    }
}

/// Empty-state block used when a list has no rows. The copy explains what will
/// appear and offers exactly one next action.
public struct DKEmptyState: View {
    @DKThemeValue private var theme

    private let symbol: String
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        title: String,
        message: String? = nil,
        systemImage: String = "tray",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.symbol = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DKSpacing.x14) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(theme.primary)
                .frame(width: 56, height: 56)
                .background(Circle().fill(theme.primaryContainer))
                .overlay(Circle().strokeBorder(theme.primary.opacity(0.14), lineWidth: 1))

            VStack(spacing: DKSpacing.x4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                if let message {
                    Text(message)
                        .font(.system(size: 11.5, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textTertiary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let actionTitle, let action {
                DKButton(actionTitle, variant: .tonal, size: .small, action: action)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DKSpacing.x24)
        .padding(.horizontal, DKSpacing.x16)
        .accessibilityElement(children: .combine)
    }
}

/// Small spinner with a label, used while a surface loads its first payload.
public struct DKSpinner: View {
    @DKThemeValue private var theme

    private let label: String?

    public init(_ label: String? = nil) {
        self.label = label
    }

    public var body: some View {
        HStack(spacing: DKSpacing.x8) {
            ProgressView()
                .controlSize(.small)
            if let label {
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
