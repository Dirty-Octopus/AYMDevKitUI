import SwiftUI
import AppKit
import AYMDevKitUI

@MainActor
enum SnapshotRenderer {
    static func run() {
        let arguments = CommandLine.arguments
        var outputPath = "docs"
        if let index = arguments.firstIndex(of: "--snapshot"), arguments.indices.contains(index + 1) {
            outputPath = arguments[index + 1]
        }

        let directory = URL(fileURLWithPath: outputPath, isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        _ = NSApplication.shared
        NSApplication.shared.setActivationPolicy(.prohibited)

        let suite = "aymdk.snapshot.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        let settings = DKAppSettings(defaults: defaults, welcomeVersion: "snapshot", applyImmediately: false)

        render(
            DemoIcon(),
            name: "icon",
            size: CGSize(width: 1024, height: 1024),
            scheme: .light,
            scale: 1,
            format: .png,
            directory: directory
        )

        settings.language = .english
        render(
            welcome(settings),
            name: "welcome-light",
            size: CGSize(width: 1180, height: 820),
            scheme: .light,
            directory: directory
        )
        render(
            welcome(settings),
            name: "welcome-dark",
            size: CGSize(width: 1180, height: 820),
            scheme: .dark,
            directory: directory
        )

        settings.language = .simplifiedChinese
        render(
            welcome(settings),
            name: "welcome-zh",
            size: CGSize(width: 1180, height: 820),
            scheme: .light,
            directory: directory
        )

        settings.language = .english
        render(
            settingsPanel(settings),
            name: "settings-light",
            size: CGSize(width: 640, height: 1000),
            scheme: .light,
            directory: directory
        )
        render(
            settingsPanel(settings),
            name: "settings-dark",
            size: CGSize(width: 640, height: 1000),
            scheme: .dark,
            directory: directory
        )

        settings.language = .simplifiedChinese
        render(
            settingsPanel(settings),
            name: "settings-zh",
            size: CGSize(width: 640, height: 1000),
            scheme: .light,
            directory: directory
        )

        settings.language = .english
        render(
            workspace(settings, screen: .overview),
            name: "preview-light",
            size: CGSize(width: 1180, height: 820),
            scheme: .light,
            directory: directory
        )
        render(
            workspace(settings, screen: .overview),
            name: "preview-dark",
            size: CGSize(width: 1180, height: 820),
            scheme: .dark,
            directory: directory
        )
        render(
            workspace(settings, screen: .components),
            name: "components-light",
            size: CGSize(width: 1180, height: 1950),
            scheme: .light,
            directory: directory
        )
        render(
            workspace(settings, screen: .foundations),
            name: "foundations-light",
            size: CGSize(width: 1180, height: 1200),
            scheme: .light,
            directory: directory
        )

        print("Snapshots written to \(directory.path)")
        exit(0)
    }

    private static func welcome(_ settings: DKAppSettings) -> some View {
        ZStack {
            DKAppBackground()
            DKWelcomePanel(info: Demo.info, settings: settings, scrolls: false)
        }
        .dkBrand(.aurora)
        .environment(\.locale, settings.language.locale)
    }

    private static func settingsPanel(_ settings: DKAppSettings) -> some View {
        DKSettingsPanel(
            info: Demo.info,
            brand: .aurora,
            settings: settings,
            scrolls: false,
            onClose: {}
        )
    }

    private static func workspace(_ settings: DKAppSettings, screen: DemoScreen) -> some View {
        ZStack {
            DKAppBackground()
            DemoWorkspace(
                info: Demo.info,
                topBarLeadingInset: 20,
                initialScreen: screen,
                usesScrollView: false,
                snapshot: true,
                enablesWindowDrag: false
            )
            .environmentObject(settings)
            .dkBrand(.aurora)
            .environment(\.locale, settings.language.locale)
        }
    }

    private enum ImageFormat {
        case png
        case jpeg
    }

    private static func render<V: View>(
        _ view: V,
        name: String,
        size: CGSize,
        scheme: ColorScheme,
        scale: CGFloat = 1.5,
        format: ImageFormat = .jpeg,
        directory: URL
    ) {
        let content = view
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, scheme)

        let renderer = ImageRenderer(content: content)
        renderer.scale = scale
        renderer.isOpaque = true

        guard
            let image = renderer.nsImage,
            let tiff = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff)
        else {
            FileHandle.standardError.write(Data("snapshot failed: \(name)\n".utf8))
            return
        }

        let data: Data?
        let fileExtension: String
        switch format {
        case .png:
            data = bitmap.representation(using: .png, properties: [:])
            fileExtension = "png"
        case .jpeg:
            data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
            fileExtension = "jpg"
        }

        guard let data else {
            FileHandle.standardError.write(Data("encode failed: \(name)\n".utf8))
            return
        }

        let url = directory.appendingPathComponent("\(name).\(fileExtension)")
        do {
            try data.write(to: url)
            print("wrote \(url.lastPathComponent) (\(data.count) bytes, \(Int(size.width))×\(Int(size.height)) @\(String(format: "%.1f", scale))x)")
        } catch {
            FileHandle.standardError.write(Data("write failed: \(name): \(error)\n".utf8))
        }
    }
}

private struct DemoIcon: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(dkHex: 0x7C5CFF), Color(dkHex: 0x4A2BD6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 620, height: 620)
                .blur(radius: 110)
                .offset(x: 260, y: -300)

            Circle()
                .fill(Color(dkHex: 0xFF6B7A).opacity(0.30))
                .frame(width: 560, height: 560)
                .blur(radius: 110)
                .offset(x: -300, y: 320)

            VStack(spacing: 18) {
                Text("DK")
                    .font(.system(size: 330, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("AYMDEVKITUI")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .tracking(14)
                    .foregroundStyle(.white.opacity(0.78))
            }
        }
        .frame(width: 1024, height: 1024)
        .clipped()
    }
}
