import SwiftUI

/// The primary raised surface. Cards are the only container that casts a real
/// shadow; nesting cards is discouraged.
public struct DKCard<Content: View>: View {
    @DKThemeValue private var theme

    private let padding: CGFloat
    private let radius: CGFloat
    private let elevation: DKElevation
    private let tint: Color?
    private let content: Content

    public init(
        padding: CGFloat = DKLayout.cardPadding,
        radius: CGFloat = DKRadius.xxl,
        elevation: DKElevation = .low,
        tint: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.radius = radius
        self.elevation = elevation
        self.tint = tint
        self.content = content()
    }

    public var body: some View {
        let shadow = elevation.shadow(theme: theme)
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(tint ?? theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(theme.outline, lineWidth: 1)
            )
            .shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}

/// A recessed surface for rows, sidebars and secondary blocks. Never casts a
/// shadow, so it reads as "inside" the parent card.
public struct DKInset<Content: View>: View {
    @DKThemeValue private var theme

    private let padding: CGFloat
    private let radius: CGFloat
    private let content: Content

    public init(
        padding: CGFloat = 14,
        radius: CGFloat = DKRadius.md,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.radius = radius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(theme.surfaceLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(theme.outline, lineWidth: 1)
            )
    }
}

public struct DKHairline: View {
    @DKThemeValue private var theme

    private let vertical: Bool

    public init(vertical: Bool = false) {
        self.vertical = vertical
    }

    public var body: some View {
        Rectangle()
            .fill(theme.outline)
            .frame(width: vertical ? 1 : nil, height: vertical ? nil : 1)
            .accessibilityHidden(true)
    }
}

/// Numbered section header used by the welcome panel. The mono index is part of
/// the framework identity: setup steps always read `01 / 02 / 03`.
public struct DKStepHeader: View {
    @DKThemeValue private var theme

    private let index: String
    private let title: String
    private let subtitle: String?
    private let symbol: String?

    public init(
        index: String,
        title: String,
        subtitle: String? = nil,
        symbol: String? = nil
    ) {
        self.index = index
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DKSpacing.x10) {
            Text("[\(index)]")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.primary)
                .frame(width: 36, alignment: .leading)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    if let symbol {
                        Image(systemName: symbol)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(theme.textTertiary)
                    }
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

/// A dashed ASCII separator. Used sparingly where a hairline would feel too
/// "interface" and the surface should read as ambient code.
public struct DKASCIIRule: View {
    @DKThemeValue private var theme

    private let character: String

    public init(_ character: String = "-") {
        self.character = character
    }

    public var body: some View {
        Text(String(repeating: character, count: 260))
            .font(.system(size: 7.5, weight: .medium, design: .monospaced))
            .tracking(1.4)
            .foregroundStyle(theme.outlineStrong.opacity(0.75))
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityHidden(true)
    }
}

/// Miniature window used by window-size choices in the welcome and settings
/// panels. The silhouette is proportional to the real preset.
public struct DKWindowPreview: View {
    @DKThemeValue private var theme

    private let preset: DKWindowPreset
    private let width: CGFloat

    public init(preset: DKWindowPreset, width: CGFloat = 58) {
        self.preset = preset
        self.width = width
    }

    public var body: some View {
        let ratio = preset.contentSize.height / preset.contentSize.width
        let height = width * ratio

        VStack(alignment: .leading, spacing: height * 0.075) {
            HStack(spacing: width * 0.035) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(theme.textTertiary.opacity(0.45))
                        .frame(width: width * 0.035, height: width * 0.035)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, width * 0.055)
            .padding(.top, height * 0.06)

            HStack(alignment: .top, spacing: width * 0.045) {
                RoundedRectangle(cornerRadius: width * 0.025, style: .continuous)
                    .fill(theme.primary.opacity(0.16))
                    .frame(width: width * 0.24)
                VStack(alignment: .leading, spacing: height * 0.055) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(theme.textTertiary.opacity(0.25))
                        .frame(width: width * 0.42, height: 2)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(theme.outline)
                        .frame(width: width * 0.34, height: 2)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(theme.outline)
                        .frame(width: width * 0.38, height: 2)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, width * 0.055)
            .padding(.bottom, height * 0.08)
        }
        .frame(width: width, height: height, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: width * 0.12, style: .continuous)
                .fill(theme.surfaceLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: width * 0.12, style: .continuous)
                .strokeBorder(theme.outlineStrong, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: width * 0.12, style: .continuous))
        .accessibilityHidden(true)
    }
}

/// The shared app backdrop: brand-tinted canvas, two soft radial washes and a
/// very quiet dot grid. Every DevKit window uses this instead of a flat colour.
public struct DKAppBackground: View {
    @DKThemeValue private var theme

    private let fieldIntensity: Double

    public init(fieldIntensity: Double = 1) {
        self.fieldIntensity = fieldIntensity
    }

    public var body: some View {
        ZStack {
            theme.canvas

            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    theme.brand.primary.opacity(theme.isDark ? 0.30 : 0.17),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 380
                            )
                        )
                        .frame(width: 760, height: 760)
                        .offset(x: proxy.size.width * 0.68, y: -320)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    theme.brand.secondary.opacity(theme.isDark ? 0.18 : 0.12),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 300
                            )
                        )
                        .frame(width: 560, height: 560)
                        .offset(x: -220, y: proxy.size.height - 280)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            }
            .ignoresSafeArea()

            if fieldIntensity > 0 {
                DKASCIIField(intensity: fieldIntensity)
                    .ignoresSafeArea()
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
