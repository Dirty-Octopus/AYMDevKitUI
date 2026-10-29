import SwiftUI
import AYMDevKitUI

@main
struct DemoEntry {
    @MainActor
    static func main() {
        if CommandLine.arguments.contains("--snapshot") {
            SnapshotRenderer.run()
        } else {
            DemoApp.main()
        }
    }
}

@MainActor
struct DemoApp: App {
    @StateObject private var settings = DKAppSettings(welcomeVersion: "demo-1")

    var body: some Scene {
        WindowGroup {
            DKAppRoot(info: Demo.info, brand: .aurora, settings: settings) {
                DemoWorkspace(info: Demo.info)
            }
        }
        .defaultSize(width: 1180, height: 820)
        .commands {
            DKAppCommands(settings: settings, info: Demo.info)
        }

        Settings {
            DKSettingsPanel(
                info: Demo.info,
                brand: .aurora,
                settings: settings
            )
        }
    }
}

enum Demo {
    static let info = DKAppInfo(
        name: "AYMDevKitUI",
        tagline: "Component gallery",
        version: DKFrameworkInfo.version,
        build: "1",
        bundleIdentifier: "app.aymdevkit.demo",
        copyright: "© 2026 Andy Yu",
        license: "MIT License",
        repository: URL(string: "https://github.com/Dirty-Octopus/AYMDevKitUI"),
        mark: .monogram("DK")
    )
}
