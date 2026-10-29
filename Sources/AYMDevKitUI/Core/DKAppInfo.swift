import Foundation
import SwiftUI

/// Static identity of the app that adopts DevKit.
///
/// The welcome panel, settings panel and top bar all read from this value, so an
/// app only declares its identity once. Everything else — copy, spacing, window
/// chrome — is provided by the library.
public struct DKAppInfo {
    /// Display name, e.g. `Seal`.
    public var name: String
    /// One-line description shown under the name in the top bar.
    public var tagline: String
    /// Marketing version, e.g. `1.4.0`.
    public var version: String
    /// Bundle build number, when the bundle declares one.
    public var build: String?
    public var bundleIdentifier: String
    public var copyright: String
    public var license: String
    public var website: URL?
    public var repository: URL?
    public var support: URL?
    /// App mark used by the welcome panel, settings header and top bar.
    public var mark: DKMark

    public init(
        name: String,
        tagline: String = "",
        version: String = "1.0.0",
        build: String? = nil,
        bundleIdentifier: String = "app.aymdevkit.unknown",
        copyright: String? = nil,
        license: String = "MIT License",
        website: URL? = nil,
        repository: URL? = nil,
        support: URL? = nil,
        mark: DKMark = .automatic
    ) {
        self.name = name
        self.tagline = tagline
        self.version = version
        self.build = build
        self.bundleIdentifier = bundleIdentifier
        self.license = license
        self.website = website
        self.repository = repository
        self.support = support
        self.mark = mark
        self.copyright = copyright ?? Self.defaultCopyright(for: name)
    }

    /// Reads the identity from a bundle. Missing keys fall back to safe values so
    /// a command-line build or a test bundle never renders empty chrome.
    public static func current(bundle: Bundle = .main) -> DKAppInfo {
        let dictionary = bundle.infoDictionary ?? [:]
        let name =
            dictionary["CFBundleDisplayName"] as? String
            ?? dictionary["CFBundleName"] as? String
            ?? "App"
        let version = dictionary["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = dictionary["CFBundleVersion"] as? String
        let identifier = bundle.bundleIdentifier ?? "app.aymdevkit.unknown"
        let copyright = dictionary["NSHumanReadableCopyright"] as? String
        return DKAppInfo(
            name: name,
            version: version,
            build: build,
            bundleIdentifier: identifier,
            copyright: copyright,
            mark: .automatic
        )
    }

    /// The identity of the running app.
    public static var current: DKAppInfo { current() }

    /// Stable identity for previews, tests and documentation snapshots.
    public static let placeholder = DKAppInfo(
        name: "AYMDevKitUI",
        tagline: "Andy Yu's macOS Development Kit for UI",
        version: "1.0.0",
        build: "1",
        bundleIdentifier: "app.aymdevkit.placeholder",
        copyright: "© AYMDevKitUI",
        license: "MIT License",
        mark: .monogram("DK")
    )

    private static func defaultCopyright(for name: String) -> String {
        let year = Calendar(identifier: .gregorian).component(.year, from: Date())
        return "© \(year) \(name)"
    }
}

/// Identity of the library itself, shown in the welcome footer and about
/// section. Kept separate from `DKAppInfo` so adopting apps keep their own name.
public enum DKFrameworkInfo {
    public static let name = "AYMDevKitUI"
    public static let shortName = "AYMDKUI"
    public static let tagline = "Andy Yu's macOS Development Kit for UI"
    public static let version = "1.0.0"
}

public extension DKAppInfo {
    /// `1.4.0 (42)` when a build number exists, otherwise just the version.
    var versionText: String {
        guard let build, !build.isEmpty else { return version }
        return "\(version) (\(build))"
    }

    /// `AYMDevKitUI 1.4.0` — used by the settings header.
    var nameAndVersion: String {
        "\(name) \(versionText)"
    }
}
