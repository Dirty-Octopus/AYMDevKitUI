import SwiftUI
import AppKit

/// The visual identity of an app inside DevKit chrome.
public enum DKMark {
    /// Uses the running app's icon, falling back to a layered-squares symbol.
    case automatic
    /// An SF Symbol rendered in white on the brand gradient.
    case symbol(String)
    /// One or two characters rendered on the brand gradient.
    case monogram(String)
    /// A host-provided image, clipped to the standard rounded-square shape.
    case image(Image)
    /// An asset name resolved from the main bundle.
    case asset(String)
}

public enum DKMarkStyle {
    /// Brand gradient fill with a white glyph. The default for hero marks.
    case gradient
    /// Soft brand container with a brand-coloured glyph. For top bars.
    case tinted
    /// Neutral recessed container. For dense toolbars and rows.
    case plain
}

/// Renders a `DKMark` at a consistent size and corner radius.
public struct DKMarkView: View {
    @DKThemeValue private var theme

    private let mark: DKMark
    private let size: CGFloat
    private let style: DKMarkStyle
    private let showsGlow: Bool

    public init(
        _ mark: DKMark = .automatic,
        size: CGFloat = 36,
        style: DKMarkStyle = .gradient,
        showsGlow: Bool = false
    ) {
        self.mark = mark
        self.size = size
        self.style = style
        self.showsGlow = showsGlow
    }

    public var body: some View {
        content
            .frame(width: size, height: size)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                    .strokeBorder(highlight, lineWidth: 1)
            )
            .shadow(
                color: showsGlow ? theme.brand.primary.opacity(0.32) : .clear,
                radius: showsGlow ? size * 0.24 : 0,
                x: 0,
                y: showsGlow ? size * 0.12 : 0
            )
            .accessibilityHidden(true)
    }

    @ViewBuilder private var content: some View {
        switch resolved {
        case .image(let image):
            image
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: size * 0.44, weight: .bold))
                .foregroundStyle(foreground)
        case .monogram(let text):
            Text(text)
                .font(.system(size: size * monogramSizeRatio(for: text), weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(foreground)
                .padding(.horizontal, size * 0.1)
        }
    }

    private var resolved: ResolvedMark {
        switch mark {
        case .automatic:
            if let icon = NSApplication.shared.applicationIconImage, icon.size.width > 0 {
                return .image(Image(nsImage: icon))
            }
            return .symbol("square.stack.3d.up.fill")
        case .symbol(let name):
            return .symbol(name)
        case .monogram(let text):
            return .monogram(text)
        case .image(let image):
            return .image(image)
        case .asset(let name):
            return .image(Image(name))
        }
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .gradient:
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(theme.primaryGradient)
        case .tinted:
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(theme.primaryContainer)
        case .plain:
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(theme.surfaceLow)
        }
    }

    private var foreground: Color {
        switch style {
        case .gradient: return .white
        case .tinted, .plain: return theme.primary
        }
    }

    private var highlight: Color {
        switch style {
        case .gradient: return Color.white.opacity(0.20)
        case .tinted: return theme.primary.opacity(0.18)
        case .plain: return theme.outline
        }
    }

    private func monogramSizeRatio(for text: String) -> CGFloat {
        text.count <= 1 ? 0.46 : 0.34
    }

    private enum ResolvedMark {
        case image(Image)
        case symbol(String)
        case monogram(String)
    }
}

/// A decorative layered orb used behind the welcome hero and empty states.
public struct DKOrb: View {
    @DKThemeValue private var theme

    private let size: CGFloat

    public init(size: CGFloat = 120) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(theme.softGradient)
                .overlay(Circle().strokeBorder(theme.outline, lineWidth: 1))
            Circle()
                .trim(from: 0.06, to: 0.78)
                .stroke(
                    AngularGradient(
                        colors: [
                            theme.brand.primary.opacity(0.85),
                            theme.brand.secondary.opacity(0.55),
                            theme.brand.primary.opacity(0.15)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(size * 0.08)
            Circle()
                .fill(theme.brand.primary.opacity(theme.isDark ? 0.18 : 0.10))
                .padding(size * 0.26)
        }
        .frame(width: size, height: size)
    }
}
