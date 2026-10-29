import SwiftUI
import AYMDevKitUI

enum DemoScreen: String, CaseIterable, Identifiable {
    case overview
    case foundations
    case components
    case panels

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .foundations: return "Foundations"
        case .components: return "Components"
        case .panels: return "Panels"
        }
    }

    var symbol: String {
        switch self {
        case .overview: return "square.grid.2x2"
        case .foundations: return "paintpalette"
        case .components: return "square.stack.3d.up"
        case .panels: return "macwindow.on.rectangle"
        }
    }
}

struct DemoWorkspace: View {
    @EnvironmentObject private var settings: DKAppSettings
    @Environment(\.openSettings) private var openSettings

    private let info: DKAppInfo
    private let topBarLeadingInset: CGFloat
    private let usesScrollView: Bool
    private let snapshot: Bool
    private let enablesWindowDrag: Bool

    @State private var screen: DemoScreen

    init(
        info: DKAppInfo,
        topBarLeadingInset: CGFloat = DKLayout.topBarLeadingInset,
        initialScreen: DemoScreen = .overview,
        usesScrollView: Bool = true,
        snapshot: Bool = false,
        enablesWindowDrag: Bool = true
    ) {
        self.info = info
        self.topBarLeadingInset = topBarLeadingInset
        self.usesScrollView = usesScrollView
        self.snapshot = snapshot
        self.enablesWindowDrag = enablesWindowDrag
        _screen = State(initialValue: initialScreen)
    }

    var body: some View {
        DKAppShell(
            info: info,
            showsTopBar: true,
            leadingInset: topBarLeadingInset,
            topBarStyle: .material,
            enablesWindowDrag: enablesWindowDrag,
            actions: {
                HStack(spacing: DKSpacing.x8) {
                    DKLiveDot(tone: .success)
                    DKBadge("Native", tone: .success, compact: true)
                    DKIconButton(
                        systemImage: "arrow.counterclockwise",
                        help: "Show the welcome panel",
                        size: 30
                    ) {
                        settings.resetWelcome()
                    }
                    DKIconButton(
                        systemImage: "gearshape",
                        help: "Settings",
                        size: 30,
                        action: { openSettings() }
                    )
                }
            },
            content: {
                HStack(spacing: 0) {
                    DKSidebar(
                        title: "Gallery",
                        selection: $screen,
                        items: DemoScreen.allCases.map { screen in
                            DKSidebarItem(
                                id: screen,
                                title: screen.title,
                                systemImage: screen.symbol
                            )
                        }
                    )

                    workspaceContent
                }
            }
        )
        .environmentObject(settings)
        .animation(DKMotion.gentle, value: screen)
    }

    @ViewBuilder private var workspaceContent: some View {
        if usesScrollView {
            ScrollView {
                screenContent
            }
            .scrollIndicators(.hidden)
        } else {
            screenContent
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var screenContent: some View {
        screenBody
            .frame(maxWidth: 1000, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder private var screenBody: some View {
        switch screen {
        case .overview:
            DemoOverview(screen: $screen)
        case .foundations:
            DemoFoundations()
        case .components:
            DemoComponents(snapshot: snapshot)
        case .panels:
            DemoPanels()
        }
    }
}

struct DemoOverview: View {
    @DKThemeValue private var theme
    @EnvironmentObject private var settings: DKAppSettings
    @Environment(\.openSettings) private var openSettings

    @Binding var screen: DemoScreen

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            hero
            stats
            HStack(alignment: .top, spacing: 16) {
                foundations
                rules
            }
        }
    }

    private var hero: some View {
        DKCard(padding: 26, radius: DKRadius.xxl, elevation: .medium) {
            HStack(alignment: .center, spacing: 24) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 6) {
                        DKBadge("v\(DKFrameworkInfo.version)", tone: .accent, compact: true)
                        DKBadge("macOS 14+", tone: .info, compact: true)
                        DKBadge("Swift 5.9", tone: .neutral, compact: true)
                    }

                    Text("One design system.\nEvery window.")
                        .font(.system(size: 33, weight: .heavy, design: .rounded))
                        .tracking(-0.8)
                        .foregroundStyle(theme.textPrimary)
                        .lineSpacing(1)

                    Text("AYMDevKitUI packages the visual language, the welcome and settings panels, and the native macOS behaviours behind a small SwiftUI API.")
                        .font(.system(size: 12.5, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 520, alignment: .leading)

                    HStack(spacing: 8) {
                        DKButton("Replay welcome", systemImage: "sparkles") {
                            settings.resetWelcome()
                        }
                        DKButton("Open settings", variant: .tonal, action: { openSettings() })
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 0)

                ZStack {
                    DKOrb(size: 158)
                    DKMarkView(.monogram("DK"), size: 76, style: .gradient, showsGlow: true)
                }
                .padding(.trailing, 10)
            }
        }
    }

    private var stats: some View {
        HStack(spacing: 12) {
            DKStatTile("Components", value: "24", detail: "Shared primitives", systemImage: "square.stack.3d.up", tone: .accent)
            DKStatTile("Panels", value: "2", detail: "Welcome + settings", systemImage: "macwindow.on.rectangle", tone: .info)
            DKStatTile("Languages", value: "\(DKLanguage.allCases.count)", detail: "English + 简体中文", systemImage: "globe", tone: .success)
            DKStatTile("Contrast", value: "4.5:1", detail: "WCAG AA text", systemImage: "circle.lefthalf.filled", tone: .warning)
        }
    }

    private var foundations: some View {
        DKCard(padding: 20, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 14) {
                DKSectionHeader(
                    verbatim: "Foundations",
                    subtitle: "Brand-derived tokens, one type scale and a 4pt rhythm."
                )

                HStack(spacing: 6) {
                    swatch(theme.brand.primary)
                    swatch(theme.brand.primarySoft)
                    swatch(theme.brand.secondary)
                    swatch(theme.brand.success)
                    swatch(theme.brand.warning)
                    swatch(theme.brand.info)
                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("The quick brown fox").font(DKTextStyle.titleL.font).foregroundStyle(theme.textPrimary)
                    Text("Body copy stays at 13pt with 3pt leading.").font(DKTextStyle.body.font).foregroundStyle(theme.textSecondary)
                    Text("EYEBROW / 1.8 TRACKING").font(DKTextStyle.eyebrow.font).tracking(DKTextStyle.eyebrow.tracking).foregroundStyle(theme.textTertiary)
                }

                DKButton("Browse foundations", variant: .link, size: .small) {
                    screen = .foundations
                }
            }
        }
    }

    private var rules: some View {
        DKCard(padding: 20, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 14) {
                DKSectionHeader(
                    verbatim: "Consistency rules",
                    subtitle: "The invariants every DevKit app inherits."
                )

                rule("01", "One accent per surface", "Primary actions never compete.")
                rule("02", "Cards own elevation", "Inset rows never cast shadows.")
                rule("03", "Panels keep one order", "Language, appearance, window, about.")
                rule("04", "Every state has a tone", "Accent, success, warning, danger, info, neutral.")

                DKButton("See the panels", variant: .link, size: .small) {
                    screen = .panels
                }
            }
        }
    }

    private func rule(_ index: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Text(index)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.primary)
                .frame(width: 20, height: 20)
                .background(Circle().fill(theme.primaryContainer))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text(detail)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
            }
        }
    }

    private func swatch(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(theme.outline, lineWidth: 1)
            )
    }
}
