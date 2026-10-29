import SwiftUI
import AppKit

/// Reads the host `NSWindow` so the library can apply its chrome and sizing.
public struct DKWindowAccessor: NSViewRepresentable {
    private let onWindow: (NSWindow?) -> Void

    public init(onWindow: @escaping (NSWindow?) -> Void) {
        self.onWindow = onWindow
    }

    public func makeNSView(context: Context) -> NSView {
        let view = WindowReaderView()
        view.onWindow = onWindow
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {}

    final class WindowReaderView: NSView {
        var onWindow: ((NSWindow?) -> Void)?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            onWindow?(window)
        }
    }
}

/// An AppKit-backed drag surface. Place it behind a top bar so the empty area
/// drags the window while buttons in front keep working.
public struct DKDragArea: NSViewRepresentable {
    public init() {}

    public func makeNSView(context: Context) -> NSView {
        DraggableView()
    }

    public func updateNSView(_ nsView: NSView, context: Context) {}

    final class DraggableView: NSView {
        override var isOpaque: Bool { false }

        override func mouseDown(with event: NSEvent) {
            window?.performDrag(with: event)
        }
    }
}

public enum DKTopBarStyle: Equatable {
    case transparent
    case material
}

/// The shared top bar. It reserves a compact leading inset, renders the app mark
/// and identity, and hosts trailing actions.
public struct DKTopBar<Actions: View>: View {
    @DKThemeValue private var theme

    private let info: DKAppInfo
    private let leadingInset: CGFloat
    private let style: DKTopBarStyle
    private let enablesDrag: Bool
    private let actions: Actions

    public init(
        info: DKAppInfo,
        leadingInset: CGFloat = DKLayout.topBarLeadingInset,
        style: DKTopBarStyle = .transparent,
        enablesDrag: Bool = true,
        @ViewBuilder actions: () -> Actions
    ) {
        self.info = info
        self.leadingInset = leadingInset
        self.style = style
        self.enablesDrag = enablesDrag
        self.actions = actions()
    }

