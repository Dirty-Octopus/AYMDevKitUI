import SwiftUI
import AppKit

/// Label/value row used by inspector panels and settings. Values are selectable
/// and can be copied without a context menu.
public struct DKInfoRow: View {
    @DKThemeValue private var theme

    private let label: String
    private let value: String?
    private let monospaced: Bool
    private let copyable: Bool
    private let labelWidth: CGFloat

    @State private var copied = false

    public init(
        _ label: String,
        value: String?,
        monospaced: Bool = false,
        copyable: Bool = false,
        labelWidth: CGFloat = 92
    ) {
        self.label = label
        self.value = value
        self.monospaced = monospaced
        self.copyable = copyable
        self.labelWidth = labelWidth
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DKSpacing.x12) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textTertiary)
                .frame(width: labelWidth, alignment: .leading)

            Text(value ?? "—")
                .font(
                    monospaced
                        ? .system(size: 11.5, weight: .medium, design: .monospaced)
                        : .system(size: 12, weight: .medium, design: .rounded)
                )
                .foregroundStyle(value == nil ? theme.textTertiary : theme.textPrimary)
                .textSelection(.enabled)
                .lineLimit(2)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)

            if copyable, let value, !value.isEmpty {
                Button {
                    copy(value)
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(copied ? theme.success : theme.textTertiary)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(theme.surfaceLow))
                }
                .buttonStyle(.plain)
                .help(copied ? DKL10n.t("common.copied") : DKL10n.t("common.copy"))
                .accessibilityLabel(Text(copied ? DKL10n.t("common.copied") : DKL10n.t("common.copy")))
            }
        }
    }

    private func copy(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        withAnimation(DKMotion.quick) {
            copied = true
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            withAnimation(DKMotion.quick) {
                copied = false
            }
        }
    }
}

/// Summary tile for dashboards. One number, one label, optional delta and icon.
public struct DKStatTile: View {
    @DKThemeValue private var theme

    private let label: String
    private let value: String
    private let detail: String?
    private let symbol: String?
    private let tone: DKTone
    private let delta: Double?

    public init(
        _ label: String,
        value: String,
        detail: String? = nil,
        systemImage: String? = nil,
        tone: DKTone = .accent,
        delta: Double? = nil
    ) {
        self.label = label
        self.value = value
        self.detail = detail
        self.symbol = systemImage
        self.tone = tone
        self.delta = delta
    }

    public var body: some View {
        DKCard(padding: DKSpacing.x16, radius: DKRadius.lg, elevation: .low) {
            VStack(alignment: .leading, spacing: DKSpacing.x10) {
                HStack(alignment: .center) {
                    Text(label)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.1)
                        .textCase(.uppercase)
                        .foregroundStyle(theme.textTertiary)
                    Spacer(minLength: 0)
                    if let symbol {
                        Image(systemName: symbol)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(theme.color(for: tone))
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(theme.tint(for: tone)))
                    }
                }

                Text(value)
                    .font(.system(size: 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                HStack(spacing: DKSpacing.x6) {
                    if let detail {
                        Text(detail)
                            .font(.system(size: 10.5, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    if let delta {
                        DKBadge(
                            String(format: "%+.1f%%", delta * 100),
                            systemImage: delta >= 0 ? "arrow.up.right" : "arrow.down.right",
                            tone: delta >= 0 ? .success : .danger,
                            compact: true
                        )
                    }
                }
            }
        }
    }
}

/// Small identity mark for people and teams.
public struct DKAvatar: View {
    @DKThemeValue private var theme

    private let initials: String
    private let size: CGFloat
    private let tone: DKTone

    public init(_ initials: String, size: CGFloat = 28, tone: DKTone = .accent) {
        self.initials = initials
        self.size = size
        self.tone = tone
    }

    public var body: some View {
        Text(initials.uppercased())
            .font(.system(size: size * 0.38, weight: .heavy, design: .rounded))
            .foregroundStyle(theme.color(for: tone))
            .frame(width: size, height: size)
            .background(Circle().fill(theme.tint(for: tone, strength: 0.16)))
            .overlay(Circle().strokeBorder(theme.color(for: tone).opacity(0.18), lineWidth: 1))
            .accessibilityHidden(true)
    }
}
