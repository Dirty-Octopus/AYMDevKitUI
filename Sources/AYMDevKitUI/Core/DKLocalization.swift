import SwiftUI
import Foundation

/// The languages shipped by DevKit. The welcome panel and settings panel use the
/// same list, so adding a language here adds it to both panels.
public enum DKLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    public var id: String { rawValue }

    /// Endonym shown in the picker. Never translated, so users can always find
    /// their own language.
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .simplifiedChinese: return "简体中文"
        }
    }

    /// Two-character badge used by the option cards.
    public var badgeText: String {
        switch self {
        case .english: return "EN"
        case .simplifiedChinese: return "中"
        }
    }

    public var locale: Locale {
        Locale(identifier: rawValue)
    }

    /// Copy describing the choice, resolved from the resource bundle.
    public var subtitleKey: String {
        switch self {
        case .english: return "language.english.subtitle"
        case .simplifiedChinese: return "language.chinese.subtitle"
        }
    }

    /// Best match for the user's system language, falling back to English.
    public static var systemDefault: DKLanguage {
        for preferred in Locale.preferredLanguages {
            let code = preferred.lowercased()
            if code.hasPrefix("zh") { return .simplifiedChinese }
            if code.hasPrefix("en") { return .english }
        }
        return .english
    }
}

/// Resolves library copy against the language selected in `DKAppSettings`.
///
/// Views use `DKL10n.text(_:)` which returns a `Text` resolved by SwiftUI's
/// environment locale. Non-view strings (window titles, accessibility labels in
/// AppKit land) use `DKL10n.t(_:)`.
public enum DKL10n {
    /// Set by `DKAppSettings`. Also mirrored into the environment locale so
    /// SwiftUI's own localisation resolves identically.
    public static var language: DKLanguage = .systemDefault

    public static var locale: Locale { language.locale }

    public static var resourceBundle: Bundle { .module }

    /// The `.lproj` bundle for a specific language, bypassing system locale.
    public static func bundle(for language: DKLanguage) -> Bundle {
        guard
            let path = Bundle.module.path(forResource: language.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .module
        }
        return bundle
    }

    /// Localised string for non-view contexts, formatted with the given args.
    public static func t(_ key: String, _ args: CVarArg...) -> String {
        let format = bundle(for: language).localizedString(forKey: key, value: key, table: nil)
        guard !args.isEmpty else { return format }
        return String(format: format, locale: locale, arguments: args)
    }

    /// Localised `Text` that follows the SwiftUI environment locale.
    public static func text(_ key: String) -> Text {
        Text(LocalizedStringKey(key), bundle: .module)
    }

    /// Localised attributed string for places that need `Text` verbatim.
    public static func verbatim(_ key: String) -> Text {
        Text(verbatim: t(key))
    }
}

public extension Notification.Name {
    /// Posted by the standard DevKit menu command. A host can also listen for it
    /// to present its own settings scene.
    static let dsOpenSettings = Notification.Name("devkit.openSettings")
    static let dsResetWelcome = Notification.Name("devkit.resetWelcome")
}