    public var body: some View {
        HStack(spacing: DKSpacing.x10) {
            Color.clear
                .frame(width: leadingInset, height: 1)

            DKMarkView(info.mark, size: 28, style: .tinted)

            VStack(alignment: .leading, spacing: 1) {
                Text(info.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(1)
                if !info.tagline.isEmpty {
                    Text(info.tagline)
                        .font(.system(size: 9.5, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textTertiary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: DKSpacing.x12)

            actions
        }
        .padding(.trailing, DKSpacing.x20)
        .frame(height: 58)
        .background {
            ZStack {
                if style == .material {
                    Rectangle().fill(.ultraThinMaterial)
                }
                if enablesDrag {
                    DKDragArea()
                }
            }
        }
        .overlay(alignment: .bottom) {
            DKHairline()
        }
    }
}

public extension DKTopBar where Actions == EmptyView {
    init(
        info: DKAppInfo,
        leadingInset: CGFloat = DKLayout.topBarLeadingInset,
        style: DKTopBarStyle = .transparent,
        enablesDrag: Bool = true
    ) {
        self.init(
            info: info,
            leadingInset: leadingInset,
            style: style,
            enablesDrag: enablesDrag
        ) {
            EmptyView()
        }
    }
}

/// Top bar + content. The root supplies the background; a standalone shell can
/// request its own with `drawsBackground`.
public struct DKAppShell<Content: View, Actions: View>: View {
    private let info: DKAppInfo
    private let brand: DKBrand
    private let showsTopBar: Bool
    private let drawsBackground: Bool
    private let leadingInset: CGFloat
    private let topBarStyle: DKTopBarStyle
    private let enablesWindowDrag: Bool
    private let actions: Actions
    private let content: Content

    public init(
        info: DKAppInfo = .current,
        brand: DKBrand = .default,
        showsTopBar: Bool = true,
        drawsBackground: Bool = false,
        leadingInset: CGFloat = DKLayout.topBarLeadingInset,
        topBarStyle: DKTopBarStyle = .transparent,
        enablesWindowDrag: Bool = true,
        @ViewBuilder actions: () -> Actions,
        @ViewBuilder content: () -> Content
    ) {
        self.info = info
        self.brand = brand
        self.showsTopBar = showsTopBar
        self.drawsBackground = drawsBackground
        self.leadingInset = leadingInset
        self.topBarStyle = topBarStyle
        self.enablesWindowDrag = enablesWindowDrag
        self.actions = actions()
        self.content = content()
    }

    public var body: some View {
        ZStack {
            if drawsBackground {
                DKAppBackground()
            }

            VStack(spacing: 0) {
                if showsTopBar {
                    DKTopBar(
                        info: info,
                        leadingInset: leadingInset,
                        style: topBarStyle,
                        enablesDrag: enablesWindowDrag
                    ) {
                        actions
                    }
                }

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .dkBrand(brand)
    }
}

public extension DKAppShell where Actions == EmptyView {
    init(
        info: DKAppInfo = .current,
        brand: DKBrand = .default,
        showsTopBar: Bool = true,
        drawsBackground: Bool = false,
        leadingInset: CGFloat = DKLayout.topBarLeadingInset,
        topBarStyle: DKTopBarStyle = .transparent,
        enablesWindowDrag: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            info: info,
            brand: brand,
            showsTopBar: showsTopBar,
            drawsBackground: drawsBackground,
            leadingInset: leadingInset,
            topBarStyle: topBarStyle,
            enablesWindowDrag: enablesWindowDrag,
            actions: { EmptyView() },
            content: content
        )
    }
}

/// One-call application root.
///
/// It owns the shared background, the welcome gate, the brand and locale
/// environment, the appearance preference and window attachment. A host app only
/// supplies its content:
///
/// ```swift
/// WindowGroup {
///     DKAppRoot(info: .current, brand: .aurora, settings: settings) {
///         AppShell()
///     }
/// }
/// ```
public struct DKAppRoot<Content: View>: View {
    @ObservedObject private var settings: DKAppSettings

    private let info: DKAppInfo
    private let brand: DKBrand
    private let showsWelcome: Bool
    private let welcomeConfiguration: DKWelcomeConfiguration
    private let backgroundFieldIntensity: Double
    private let content: Content

    public init(
        info: DKAppInfo = .current,
        brand: DKBrand = .default,
        settings: DKAppSettings,
        showsWelcome: Bool = true,
        welcome: DKWelcomeConfiguration = .init(),
        backgroundFieldIntensity: Double = 1,
        @ViewBuilder content: () -> Content
    ) {
        self._settings = ObservedObject(wrappedValue: settings)
        self.info = info
        self.brand = brand
        self.showsWelcome = showsWelcome
        self.welcomeConfiguration = welcome
        self.backgroundFieldIntensity = backgroundFieldIntensity
        self.content = content()
    }

    public var body: some View {
        ZStack {
            DKAppBackground(fieldIntensity: backgroundFieldIntensity)

            if showsWelcome && !settings.hasCompletedWelcome {
                DKWelcomePanel(
                    info: info,
                    settings: settings,
                    configuration: welcomeConfiguration
                )
                .transition(.opacity)
            } else {
                content
                    .transition(.opacity)
            }
        }
        .dkBrand(brand)
        .environmentObject(settings)
        .environment(\.locale, settings.language.locale)
        .animation(DKMotion.gentle, value: settings.hasCompletedWelcome)
        .background {
            DKWindowAccessor { window in
                guard let window else { return }
                window.title = info.name
                DKWindowManager.shared.attach(window)
            }
            .frame(width: 0, height: 0)
        }
        .dkAmbientRipples()
        .onAppear {
            settings.applyAll()
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 260_000_000)
                settings.applyAll()
            }
        }
    }
}
