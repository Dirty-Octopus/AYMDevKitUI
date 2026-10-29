import XCTest
import SwiftUI
import AYMDevKitUI

@MainActor
final class DesignSystemTests: XCTestCase {
    private let brands: [DKBrand] = [.aurora, .ocean, .graphite]
    private let schemes: [ColorScheme] = [.light, .dark]

    func testBodyAndLabelContrastMeetsWCAGAA() {
        for brand in brands {
            for scheme in schemes {
                let theme = DKTheme(scheme: scheme, brand: brand)
                let context = "\(brand.name)/\(scheme == .dark ? "dark" : "light")"

                XCTAssertGreaterThanOrEqual(
                    DKContrast.ratio(theme.textPrimary, theme.surface),
                    7.0,
                    "Primary text must reach AAA on surfaces (\(context))"
                )
                XCTAssertGreaterThanOrEqual(
                    DKContrast.ratio(theme.textSecondary, theme.surface),
                    4.5,
                    "Secondary text must reach AA (\(context))"
                )
                XCTAssertGreaterThanOrEqual(
                    DKContrast.ratio(theme.textTertiary, theme.surface),
                    4.5,
                    "Tertiary text must reach AA (\(context))"
                )
                XCTAssertGreaterThanOrEqual(
                    DKContrast.ratio(theme.textTertiary, theme.canvas),
                    4.5,
                    "Tertiary text must reach AA on the canvas (\(context))"
                )
                XCTAssertGreaterThanOrEqual(
                    DKContrast.ratio(theme.primary, theme.surface),
                    4.5,
                    "The accent text role must reach AA (\(context))"
                )
                XCTAssertGreaterThanOrEqual(
                    DKContrast.ratio(theme.onPrimaryContainer, theme.primaryContainer),
                    4.5,
                    "Accent-on-container must reach AA (\(context))"
                )

                for tone in DKTone.allCases {
                    XCTAssertGreaterThanOrEqual(
                        DKContrast.ratio(theme.color(for: tone), theme.surface),
                        4.5,
                        "Tone \(tone.rawValue) must reach AA (\(context))"
                    )
                }
            }
        }
    }

    func testThemeIsDerivedFromTheSameBrandLanguage() {
        let light = DKTheme(scheme: .light, brand: .aurora)
        let dark = DKTheme(scheme: .dark, brand: .aurora)

        XCTAssertNotEqual(light.canvas.hexDescription, dark.canvas.hexDescription)
        XCTAssertNotEqual(light.surface.hexDescription, dark.surface.hexDescription)
        XCTAssertEqual(light.brand.name, dark.brand.name)
        XCTAssertEqual(light.brand.primary.hexDescription, dark.brand.primary.hexDescription)
    }

    func testEveryBrandHasDistinctIdentity() {
        XCTAssertEqual(Set(brands.map(\.name)).count, brands.count)
        for brand in brands {
            XCTAssertFalse(brand.name.isEmpty)
            XCTAssertNotEqual(brand.primary.hexDescription, brand.primaryDeep.hexDescription)
            XCTAssertNotEqual(brand.primary.hexDescription, brand.primarySoft.hexDescription)
        }
    }

    func testAppearanceDefaultsToSystem() {
        let suite = "aymdk.tests.appearance.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let settings = DKAppSettings(defaults: defaults, welcomeVersion: "1", applyImmediately: false)
        XCTAssertEqual(settings.appearance, .system)
        XCTAssertNil(settings.appearance.colorScheme)
    }

    func testWindowPresetsAreOrderedAndProportional() {
        XCTAssertLessThan(
            DKWindowPreset.compact.contentSize.width,
            DKWindowPreset.standard.contentSize.width
        )
        XCTAssertLessThan(
            DKWindowPreset.standard.contentSize.width,
            DKWindowPreset.large.contentSize.width
        )
        XCTAssertLessThan(
            DKWindowPreset.compact.contentSize.height,
            DKWindowPreset.large.contentSize.height
        )
        XCTAssertEqual(DKWindowPreset.compact.previewRatio, 1040.0 / 1380.0, accuracy: 0.0001)
        XCTAssertEqual(DKWindowPreset.defaultPreset, .standard)
    }

    func testPerlinNoiseIsDeterministicAndBounded() {
        var values: [Double] = []
        for index in 0..<80 {
            let x = Double(index) * 0.37
            let y = Double(index) * 0.19
            let first = DKNoise.perlin(x, y)
            let second = DKNoise.perlin(x, y)
            XCTAssertEqual(first, second, accuracy: 0.000_000_1)
            XCTAssertGreaterThanOrEqual(first, -1.5)
            XCTAssertLessThanOrEqual(first, 1.5)
            values.append(first)
        }
        XCTAssertGreaterThan(Set(values.map { Int($0 * 1000) }).count, 10)
    }

