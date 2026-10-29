import SwiftUI
import AppKit

/// App-wide appearance preference. Kept in `DKAppSettings` and applied through
/// both SwiftUI's preferred colour scheme and `NSApp.appearance` so sheets,
/// traffic lights and native menus agree.
public enum DKAppearance: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var titleKey: String {
        switch self {
        case .system: return "appearance.system"
        case .light: return "appearance.light"
        case .dark: return "appearance.dark"
        }
    }

    public var subtitleKey: String {
        switch self {
        case .system: return "appearance.system.subtitle"
        case .light: return "appearance.light.subtitle"
        case .dark: return "appearance.dark.subtitle"
        }
    }

    public var systemImage: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.stars.fill"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    @MainActor
    public func apply() {
        guard let app = NSApp else { return }
        switch self {
        case .system:
            app.appearance = nil
        case .light:
            app.appearance = NSAppearance(named: .aqua)
        case .dark:
            app.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

/// Window presets are part of the shared framework: welcome and settings expose
/// exactly the same three choices.
public enum DKWindowPreset: String, CaseIterable, Identifiable, Codable {
    case compact
    case standard
    case large

    public var id: String { rawValue }

    public var contentSize: CGSize {
        switch self {
        case .compact: return CGSize(width: 1040, height: 720)
        case .standard: return CGSize(width: 1180, height: 820)
        case .large: return CGSize(width: 1380, height: 920)
        }
    }

    public var titleKey: String {
        switch self {
        case .compact: return "window.compact"
        case .standard: return "window.standard"
        case .large: return "window.large"
        }
    }

    public var subtitleKey: String {
        switch self {
        case .compact: return "window.compact.subtitle"
        case .standard: return "window.standard.subtitle"
        case .large: return "window.large.subtitle"
        }
    }

    public var symbol: String {
        switch self {
        case .compact: return "rectangle.compress.vertical"
        case .standard: return "rectangle"
        case .large: return "rectangle.expand.vertical"
        }
    }

    public var sizeText: String {
        "\(Int(contentSize.width)) × \(Int(contentSize.height))"
    }

    /// Relative width for the miniature preview, normalised to the large size.
    public var previewRatio: CGFloat {
        contentSize.width / DKWindowPreset.large.contentSize.width
    }

    public static var defaultPreset: DKWindowPreset { .standard }
}

/// Owns the host window's chrome and preset sizing. The panel code only ever
/// talks to this manager, never to `NSWindow` directly.
@MainActor
public final class DKWindowManager {
    public static let shared = DKWindowManager()

    public private(set) weak var window: NSWindow?
    private var configuredWindowID: ObjectIdentifier?
    private var didApplyInitialPreset = false

    private init() {}

    /// Applies the seamless titlebar chrome used by every DevKit app.
    ///
    /// The window keeps the native traffic lights, but the titlebar is
    /// transparent and the content extends underneath it. The app's own canvas
    /// and ASCII field therefore continue to the very top edge; there is no
    /// grey system strip between the window chrome and the content. The title is
    /// hidden because the in-app top bar carries the identity.
    public func attach(_ window: NSWindow) {
        self.window = window

        let id = ObjectIdentifier(window)
        guard configuredWindowID != id else { return }
        configuredWindowID = id

        window.styleMask.insert(.fullSizeContentView)
        window.styleMask.insert(.titled)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        window.backgroundColor = .clear
        window.isOpaque = false
        window.isMovableByWindowBackground = false
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
        window.styleMask.insert(.resizable)
        window.minSize = NSSize(
            width: DKLayout.minWindowWidth,
            height: DKLayout.minWindowHeight
        )

        if !didApplyInitialPreset {
            didApplyInitialPreset = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.apply(.currentOrDefault, animated: false)
            }
        }
    }

    /// Styles an auxiliary window (the Settings scene, a sheet, a panel) with
    /// the same seamless chrome, without making it the window that receives
    /// preset resizing.
    public func styleAuxiliary(_ window: NSWindow) {
        window.styleMask.insert(.fullSizeContentView)
        window.styleMask.insert(.titled)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        window.backgroundColor = .clear
        window.isOpaque = false
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    }

    /// Attaches to the app's key window when the host cannot provide an
    /// `NSViewRepresentable` accessor. Safe to call repeatedly.
    public func attachCurrentWindowIfAvailable() {
        guard window == nil else { return }
        guard let candidate = NSApp?.keyWindow ?? NSApp?.mainWindow ?? NSApp?.windows.first else {
            return
        }
        attach(candidate)
    }

    /// Computes the frame for a new size while keeping the visual top-left
    /// corner fixed and the result on screen. Exposed internally so the
    /// anchoring rule can be unit-tested without creating a window.
    static func anchoredFrame(
        currentFrame: NSRect,
        newFrameSize: CGSize,
        visibleFrame: NSRect?
    ) -> NSRect {
        var frame = NSRect(origin: currentFrame.origin, size: newFrameSize)
        // AppKit's origin is bottom-left; anchoring maxY keeps the visual
        // top-left corner fixed while the height changes.
        frame.origin.y = currentFrame.maxY - newFrameSize.height

        if let visibleFrame {
            if frame.width >= visibleFrame.width {
                frame.origin.x = visibleFrame.minX
            } else {
                frame.origin.x = min(
                    max(frame.origin.x, visibleFrame.minX),
                    visibleFrame.maxX - frame.width
                )
            }
            if frame.height >= visibleFrame.height {
                frame.origin.y = visibleFrame.minY
            } else {
                frame.origin.y = min(
                    max(frame.origin.y, visibleFrame.minY),
                    visibleFrame.maxY - frame.height
                )
            }
        }
        return frame
    }

    /// Applies a preset in place. The window keeps its current top-left corner,
    /// so changing the preset in Settings never slides the main window around;
    /// only the size changes. The result is clamped to the visible screen.
    public func apply(_ preset: DKWindowPreset, animated: Bool = true) {
        guard let window else { return }

        var contentSize = preset.contentSize
        let screen = window.screen ?? NSScreen.main
        if let visible = screen?.visibleFrame {
            contentSize.width = min(contentSize.width, max(DKLayout.minWindowWidth, visible.width - 80))
            contentSize.height = min(contentSize.height, max(DKLayout.minWindowHeight, visible.height - 100))
        }

        let oldFrame = window.frame
        let frameSize = window.frameRect(
            forContentRect: NSRect(origin: .zero, size: contentSize)
        ).size

        let newFrame = Self.anchoredFrame(
            currentFrame: oldFrame,
            newFrameSize: frameSize,
            visibleFrame: screen?.visibleFrame
        )

        let unchanged =
            abs(newFrame.width - oldFrame.width) < 0.5
            && abs(newFrame.height - oldFrame.height) < 0.5
            && abs(newFrame.origin.x - oldFrame.origin.x) < 0.5
            && abs(newFrame.origin.y - oldFrame.origin.y) < 0.5
        guard !unchanged else { return }

        guard animated, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            window.setFrame(newFrame, display: true)
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = DKMotion.windowResizeDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(newFrame, display: true)
        }
    }
}

public extension DKWindowPreset {
    /// The persisted preset, used when the app window first attaches.
    static var currentOrDefault: DKWindowPreset {
        let raw = UserDefaults.standard.string(forKey: DKDefaultsKey.windowPreset)
        return raw.flatMap(DKWindowPreset.init(rawValue:)) ?? .defaultPreset
    }
}

/// Stable persistence keys. Exposed so an app can migrate or inspect them.
public enum DKDefaultsKey {
    public static let language = "aymdk.language"
    public static let appearance = "aymdk.appearance"
    public static let windowPreset = "aymdk.window.preset"
    public static let welcomeCompleted = "aymdk.welcome.completed"
    public static let welcomeVersion = "aymdk.welcome.version"
}
