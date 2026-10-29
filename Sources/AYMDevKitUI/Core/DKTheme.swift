import SwiftUI

/// Semantic colour roles. Apps map their own domain states onto these rather
/// than inventing new colours, which is what keeps badges, notices and toasts
/// consistent across every DevKit app.
public enum DKTone: String, CaseIterable, Hashable, Identifiable {
    case accent
    case success
    case warning
    case danger
    case info
    case neutral

    public var id: String { rawValue }
}

/// Resolved, appearance-aware design tokens.
///
/// `DKTheme` is derived from a `DKBrand` and the current `ColorScheme`. Views
/// read it through `@DKThemeValue` so nothing has to be injected manually.
public struct DKTheme {
    public let brand: DKBrand
    public let scheme: ColorScheme

    public init(scheme: ColorScheme, brand: DKBrand = .default) {
        self.scheme = scheme
        self.brand = brand
    }

    public var isDark: Bool { scheme == .dark }

    // MARK: - Surfaces

    /// The window background, slightly tinted by the brand.
    public var canvas: Color {
        isDark
            ? DKColorMath.mix(brand.darkBase, brand.primary, ratio: 0.045)
            : DKColorMath.mix(brand.lightBase, brand.primary, ratio: 0.035)
    }

    /// Primary card surface.
    public var surface: Color {
        isDark
            ? DKColorMath.mix(brand.darkBase, .white, ratio: 0.045)
            : .white
    }

    /// Recessed surface for inset rows and secondary blocks.
    public var surfaceLow: Color {
        isDark
            ? DKColorMath.mix(brand.darkBase, brand.primary, ratio: 0.11)
            : DKColorMath.mix(.white, brand.primary, ratio: 0.055)
    }

    /// Stronger recessed surface for switches, pills and selected rows.
    public var surfaceHigh: Color {
        isDark
            ? DKColorMath.mix(brand.darkBase, brand.primary, ratio: 0.17)
            : DKColorMath.mix(.white, brand.primary, ratio: 0.10)
    }

    public var outline: Color {
        isDark ? Color.white.opacity(0.10) : Color(hex: 0x2E2540, opacity: 0.09)
    }

    public var outlineStrong: Color {
        isDark ? Color.white.opacity(0.18) : Color(hex: 0x2E2540, opacity: 0.15)
    }

    // MARK: - Text

    public var textPrimary: Color {
        isDark ? Color(hex: 0xF9F5FF) : Color(hex: 0x1A1424)
    }

    public var textSecondary: Color {
        isDark ? Color(hex: 0xC6BBD6) : Color(hex: 0x574E66)
    }

    /// Small print. Kept at >= 4.5:1 contrast on `surface` in both modes.
    public var textTertiary: Color {
        isDark ? Color(hex: 0xA69AB8) : Color(hex: 0x6E647D)
    }

    public var textDisabled: Color {
        textTertiary.opacity(0.55)
    }

    // MARK: - Accent

    /// Vivid accent for fills and gradients. Never use for small text on
    /// light surfaces — use `primary` instead.
    public var accentFill: Color { brand.primary }

    /// Readable accent for text, icons and strokes on the current surface.
    public var primary: Color {
        DKColorMath.ensureContrast(
            isDark ? brand.primarySoft : brand.primary,
            on: surface,
            target: 4.5
        )
    }

    public var primaryContainer: Color {
        isDark
            ? DKColorMath.mix(surface, brand.primary, ratio: 0.26)
            : DKColorMath.mix(.white, brand.primary, ratio: 0.12)
    }

    public var onPrimaryContainer: Color {
        DKColorMath.ensureContrast(
            isDark ? brand.primarySoft : brand.primaryDeep,
            on: primaryContainer,
            target: 4.5
        )
    }

    public var secondary: Color {
        DKColorMath.ensureContrast(
            isDark ? DKColorMath.lighten(brand.secondary, by: 0.15) : brand.secondary,
            on: surface,
            target: 4.5
        )
    }

    public var secondaryFill: Color { brand.secondary }

    public var secondaryContainer: Color {
        isDark
            ? DKColorMath.mix(surface, brand.secondary, ratio: 0.24)
            : DKColorMath.mix(.white, brand.secondary, ratio: 0.13)
    }

    // MARK: - Semantic

    public var success: Color { semantic(brand.success) }
    public var warning: Color { semantic(brand.warning) }
    public var danger: Color { semantic(brand.danger) }
    public var info: Color { semantic(brand.info) }

    public var successFill: Color { brand.success }
    public var warningFill: Color { brand.warning }
    public var dangerFill: Color { brand.danger }
    public var infoFill: Color { brand.info }

    private func semantic(_ color: Color) -> Color {
        DKColorMath.ensureContrast(color, on: surface, target: 4.5)
    }

    public func color(for tone: DKTone) -> Color {
        switch tone {
        case .accent: return primary
        case .success: return success
        case .warning: return warning
        case .danger: return danger
        case .info: return info
        case .neutral: return textSecondary
        }
    }

    public func fill(for tone: DKTone) -> Color {
        switch tone {
        case .accent: return accentFill
        case .success: return successFill
        case .warning: return warningFill
        case .danger: return dangerFill
        case .info: return infoFill
        case .neutral: return textSecondary
        }
    }

    /// Tinted background used by badges, notices and icon orbs.
    public func tint(for tone: DKTone, strength: Double? = nil) -> Color {
        let base = fill(for: tone)
        let opacity = strength ?? (isDark ? 0.16 : 0.10)
        return base.opacity(opacity)
    }

    // MARK: - Effects

    public var shadow: Color {
        isDark
            ? Color.black.opacity(0.42)
            : DKColorMath.mix(brand.primaryDeep, .black, ratio: 0.55).opacity(0.14)
    }

    public var shadowSoft: Color {
        isDark ? Color.black.opacity(0.30) : shadow.opacity(0.55)
    }

    public var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [DKColorMath.mix(brand.primary, .white, ratio: 0.06), brand.primaryDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public var expressiveGradient: LinearGradient {
        LinearGradient(
            colors: [
                brand.primary,
                DKColorMath.mix(brand.primary, brand.secondary, ratio: 0.55),
                brand.secondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public var softGradient: LinearGradient {
        LinearGradient(
            colors: isDark
                ? [DKColorMath.mix(surface, brand.primary, ratio: 0.12), brand.darkBase]
                : [DKColorMath.mix(.white, brand.primary, ratio: 0.06), .white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Metrics helpers

    public var hairlineWidth: CGFloat { 1 }
    public var cardRadius: CGFloat { DKRadius.xxl }
    public var panelRadius: CGFloat { DKRadius.hero }
}

// MARK: - Environment

@propertyWrapper
public struct DKThemeValue: DynamicProperty {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dkBrand) private var brand

    public init() {}

    public var wrappedValue: DKTheme {
        DKTheme(scheme: colorScheme, brand: brand)
    }
}

private struct DKBrandKey: EnvironmentKey {
    static let defaultValue: DKBrand = .default
}

public extension EnvironmentValues {
    var dkBrand: DKBrand {
        get { self[DKBrandKey.self] }
        set { self[DKBrandKey.self] = newValue }
    }
}

public extension View {
    /// Selects the brand used by every DevKit component in this subtree.
    func dkBrand(_ brand: DKBrand) -> some View {
        environment(\.dkBrand, brand)
    }
}