    func testAmbientRipplesUseNormalisedCoordinates() {
        let ambient = DKAmbient.shared
        ambient.ripples.forEach { _ in }
        let before = ambient.ripples.count
        ambient.spawn(at: CGPoint(x: 50, y: 25), in: CGSize(width: 200, height: 100))
        XCTAssertEqual(ambient.ripples.count, min(before + 1, 8))
        if let last = ambient.ripples.last {
            XCTAssertEqual(last.center.x, 0.25, accuracy: 0.0001)
            XCTAssertEqual(last.center.y, 0.25, accuracy: 0.0001)
        }
    }

    func testLocalizationResourcesCoverEveryKey() {
        let keys = [
            "common.browse", "common.clear", "common.close", "common.copied", "common.copy", "common.search",
            "dropzone.title", "dropzone.subtitle",
            "menu.aboutApp", "menu.appearance", "menu.language", "menu.resetWelcome", "menu.settings", "menu.view",
            "appearance.system", "appearance.system.subtitle",
            "appearance.light", "appearance.light.subtitle",
            "appearance.dark", "appearance.dark.subtitle",
            "window.compact", "window.compact.subtitle",
            "window.standard", "window.standard.subtitle",
            "window.large", "window.large.subtitle",
            "language.english.subtitle", "language.chinese.subtitle",
            "welcome.title", "welcome.subtitle", "welcome.setup.eyebrow", "welcome.setup.title",
            "welcome.language.title", "welcome.language.subtitle",
            "welcome.appearance.title", "welcome.appearance.subtitle",
            "welcome.window.title", "welcome.window.subtitle",
            "welcome.ready.title", "welcome.footnote", "welcome.start",
            "welcome.highlight.1", "welcome.highlight.2", "welcome.highlight.3",
            "settings.title", "settings.language.title", "settings.language.subtitle",
            "settings.appearance.title", "settings.appearance.subtitle",
            "settings.window.title", "settings.window.subtitle",
            "settings.about.title", "settings.about.subtitle",
            "settings.about.version", "settings.about.build", "settings.about.bundle",
            "settings.about.license", "settings.about.website", "settings.about.repository",
            "settings.resetWelcome", "settings.resetWelcome.title", "settings.resetWelcome.subtitle"
        ]

        for language in DKLanguage.allCases {
            let bundle = DKL10n.bundle(for: language)
            for key in keys {
                let value = bundle.localizedString(forKey: key, value: nil, table: nil)
                XCTAssertFalse(value.isEmpty, "\(language.rawValue) is missing \(key)")
                XCTAssertNotEqual(value, key, "\(language.rawValue) falls back for \(key)")
            }
        }
    }

    func testLanguageFormatsAreStable() {
        let previous = DKL10n.language
        defer { DKL10n.language = previous }

        DKL10n.language = .english
        XCTAssertEqual(DKL10n.t("welcome.start"), "Get started")
        XCTAssertTrue(DKL10n.t("menu.aboutApp", "Demo").contains("Demo"))

        DKL10n.language = .simplifiedChinese
        XCTAssertEqual(DKL10n.t("welcome.start"), "开始使用")
        XCTAssertEqual(DKL10n.t("appearance.dark"), "深色")
    }

    func testWelcomeLifecyclePersistsAndVersions() {
        let suite = "aymdk.tests.settings.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let settings = DKAppSettings(defaults: defaults, welcomeVersion: "2", applyImmediately: false)
        XCTAssertFalse(settings.hasCompletedWelcome)

        settings.completeWelcome()
        XCTAssertTrue(settings.hasCompletedWelcome)

        let relaunched = DKAppSettings(defaults: defaults, welcomeVersion: "2", applyImmediately: false)
        XCTAssertTrue(relaunched.hasCompletedWelcome)

        let upgraded = DKAppSettings(defaults: defaults, welcomeVersion: "3", applyImmediately: false)
        XCTAssertFalse(upgraded.hasCompletedWelcome)

        upgraded.resetWelcome()
        XCTAssertFalse(upgraded.hasCompletedWelcome)
        XCTAssertNil(defaults.string(forKey: DKDefaultsKey.welcomeVersion))
    }

    func testChoicesPersistImmediately() {
        let suite = "aymdk.tests.choices.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let settings = DKAppSettings(defaults: defaults, welcomeVersion: "1", applyImmediately: false)
        settings.language = .simplifiedChinese
        settings.windowPreset = .large

        let reloaded = DKAppSettings(defaults: defaults, welcomeVersion: "1", applyImmediately: false)
        XCTAssertEqual(reloaded.language, .simplifiedChinese)
        XCTAssertEqual(reloaded.windowPreset, .large)
    }

    func testAppInfoReadsVersionText() {
        let info = DKAppInfo(name: "Demo", version: "1.4.0", build: "42", bundleIdentifier: "app.demo")
        XCTAssertEqual(info.versionText, "1.4.0 (42)")
        XCTAssertEqual(info.nameAndVersion, "Demo 1.4.0 (42)")
        XCTAssertTrue(DKFrameworkInfo.name.contains("DevKit"))
    }
}
