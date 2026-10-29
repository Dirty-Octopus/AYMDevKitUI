import SwiftUI
import AYMDevKitUI

struct DemoComponents: View {
    @DKThemeValue private var theme

    private let snapshot: Bool

    @State private var name = "Andy Yu"
    @State private var apiKey = ""
    @State private var query = ""
    @State private var notifications = true
    @State private var autoUpdate = false
    @State private var mode = "grid"
    @State private var sort = "recent"
    @State private var language: DKLanguage = .english
    @State private var progress = 0.68
    @State private var dropped: [URL] = []

    init(snapshot: Bool = false) {
        self.snapshot = snapshot
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            buttons
            HStack(alignment: .top, spacing: 16) {
                badges
                marks
            }
            inputs
            HStack(alignment: .top, spacing: 16) {
                feedback
                dataDisplay
            }
            dropZone
            emptyState
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Components")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(theme.textPrimary)
            Text("Every control is a public SwiftUI view with the same metrics, tones and press feedback.")
                .font(.system(size: 11.5, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary)
        }
    }

    private var buttons: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Buttons", subtitle: "One primary action per surface. Pills for every role.")
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 8) {
                        DKButton("Primary", systemImage: "sparkles") {}
                        DKButton("Secondary", variant: .secondary) {}
                        DKButton("Tonal", variant: .tonal) {}
                        DKButton("Ghost", variant: .ghost) {}
                        DKButton("Link", variant: .link, size: .small) {}
                    }
                    HStack(spacing: 8) {
                        DKButton("Delete", systemImage: "trash", variant: .destructive) {}
                        DKButton("Loading", variant: .primary, isLoading: true) {}
                        DKButton("Disabled") {}.disabled(true)
                        DKButton("Small", variant: .secondary, size: .small) {}
                        DKButton("Large", variant: .secondary, size: .large) {}
                    }
                }
                DKHairline()
                HStack(spacing: 8) {
                    DKIconButton(systemImage: "gearshape", help: "Settings") {}
                    DKIconButton(systemImage: "trash", help: "Delete", tint: theme.danger) {}
                    DKIconButton(systemImage: "info.circle", help: "Information", size: 28) {}
                    DKIconButton(systemImage: "square.and.arrow.up", help: "Share", showsBackground: false) {}
                    Spacer(minLength: 0)
                    DKBadge("Hover any control", tone: .neutral, compact: true)
                }
            }
        }
    }

    private var badges: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Badges & status", subtitle: "Six tones, three styles.")
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 6) {
                        DKBadge("Accent", systemImage: "sparkles", tone: .accent)
                        DKBadge("Success", systemImage: "checkmark", tone: .success)
                        DKBadge("Warning", systemImage: "exclamationmark", tone: .warning)
                        Spacer(minLength: 0)
                    }
                    HStack(spacing: 6) {
                        DKBadge("Danger", systemImage: "xmark", tone: .danger)
                        DKBadge("Info", systemImage: "info", tone: .info)
                        DKBadge("Neutral", tone: .neutral)
                        Spacer(minLength: 0)
                    }
                    HStack(spacing: 6) {
                        DKBadge("Solid", tone: .accent, style: .solid)
                        DKBadge("Outline", tone: .success, style: .outline)
                        DKBadge("Compact", tone: .warning, compact: true)
                    }
                }
                DKHairline()
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        DKLiveDot(tone: .success)
                        Text("Live").font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary)
                    }
                    HStack(spacing: 5) {
                        DKStatusDot(tone: .warning)
                        Text("Queued").font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary)
                    }
                    HStack(spacing: 5) {
                        DKStatusDot(tone: .danger)
                        Text("Failed").font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var marks: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "App marks", subtitle: "Monogram, symbol or a host image.")
                HStack(spacing: 14) {
                    VStack(spacing: 5) {
                        DKMarkView(.monogram("DK"), size: 54, style: .gradient, showsGlow: true)
                        Text("gradient").font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundStyle(theme.textTertiary)
                    }
                    VStack(spacing: 5) {
                        DKMarkView(.symbol("seal.fill"), size: 54, style: .tinted)
                        Text("tinted").font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundStyle(theme.textTertiary)
                    }
                    VStack(spacing: 5) {
                        DKMarkView(.monogram("AY"), size: 54, style: .plain)
                        Text("plain").font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundStyle(theme.textTertiary)
                    }
                    VStack(spacing: 5) {
                        ZStack {
                            DKOrb(size: 54)
                            Image(systemName: "sparkles")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(theme.primary)
                        }
                        Text("orb").font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundStyle(theme.textTertiary)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var inputs: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 13) {
                DKSectionHeader(verbatim: "Inputs", subtitle: "Labels, help, errors and clear affordances are built in.")

                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        if snapshot {
                            SnapshotField(label: "Name", value: name, systemImage: "person")
                            SnapshotField(
                                label: "API key",
                                value: "••••••••••••",
                                systemImage: "key",
                                help: "Stored in the keychain by the host app."
                            )
                        } else {
                            DKTextField(
                                label: "Name",
                                placeholder: "Your name",
                                text: $name,
                                systemImage: "person"
                            )
                            DKTextField(
                                label: "API key",
                                placeholder: "sk-…",
                                text: $apiKey,
                                systemImage: "key",
                                isSecure: true,
                                help: "Stored in the keychain by the host app."
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 10) {
                        if snapshot {
                            SnapshotField(
                                label: "Workspace",
                                value: "aym-dev",
                                systemImage: "folder",
                                error: "This workspace already exists."
                            )
                            SnapshotSearchField(placeholder: "Search")
                                .padding(.top, 22)
                        } else {
                            DKTextField(
                                label: "Workspace",
                                placeholder: "aym-dev",
                                text: .constant("aym-dev"),
                                systemImage: "folder",
                                error: "This workspace already exists."
                            )
                            DKSearchField(text: $query)
                                .padding(.top, 22)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                DKHairline()

                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 8) {
                        DKToggleRow(
                            "Notifications",
                            subtitle: "Show build results",
                            systemImage: "bell",
                            isOn: $notifications
                        )
                        DKToggleRow(
                            "Automatic updates",
                            subtitle: "Check once a day",
                            systemImage: "arrow.triangle.2.circlepath",
                            isOn: $autoUpdate
                        )
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 10) {
                        DKSegmentedControl(
                            selection: $mode,
                            items: [
                                DKSegmentedItem(value: "grid", title: "Grid", symbol: "square.grid.2x2"),
                                DKSegmentedItem(value: "list", title: "List", symbol: "list.bullet"),
                                DKSegmentedItem(value: "board", title: "Board", symbol: "rectangle.split.3x1")
                            ]
                        )

                        if snapshot {
                            SnapshotMenuRow(title: "Sort", value: "Recent", subtitle: "Order of the results", symbol: "clock")
                            SnapshotMenuRow(title: "Language", value: language.displayName, symbol: "globe")
                        } else {
                            DKMenuPicker(
                                "Sort",
                                subtitle: "Order of the results",
                                selection: $sort,
                                options: [
                                    DKSelectOption(value: "recent", title: "Recent", symbol: "clock"),
                                    DKSelectOption(value: "name", title: "Name", symbol: "textformat"),
                                    DKSelectOption(value: "size", title: "Size", symbol: "arrow.up.arrow.down")
                                ]
                            )

                            DKMenuPicker(
                                "Language",
                                selection: $language,
                                options: DKLanguage.allCases.map {
                                    DKSelectOption(value: $0, title: $0.displayName)
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var feedback: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Feedback", subtitle: "Inline notices, progress and empty states.")
                VStack(spacing: 7) {
                    DKNotice("The archive is ready to install.", title: "Build complete", tone: .success, actionTitle: "Reveal", action: {})
                    DKNotice("Two files were skipped.", title: "Needs attention", tone: .warning)
                    DKNotice("The selected certificate expired.", title: "Signing failed", tone: .danger)
                }
                DKHairline()
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Uploading")
                                .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.textSecondary)
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                                .foregroundStyle(theme.textTertiary)
                        }
                        DKProgressBar(value: progress, tone: .accent)
                        HStack(spacing: 6) {
                            DKButton("-10%", variant: .ghost, size: .small) {
                                progress = max(0, progress - 0.1)
                            }
                            DKButton("+10%", variant: .ghost, size: .small) {
                                progress = min(1, progress + 0.1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    DKProgressRing(value: progress, tone: .accent, size: 62, lineWidth: 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var dataDisplay: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Data display", subtitle: "Inspectors, summaries and identity.")
                DKInset(padding: 12, radius: DKRadius.md) {
                    VStack(spacing: 7) {
                        DKInfoRow("Name", value: name)
                        DKInfoRow("Bundle", value: "app.aymdevkit.demo", monospaced: true, copyable: true)
                        DKInfoRow("Commit", value: "9f2c1ab7d4e8", monospaced: true, copyable: true)
                    }
                }
                HStack(spacing: 10) {
                    DKAvatar("AY", size: 34)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Andy Yu")
                            .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textPrimary)
                        Text("Designer & developer")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textTertiary)
                    }
                    Spacer(minLength: 0)
                    DKBadge("Owner", tone: .accent, compact: true)
                }
                DKHairline()
                HStack(spacing: 10) {
                    DKStatTile("Builds", value: "128", detail: "This month", systemImage: "hammer", tone: .accent, delta: 0.12)
                    DKStatTile("Failures", value: "3", detail: "Last 7 days", systemImage: "xmark.octagon", tone: .danger, delta: -0.04)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var dropZone: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Drop zone", subtitle: "File URLs, multi-select and a native browse fallback.")
                if snapshot {
                    SnapshotDropZone(
                        title: "Drop a build here",
                        subtitle: "ZIP, DMG, APP or any file you want to inspect"
                    )
                } else {
                    DKDropZone(
                        title: "Drop a build here",
                        subtitle: "ZIP, DMG, APP or any file you want to inspect",
                        systemImage: "shippingbox",
                        allowsMultiple: true
                    ) { urls in
                        dropped = urls
                    }
                }
                if !dropped.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(dropped, id: \.absoluteString) { url in
                            HStack(spacing: 6) {
                                Image(systemName: "doc")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(theme.primary)
                                Text(url.lastPathComponent)
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundStyle(theme.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    private var emptyState: some View {
        DKCard(padding: 0, radius: DKRadius.xl, elevation: .low) {
            DKEmptyState(
                title: "No builds yet",
                message: "Drop a build above or create one from the toolbar. The empty state always offers exactly one next step.",
                systemImage: "shippingbox",
                actionTitle: "Create build"
            ) {}
        }
    }
}


private struct SnapshotField: View {
    @DKThemeValue private var theme
    let label: String
    let value: String
    let systemImage: String
    var help: String?
    var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary)

            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.textTertiary)
                    .frame(width: 16)
                Text(value)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Spacer(minLength: 0)
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.textTertiary)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                    .fill(theme.surfaceLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                    .strokeBorder(error == nil ? theme.outline : theme.danger.opacity(0.65), lineWidth: error == nil ? 1 : 1.5)
            )

            if let error {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.danger)
            } else if let help {
                Text(help)
                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
            }
        }
    }
}

private struct SnapshotSearchField: View {
    @DKThemeValue private var theme
    let placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(theme.textTertiary)
            Text(placeholder)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textTertiary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(Capsule().fill(theme.surfaceLow))
        .overlay(Capsule().strokeBorder(theme.outline, lineWidth: 1))
    }
}

private struct SnapshotMenuRow: View {
    @DKThemeValue private var theme
    let title: String
    let value: String
    var subtitle: String? = nil
    var symbol: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let subtitle {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 10.5, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(spacing: 6) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(value)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundStyle(theme.textTertiary)
            }
            .foregroundStyle(theme.primary)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                .fill(theme.surfaceLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                .strokeBorder(theme.outline, lineWidth: 1)
        )
    }
}

private struct SnapshotDropZone: View {
    @DKThemeValue private var theme
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous)
                        .fill(theme.primaryGradient)
                )
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
            }
            DKButton("Browse…", systemImage: "folder", variant: .tonal, size: .small) {}
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: DKRadius.xl, style: .continuous)
                .fill(theme.surfaceLow.opacity(0.38))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DKRadius.xl, style: .continuous)
                .strokeBorder(theme.outlineStrong, style: StrokeStyle(lineWidth: 1.4, dash: [6, 5]))
        )
    }
}
