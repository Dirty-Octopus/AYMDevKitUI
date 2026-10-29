import SwiftUI

/// A labelled single-line field. Secure entry, help text, validation and the
/// clear affordance are part of the component so forms stay consistent.
public struct DKTextField: View {
    @DKThemeValue private var theme

    private let label: String?
    private let placeholder: String
    @Binding private var text: String
    private let systemImage: String?
    private let isSecure: Bool
    private let help: String?
    private let error: String?
    private let onSubmit: (() -> Void)?

    @FocusState private var focused: Bool

    public init(
        label: String? = nil,
        placeholder: String,
        text: Binding<String>,
        systemImage: String? = nil,
        isSecure: Bool = false,
        help: String? = nil,
        error: String? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.systemImage = systemImage
        self.isSecure = isSecure
        self.help = help
        self.error = error
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DKSpacing.x6) {
            if let label {
                Text(label)
                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textSecondary)
            }

            HStack(spacing: DKSpacing.x8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(focused ? theme.primary : theme.textTertiary)
                        .frame(width: 16)
                }

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textPrimary)
                .focused($focused)
                .onSubmit { onSubmit?() }

                if focused && !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(DKL10n.t("common.clear")))
                }
            }
            .padding(.horizontal, DKSpacing.x12)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                    .fill(theme.surfaceLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                    .strokeBorder(
                        error != nil
                            ? theme.danger.opacity(0.65)
                            : (focused ? theme.primary.opacity(0.65) : theme.outline),
                        lineWidth: focused || error != nil ? 1.5 : 1
                    )
            )
            .animation(DKMotion.quick, value: focused)

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
        .accessibilityElement(children: .contain)
    }
}

/// Compact search field used in toolbars and list headers.
public struct DKSearchField: View {
    @DKThemeValue private var theme

    @Binding private var text: String
    private let placeholder: String

    @FocusState private var focused: Bool

    public init(text: Binding<String>, placeholder: String? = nil) {
        self._text = text
        self.placeholder = placeholder ?? DKL10n.t("common.search")
    }

    public var body: some View {
        HStack(spacing: DKSpacing.x8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(focused ? theme.primary : theme.textTertiary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textPrimary)
                .focused($focused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(theme.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(DKL10n.t("common.clear")))
            }
        }
        .padding(.horizontal, DKSpacing.x12)
        .frame(height: 34)
        .background(Capsule().fill(theme.surfaceLow))
        .overlay(
            Capsule().strokeBorder(
                focused ? theme.primary.opacity(0.55) : theme.outline,
                lineWidth: focused ? 1.4 : 1
            )
        )
        .animation(DKMotion.quick, value: focused)
    }
}

/// A full-width setting row with an icon, copy and the framework switch. The
/// whole row is clickable, which is the interaction rule for boolean settings.
public struct DKToggleRow: View {
    @DKThemeValue private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    @Binding private var isOn: Bool
    private let isEnabled: Bool

    public init(
        _ title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        isOn: Binding<Bool>,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self._isOn = isOn
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Button {
            withAnimation(DKMotion.resolve(DKMotion.quick, reduceMotion: reduceMotion)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: DKSpacing.x12) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(isOn ? theme.primary : theme.textTertiary)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(isOn ? theme.primaryContainer : theme.surfaceLow)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 10.5, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textTertiary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                switchTrack
            }
            .padding(.horizontal, DKSpacing.x12)
            .padding(.vertical, DKSpacing.x8)
            .background(
                RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous)
                    .fill(isOn ? theme.primaryContainer.opacity(theme.isDark ? 0.45 : 0.38) : theme.surfaceLow.opacity(0.62))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous)
                    .strokeBorder(isOn ? theme.primary.opacity(0.18) : theme.outline, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous))
            .opacity(isEnabled ? 1 : 0.42)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private var switchTrack: some View {
        Capsule()
            .fill(isOn ? theme.primary : theme.surfaceHigh)
            .frame(width: 36, height: 21)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width: 15, height: 15)
                    .shadow(color: Color.black.opacity(0.14), radius: 2, x: 0, y: 1)
                    .offset(x: isOn ? 7.5 : -7.5)
            )
            .animation(DKMotion.resolve(DKMotion.quick, reduceMotion: reduceMotion), value: isOn)
    }
}

/// Leading artwork for `DKChoiceCard`.
public enum DKChoiceLeading {
    case none
    case badge(String)
    case symbol(String)
    case window(DKWindowPreset)
    case mark(DKMark)
}

/// A large, clickable option card. Used for language, appearance and window-size
/// choices so the welcome and settings panels share one selection language.
public struct DKChoiceCard: View {
    @DKThemeValue private var theme

    private let title: String
    private let subtitle: String?
    private let leading: DKChoiceLeading
    private let selected: Bool
    private let compact: Bool
    private let action: () -> Void

    @State private var hovering = false

