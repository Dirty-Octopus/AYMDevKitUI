import SwiftUI

/// The raw colour identity of an app.
///
/// A brand is deliberately small: a primary, a supporting colour, four semantic
/// hues and two neutral bases. Everything else — surfaces, containers, outlines,
/// readable text tints, gradients — is derived by `DKTheme`, which is what keeps
/// every app built with DevKit visually related.
public struct DKBrand {
    public var name: String

    /// Vivid, saturated colour used for fills, gradients and the app mark.
    public var primary: Color
    /// Darker companion used for gradient ends and pressed states.
    public var primaryDeep: Color
    /// Lighter companion used for dark-mode readable tints.
    public var primarySoft: Color

    /// Supporting colour. Used sparingly for expressive gradients and highlights.
    public var secondary: Color
    public var secondaryDeep: Color

    public var success: Color
    public var warning: Color
    public var danger: Color
    public var info: Color

    /// Base neutrals the surfaces are mixed from.
    public var lightBase: Color
    public var darkBase: Color

    public init(
        name: String,
        primary: Color,
        primaryDeep: Color,
        primarySoft: Color,
        secondary: Color,
        secondaryDeep: Color,
        success: Color,
        warning: Color,
        danger: Color,
        info: Color,
        lightBase: Color = Color(dkHex: 0xFAF7FD),
        darkBase: Color = Color(dkHex: 0x17131D)
    ) {
        self.name = name
        self.primary = primary
        self.primaryDeep = primaryDeep
        self.primarySoft = primarySoft
        self.secondary = secondary
        self.secondaryDeep = secondaryDeep
        self.success = success
        self.warning = warning
        self.danger = danger
        self.info = info
        self.lightBase = lightBase
        self.darkBase = darkBase
    }

    // MARK: - Presets

    /// The default DevKit identity: Seal's violet / coral / mint language.
    public static let aurora = DKBrand(
        name: "Aurora",
        primary: Color(hex: 0x6B4DFF),
        primaryDeep: Color(hex: 0x4A2BD6),
        primarySoft: Color(hex: 0xB9A7FF),
        secondary: Color(hex: 0xFF6B7A),
        secondaryDeep: Color(hex: 0xE1465B),
        success: Color(hex: 0x00B894),
        warning: Color(hex: 0xF3A712),
        danger: Color(hex: 0xEF4B63),
        info: Color(hex: 0x4D9BFF)
    )

    /// Cool alternative for tools that should not read as "Seal".
    public static let ocean = DKBrand(
        name: "Ocean",
        primary: Color(hex: 0x1E7BE0),
        primaryDeep: Color(hex: 0x1259A8),
        primarySoft: Color(hex: 0x8EC2FF),
        secondary: Color(hex: 0x00B8A9),
        secondaryDeep: Color(hex: 0x00877C),
        success: Color(hex: 0x00A884),
        warning: Color(hex: 0xE59A00),
        danger: Color(hex: 0xE5484D),
        info: Color(hex: 0x3B82F6)
    )

    /// A quiet, nearly monochrome identity for utilities.
    public static let graphite = DKBrand(
        name: "Graphite",
        primary: Color(hex: 0x4F5566),
        primaryDeep: Color(hex: 0x333846),
        primarySoft: Color(hex: 0xB4BAC8),
        secondary: Color(hex: 0x8B5CF6),
        secondaryDeep: Color(hex: 0x6D3FF0),
        success: Color(hex: 0x0F9D78),
        warning: Color(hex: 0xD99100),
        danger: Color(hex: 0xE5484D),
        info: Color(hex: 0x3B82F6),
        lightBase: Color(hex: 0xF7F7F9),
        darkBase: Color(hex: 0x141519)
    )

    public static let `default` = DKBrand.aurora
}
