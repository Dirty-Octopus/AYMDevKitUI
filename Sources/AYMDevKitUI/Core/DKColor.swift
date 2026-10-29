import SwiftUI
import AppKit

// MARK: - Hex initialisers

public extension Color {
    /// Creates an sRGB colour from a `0xRRGGBB` literal.
    init(dkHex hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// `#RRGGBB`, plus the alpha percentage when the colour is translucent.
    /// Useful for documentation, token tables and the component gallery.
    var hexDescription: String {
        guard let ns = NSColor(self).usingColorSpace(.sRGB) else { return "—" }
        let red = Int((ns.redComponent * 255).rounded())
        let green = Int((ns.greenComponent * 255).rounded())
        let blue = Int((ns.blueComponent * 255).rounded())
        let alpha = ns.alphaComponent
        if alpha < 0.999 {
            return String(
                format: "#%02X%02X%02X · %d%%",
                red, green, blue, Int((alpha * 100).rounded())
            )
        }
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

internal extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(dkHex: hex, opacity: opacity)
    }
}

// MARK: - Colour maths

/// Small, dependency-free colour maths used to derive a coherent token set from
/// a handful of brand colours. Everything is done in sRGB so results are stable
/// across appearances.
enum DKColorMath {
    struct RGBA: Equatable {
        var r: Double
        var g: Double
        var b: Double
        var a: Double
    }

    static func components(_ color: Color) -> RGBA {
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? .black
        return RGBA(
            r: Double(ns.redComponent),
            g: Double(ns.greenComponent),
            b: Double(ns.blueComponent),
            a: Double(ns.alphaComponent)
        )
    }

    static func color(_ rgba: RGBA) -> Color {
        Color(
            .sRGB,
            red: clamp(rgba.r),
            green: clamp(rgba.g),
            blue: clamp(rgba.b),
            opacity: clamp(rgba.a)
        )
    }

    static func mix(_ a: Color, _ b: Color, ratio: Double) -> Color {
        let t = clamp(ratio)
        let x = components(a)
        let y = components(b)
        return color(
            RGBA(
                r: x.r + (y.r - x.r) * t,
                g: x.g + (y.g - x.g) * t,
                b: x.b + (y.b - x.b) * t,
                a: x.a + (y.a - x.a) * t
            )
        )
    }

    static func lighten(_ color: Color, by ratio: Double) -> Color {
        mix(color, .white, ratio: ratio)
    }

    static func darken(_ color: Color, by ratio: Double) -> Color {
        mix(color, .black, ratio: ratio)
    }

    static func relativeLuminance(_ color: Color) -> Double {
        let c = components(color)
        func channel(_ value: Double) -> Double {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b)
    }

    /// WCAG 2.1 contrast ratio between two opaque colours, from 1 to 21.
    static func contrastRatio(_ a: Color, _ b: Color) -> Double {
        let la = relativeLuminance(a)
        let lb = relativeLuminance(b)
        let lighter = max(la, lb)
        let darker = min(la, lb)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Pushes `color` towards white or black until it has at least `target`
    /// contrast against `background`. Brand colours stay recognisable because
    /// the adjustment is the smallest one that clears the bar.
    static func ensureContrast(
        _ color: Color,
        on background: Color,
        target: Double = 4.5
    ) -> Color {
        if contrastRatio(color, background) >= target { return color }

        let bg = relativeLuminance(background)
        let towardsWhite = bg < 0.5
        let goal: Color = towardsWhite ? .white : .black
        var best = color
        for step in 1...20 {
            let candidate = mix(color, goal, ratio: Double(step) / 20)
            best = candidate
            if contrastRatio(candidate, background) >= target { return candidate }
        }
        return best
    }

    /// Returns a colour that is either a tint or a shade of `color`, whichever
    /// sits closer to the original while remaining readable.
    static func readableTint(
        _ color: Color,
        on background: Color,
        target: Double = 4.5
    ) -> Color {
        let bg = relativeLuminance(background)
        let preferred: Color = bg < 0.5 ? .white : .black
        var best = color
        for step in 1...20 {
            let candidate = mix(color, preferred, ratio: Double(step) / 20)
            best = candidate
            if contrastRatio(candidate, background) >= target { return candidate }
        }
        return best
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

// MARK: - WCAG helpers for previews and tests

public enum DKContrast {
    /// WCAG contrast ratio between two colours, using the same maths the theme
    /// uses internally. Exposed for auditing a palette before shipping.
    public static func ratio(_ foreground: Color, _ background: Color) -> Double {
        DKColorMath.contrastRatio(foreground, background)
    }

    /// `true` when the pair reaches WCAG AA for normal text.
    public static func passesAA(_ foreground: Color, on background: Color) -> Bool {
        ratio(foreground, background) >= 4.5
    }

    /// `true` when the pair reaches WCAG AA for large text and UI graphics.
    public static func passesLargeAA(_ foreground: Color, on background: Color) -> Bool {
        ratio(foreground, background) >= 3.0
    }
}
