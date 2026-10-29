import SwiftUI
import AppKit
import Combine

/// Persisted, app-wide preferences shared by every DevKit surface.
///
/// One instance drives the welcome panel, the settings panel, the menu commands
/// and the window manager. Hosts create it once (usually as a `@StateObject`) and
/// hand it to `DKAppRoot`; the library does the rest.
///
/// All properties persist to `UserDefaults` immediately, so the welcome flow can
/// be completed, the app relaunched, and the chosen language and appearance are
/// already applied on the next launch.
@MainActor
public final class DKAppSettings: ObservableObject {
    /// Convenience instance for apps that only need one settings store. Apps that
    /// need a custom defaults suite should create their own instance.
    public static let shared = DKAppSettings()

    private let defaults: UserDefaults

    /// Bump this string to show the welcome panel again after a redesign.
    public let welcomeVersion: String

    @Published public var language: DKLanguage {
        didSet {
            defaults.set(language.rawValue, forKey: DKDefaultsKey.language)
            DKL10n.language = language
        }
    }

    @Published public var appearance: DKAppearance {
        didSet {
            defaults.set(appearance.rawValue, forKey: DKDefaultsKey.appearance)
            applyAppearance()
        }
    }

    @Published public var windowPreset: DKWindowPreset {
        didSet {
            defaults.set(windowPreset.rawValue, forKey: DKDefaultsKey.windowPreset)
            DKWindowManager.shared.apply(windowPreset)
        }
    }

    /// The welcome version the user last completed. `nil` means "never".
    @Published public private(set) var completedWelcomeVersion: String?

    public var hasCompletedWelcome: Bool {
        completedWelcomeVersion == welcomeVersion
    }

    public init(
        defaults: UserDefaults = .standard,
        welcomeVersion: String = "1",
        applyImmediately: Bool = true
    ) {
        self.defaults = defaults
        self.welcomeVersion = welcomeVersion

        self.language =
            defaults.string(forKey: DKDefaultsKey.language)
                .flatMap(DKLanguage.init(rawValue:))
            ?? .systemDefault
        self.appearance =
            defaults.string(forKey: DKDefaultsKey.appearance)
                .flatMap(DKAppearance.init(rawValue:))
            ?? .system
        self.windowPreset =
            defaults.string(forKey: DKDefaultsKey.windowPreset)
                .flatMap(DKWindowPreset.init(rawValue:))
            ?? .defaultPreset
        self.completedWelcomeVersion = defaults.string(forKey: DKDefaultsKey.welcomeVersion)

        DKL10n.language = language
        if applyImmediately {
            applyAppearance(animated: false)
        }
    }

    /// Applies the initial state to the app and the window. Called by
    /// `DKAppRoot` on appear, and by hosts that manage their own scene.
    public func applyAll() {
        DKL10n.language = language
        applyAppearance(animated: false)
        DKWindowManager.shared.attachCurrentWindowIfAvailable()
        DKWindowManager.shared.apply(windowPreset)
    }

    /// Applies the current appearance. Animated changes use the library
    /// crossfade; the initial launch applies instantly.
    public func applyAppearance(animated: Bool = true) {
        if animated {
            DKAppearanceTransition.apply(appearance)
        } else {
            appearance.apply()
        }
    }

    /// Marks the current welcome version as completed. Idempotent.
    public func completeWelcome() {
        completedWelcomeVersion = welcomeVersion
        defaults.set(welcomeVersion, forKey: DKDefaultsKey.welcomeVersion)
        defaults.set(true, forKey: DKDefaultsKey.welcomeCompleted)
    }

    /// Shows the welcome panel again on the next render. Settings are untouched.
    public func resetWelcome() {
        completedWelcomeVersion = nil
        defaults.removeObject(forKey: DKDefaultsKey.welcomeVersion)
        defaults.set(false, forKey: DKDefaultsKey.welcomeCompleted)
    }
}
