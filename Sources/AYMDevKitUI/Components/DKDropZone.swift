import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// The framework drop target. It accepts file URLs, shows a dashed target state
/// and offers a browse fallback for users who do not drag.
public struct DKDropZone: View {
    @DKThemeValue private var theme

    private let title: String
    private let subtitle: String
    private let systemImage: String
    private let allowsMultiple: Bool
    private let allowedContentTypes: [UTType]
    private let showsBrowse: Bool
    private let onDrop: ([URL]) -> Void

    @State private var isTargeted = false

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        systemImage: String = "arrow.down.doc",
        allowsMultiple: Bool = true,
        allowedContentTypes: [UTType] = [],
        showsBrowse: Bool = true,
        onDrop: @escaping ([URL]) -> Void
    ) {
        self.title = title ?? DKL10n.t("dropzone.title")
        self.subtitle = subtitle ?? DKL10n.t("dropzone.subtitle")
        self.systemImage = systemImage
        self.allowsMultiple = allowsMultiple
        self.allowedContentTypes = allowedContentTypes
        self.showsBrowse = showsBrowse
        self.onDrop = onDrop
    }

    public var body: some View {
        VStack(spacing: DKSpacing.x12) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous)
                        .fill(isTargeted ? theme.expressiveGradient : theme.primaryGradient)
                )
                .shadow(
                    color: theme.brand.primary.opacity(isTargeted ? 0.34 : 0.2),
                    radius: isTargeted ? 16 : 10,
                    x: 0,
                    y: 6
                )
                .scaleEffect(isTargeted ? 1.06 : 1)

            VStack(spacing: DKSpacing.x4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textTertiary)
                    .multilineTextAlignment(.center)
            }

            if showsBrowse {
                DKButton(
                    DKL10n.t("common.browse"),
                    systemImage: "folder",
                    variant: .tonal,
                    size: .small,
                    action: browse
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DKSpacing.x28)
        .padding(.horizontal, DKSpacing.x20)
        .background(
            RoundedRectangle(cornerRadius: DKRadius.xl, style: .continuous)
                .fill(isTargeted
                    ? theme.primaryContainer.opacity(theme.isDark ? 0.45 : 0.55)
                    : theme.surfaceLow.opacity(0.38))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DKRadius.xl, style: .continuous)
                .strokeBorder(
                    isTargeted ? theme.primary.opacity(0.75) : theme.outlineStrong,
                    style: StrokeStyle(lineWidth: 1.4, dash: [6, 5])
                )
        )
        .scaleEffect(isTargeted ? 1.006 : 1)
        .animation(DKMotion.quick, value: isTargeted)
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
            accept(providers)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(title))
    }

    private func accept(_ providers: [NSItemProvider]) -> Bool {
        guard !providers.isEmpty else { return false }

        let group = DispatchGroup()
        let lock = NSLock()
        var results = [URL?](repeating: nil, count: providers.count)

        for (index, provider) in providers.enumerated() {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                defer { group.leave() }
                let url = Self.url(from: item)
                lock.lock()
                results[index] = url
                lock.unlock()
            }
        }

        group.notify(queue: .main) {
            let urls = results.compactMap { $0 }
            guard !urls.isEmpty else { return }
            onDrop(allowsMultiple ? urls : Array(urls.prefix(1)))
        }

        return true
    }

    private func browse() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = allowsMultiple
        panel.canChooseFiles = true
        panel.canChooseDirectories = allowedContentTypes.contains(.folder)
        if !allowedContentTypes.isEmpty {
            panel.allowedContentTypes = allowedContentTypes
        }
        if panel.runModal() == .OK {
            onDrop(panel.urls)
        }
    }

    private static func url(from item: NSSecureCoding?) -> URL? {
        if let url = item as? URL {
            return url
        }
        if let url = item as? NSURL {
            return url as URL
        }
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }
        if let string = item as? String {
            return URL(fileURLWithPath: string)
        }
        return nil
    }
}
