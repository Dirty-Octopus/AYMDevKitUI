import SwiftUI

/// 4pt spacing grid. Components only use these steps so vertical rhythm is
/// identical in every panel and card.
public enum DKSpacing {
    public static let x2: CGFloat = 2
    public static let x4: CGFloat = 4
    public static let x6: CGFloat = 6
    public static let x8: CGFloat = 8
    public static let x10: CGFloat = 10
    public static let x12: CGFloat = 12
    public static let x14: CGFloat = 14
    public static let x16: CGFloat = 16
    public static let x18: CGFloat = 18
    public static let x20: CGFloat = 20
    public static let x24: CGFloat = 24
    public static let x28: CGFloat = 28
    public static let x32: CGFloat = 32
    public static let x36: CGFloat = 36
    public static let x40: CGFloat = 40
    public static let x48: CGFloat = 48
    public static let x56: CGFloat = 56
    public static let x64: CGFloat = 64
}

/// Corner radius scale. The larger steps are used for cards and panels; control
/// surfaces use pills and small radii only.
public enum DKRadius {
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 20
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 28
    public static let hero: CGFloat = 36
    public static let pill: CGFloat = 999
}

/// Interaction sizes shared by buttons, icon buttons and form rows.
public enum DKControlSize: String, CaseIterable, Identifiable {
    case small
    case regular
    case large

    public var id: String { rawValue }

    public var height: CGFloat {
        switch self {
        case .small: return 32
        case .regular: return 42
        case .large: return 48
        }
    }

    public var fontSize: CGFloat {
        switch self {
        case .small: return 12.5
        case .regular: return 14
        case .large: return 15
        }
    }

    public var horizontalPadding: CGFloat {
        switch self {
        case .small: return 12
        case .regular: return 18
        case .large: return 22
        }
    }

    public var iconSize: CGFloat {
        switch self {
        case .small: return 11
        case .regular: return 13
        case .large: return 14
        }
    }

    public var controlRadius: CGFloat {
        switch self {
        case .small: return 10
        case .regular: return 12
        case .large: return 14
        }
    }
}

/// Shadow recipes. Elevation communicates layering, not decoration: only
/// floating cards, sheets and primary actions get more than `low`.
public enum DKElevation {
    case none
    case low
    case medium
    case high

    public func shadow(theme: DKTheme) -> (color: Color, radius: CGFloat, y: CGFloat) {
        switch self {
        case .none:
            return (.clear, 0, 0)
        case .low:
            return (theme.shadowSoft, 8, 3)
        case .medium:
            return (theme.shadow, 16, 8)
        case .high:
            return (theme.shadow, 26, 14)
        }
    }
}

/// Motion is part of the language: quick feedback for input, standard springs
/// for layout changes, emphasized springs for state changes the user initiated.
public enum DKMotion {
    public static let instant = Animation.linear(duration: 0.12)
    public static let quick = Animation.spring(response: 0.24, dampingFraction: 0.86)
    public static let standard = Animation.spring(response: 0.32, dampingFraction: 0.80)
    public static let emphasized = Animation.spring(response: 0.42, dampingFraction: 0.74)
    public static let gentle = Animation.easeInOut(duration: 0.22)

    /// Duration of the library-provided light/dark crossfade. Native AppKit
    /// appearance changes are instant, so DevKit snapshots each visible window
    /// and fades the old frame over the new one.
    public static let appearanceDuration: TimeInterval = 0.34
    /// Duration of in-place window preset changes.
    public static let windowResizeDuration: TimeInterval = 0.26

    /// Returns `nil` when the system asks for reduced motion.
    public static func resolve(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }
}

/// Layout constants that make the welcome and settings panels line up across
/// every app.
public enum DKLayout {
    public static let contentMaxWidth: CGFloat = 1440
    public static let panelWidth: CGFloat = 720
    public static let panelPadding: CGFloat = 26
    public static let cardPadding: CGFloat = 22
    public static let cardPaddingCompact: CGFloat = 16
    public static let minWindowWidth: CGFloat = 1040
    public static let minWindowHeight: CGFloat = 680
    public static let defaultWindowWidth: CGFloat = 1180
    public static let defaultWindowHeight: CGFloat = 820
    public static let topBarLeadingInset: CGFloat = 92
    public static let topBarTrailingInset: CGFloat = 28
    public static let topBarVerticalInset: CGFloat = 18
    public static let heroMarkSize: CGFloat = 92
    public static let headerMarkSize: CGFloat = 36
}

/// Grid help for the option cards used by welcome and settings.
public enum DKGrid {
    public static func columns(_ count: Int, spacing: CGFloat = DKSpacing.x12) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: max(1, count))
    }
}
