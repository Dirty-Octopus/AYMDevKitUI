import SwiftUI

public struct DKSidebarItem<ID: Hashable>: Identifiable {
    public let id: ID
    public let title: String
    public let symbol: String
    public let badge: String?

    public init(id: ID, title: String, systemImage: String, badge: String? = nil) {
        self.id = id
        self.title = title
        self.symbol = systemImage
        self.badge = badge
    }
}

/// The shared sidebar. Selection is a single value, rows use the same height and
/// the selection pill animates between rows instead of fading.
public struct DKSidebar<ID: Hashable>: View {
    @DKThemeValue private var theme

    @Binding private var selection: ID
    private let title: String?
    private let items: [DKSidebarItem<ID>]
    private let width: CGFloat

    @Namespace private var namespace

    public init(
        title: String? = nil,
        selection: Binding<ID>,
        items: [DKSidebarItem<ID>],
        width: CGFloat = 208
    ) {
        self.title = title
        self._selection = selection
        self.items = items
        self.width = width
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DKSpacing.x4) {
            if let title {
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .textCase(.uppercase)
                    .foregroundStyle(theme.textTertiary)
                    .padding(.horizontal, DKSpacing.x10)
                    .padding(.top, DKSpacing.x6)
                    .padding(.bottom, DKSpacing.x8)
            }

            ForEach(items) { item in
                row(item)
            }

            Spacer(minLength: 0)
        }
        .padding(DKSpacing.x10)
        .frame(width: width)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(theme.surface.opacity(theme.isDark ? 0.34 : 0.46))
        .overlay(alignment: .trailing) {
            DKHairline(vertical: true)
        }
    }

    private func row(_ item: DKSidebarItem<ID>) -> some View {
        let selected = selection == item.id
        return Button {
            withAnimation(DKMotion.standard) {
                selection = item.id
            }
        } label: {
            HStack(spacing: DKSpacing.x10) {
                Image(systemName: item.symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(selected ? theme.primary : theme.textTertiary)
                    .frame(width: 18)

                Text(item.title)
                    .font(.system(size: 12, weight: selected ? .bold : .semibold, design: .rounded))
                    .foregroundStyle(selected ? theme.textPrimary : theme.textSecondary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                if let badge = item.badge {
                    DKBadge(badge, tone: selected ? .accent : .neutral, compact: true)
                }
            }
            .padding(.horizontal, DKSpacing.x10)
            .frame(height: 34)
            .background {
                if selected {
                    RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                        .fill(theme.primaryContainer.opacity(theme.isDark ? 0.5 : 0.55))
                        .matchedGeometryEffect(id: "sidebarSelection", in: namespace)
                }
            }
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                        .strokeBorder(theme.primary.opacity(0.16), lineWidth: 1)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