    public init(
        title: String,
        subtitle: String? = nil,
        leading: DKChoiceLeading = .none,
        selected: Bool,
        compact: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading
        self.selected = selected
        self.compact = compact
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: compact ? DKSpacing.x10 : DKSpacing.x12) {
                HStack(alignment: .top, spacing: DKSpacing.x8) {
                    leadingView
                    Spacer(minLength: 0)
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selected ? theme.primary : theme.textTertiary.opacity(0.35))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: compact ? 12.5 : 14, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: compact ? 9.5 : 10.5, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textTertiary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(compact ? DKSpacing.x12 : DKSpacing.x16)
            .frame(maxWidth: .infinity, minHeight: compact ? 92 : 112, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: compact ? DKRadius.md : DKRadius.lg, style: .continuous)
                    .fill(selected
                        ? theme.primaryContainer.opacity(theme.isDark ? 0.55 : 0.5)
                        : theme.surfaceLow.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: compact ? DKRadius.md : DKRadius.lg, style: .continuous)
                    .strokeBorder(
                        selected
                            ? theme.primary.opacity(0.55)
                            : (hovering ? theme.primary.opacity(0.3) : theme.outline),
                        lineWidth: selected ? 1.6 : 1
                    )
            )
            .scaleEffect(hovering ? 1.008 : 1)
            .contentShape(RoundedRectangle(cornerRadius: compact ? DKRadius.md : DKRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { inside in
            withAnimation(DKMotion.quick) {
                hovering = inside
            }
        }
        .animation(DKMotion.quick, value: selected)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    @ViewBuilder private var leadingView: some View {
        switch leading {
        case .none:
            EmptyView()
        case .badge(let text):
            Text(text)
                .font(.system(size: compact ? 14 : 17, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: compact ? 36 : 44, height: compact ? 36 : 44)
                .background(
                    RoundedRectangle(cornerRadius: compact ? 10 : 13, style: .continuous)
                        .fill(theme.primaryGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: compact ? 10 : 13, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                )
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: compact ? 13 : 15, weight: .semibold))
                .foregroundStyle(selected ? theme.primary : theme.textSecondary)
                .frame(width: compact ? 32 : 38, height: compact ? 32 : 38)
                .background(
                    Circle().fill(selected ? theme.primaryContainer : theme.surfaceHigh)
                )
                .overlay(Circle().strokeBorder(theme.outline, lineWidth: 1))
        case .window(let preset):
            DKWindowPreview(preset: preset, width: compact ? 44 : 54)
        case .mark(let mark):
            DKMarkView(mark, size: compact ? 34 : 40, style: .gradient)
        }
    }
}

public struct DKSegmentedItem<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: String
    public let symbol: String?

    public var id: Value { value }

    public init(value: Value, title: String, symbol: String? = nil) {
        self.value = value
        self.title = title
        self.symbol = symbol
    }
}

/// A pill segmented control with a matched-geometry selection. Use for view
/// modes and compact filters; use choice cards when each option needs copy.
public struct DKSegmentedControl<Value: Hashable>: View {
    @DKThemeValue private var theme

    @Binding private var selection: Value
    private let items: [DKSegmentedItem<Value>]

    @Namespace private var namespace

    public init(selection: Binding<Value>, items: [DKSegmentedItem<Value>]) {
        self._selection = selection
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(items) { item in
                Button {
                    withAnimation(DKMotion.standard) {
                        selection = item.value
                    }
                } label: {
                    HStack(spacing: DKSpacing.x6) {
                        if let symbol = item.symbol {
                            Image(systemName: symbol)
                                .font(.system(size: 11.5, weight: .semibold))
                        }
                        if !item.title.isEmpty {
                            Text(item.title)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                    }
                    .foregroundStyle(selection == item.value ? theme.textPrimary : theme.textSecondary)
                    .padding(.horizontal, item.title.isEmpty ? 10 : 14)
                    .frame(height: 32)
                    .background {
                        if selection == item.value {
                            Capsule()
                                .fill(theme.surface)
                                .matchedGeometryEffect(id: "segment", in: namespace)
                                .shadow(color: theme.shadowSoft, radius: 7, x: 0, y: 3)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == item.value ? .isSelected : [])
            }
        }
        .padding(3)
        .background(Capsule().fill(theme.surfaceLow))
        .overlay(Capsule().strokeBorder(theme.outline, lineWidth: 1))
    }
}

public struct DKSelectOption<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: String
    public let symbol: String?

    public var id: Value { value }

    public init(value: Value, title: String, symbol: String? = nil) {
        self.value = value
        self.title = title
        self.symbol = symbol
    }
}

/// Setting-style select. The closed control is a row; the open menu uses native
/// checkmarks and keyboard navigation.
public struct DKMenuPicker<Value: Hashable>: View {
    @DKThemeValue private var theme

    private let title: String?
    private let subtitle: String?
    private let placeholder: String
    @Binding private var selection: Value
    private let options: [DKSelectOption<Value>]
    private let isEnabled: Bool

    public init(
        _ title: String? = nil,
        subtitle: String? = nil,
        placeholder: String = "—",
        selection: Binding<Value>,
        options: [DKSelectOption<Value>],
        isEnabled: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
        self._selection = selection
        self.options = options
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    selection = option.value
                } label: {
                    if selection == option.value {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Text(option.title)
                    }
                }
            }
        } label: {
            HStack(spacing: DKSpacing.x12) {
                if let title {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textPrimary)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 10.5, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textTertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: DKSpacing.x6) {
                    if let symbol = current?.symbol {
                        Image(systemName: symbol)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    Text(current?.title ?? placeholder)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundStyle(theme.textTertiary)
                }
                .foregroundStyle(theme.primary)
            }
            .padding(.horizontal, DKSpacing.x12)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                    .fill(theme.surfaceLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DKRadius.sm, style: .continuous)
                    .strokeBorder(theme.outline, lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : 0.45)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .disabled(!isEnabled)
    }

    private var current: DKSelectOption<Value>? {
        options.first { $0.value == selection }
    }
}
