import SwiftUI
import AYMDevKitUI

struct DemoFoundations: View {
    @DKThemeValue private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            colors
            brands
            HStack(alignment: .top, spacing: 16) {
                typography
                metrics
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Foundations")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(theme.textPrimary)
            Text("A brand is six colours. Everything else — surfaces, outlines, readable tints and gradients — is derived by DKTheme.")
                .font(.system(size: 11.5, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var colors: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Semantic colour roles", subtitle: "Resolved for the current appearance.")
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 132), spacing: 8)],
                    spacing: 8
                ) {
                    ForEach(tokens) { token in
                        VStack(alignment: .leading, spacing: 5) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(token.color)
                                .frame(height: 42)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(theme.outline, lineWidth: 1)
                                )
                            Text(token.name)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textPrimary)
                            Text(token.value)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundStyle(theme.textTertiary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    private var brands: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Brand presets", subtitle: "Same structure, different identity. Set `dkBrand` once.")
                HStack(spacing: 10) {
                    ForEach([DKBrand.aurora, DKBrand.ocean, DKBrand.graphite], id: \.name) { brand in
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                Text(brand.name)
                                    .font(.system(size: 12.5, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary)
                                Spacer(minLength: 0)
                                Circle()
                                    .fill(brand.primary)
                                    .frame(width: 10, height: 10)
                            }
                            HStack(spacing: 4) {
                                chip(brand.primary)
                                chip(brand.primarySoft)
                                chip(brand.secondary)
                                chip(brand.success)
                                chip(brand.warning)
                                chip(brand.info)
                            }
                            Text(brand.primary.hexDescription)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundStyle(theme.textTertiary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous)
                                .fill(theme.surfaceLow.opacity(0.55))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DKRadius.md, style: .continuous)
                                .strokeBorder(theme.outline, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var typography: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 10) {
                DKSectionHeader(verbatim: "Type scale", subtitle: "Rounded system design, one tracking rule per role.")

                ForEach(samples, id: \.0) { sample in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(sample.1)
                            .font(sample.2.font)
                            .tracking(sample.2.tracking)
                            .foregroundStyle(theme.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(sample.0)
                            .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(theme.textTertiary)
                            .frame(width: 72, alignment: .trailing)
                    }
                    if sample.0 != samples.last?.0 {
                        DKHairline()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var metrics: some View {
        DKCard(padding: 18, radius: DKRadius.xl, elevation: .low) {
            VStack(alignment: .leading, spacing: 12) {
                DKSectionHeader(verbatim: "Space, radius, controls", subtitle: "Only these steps are allowed in components.")

                VStack(alignment: .leading, spacing: 6) {
                    Text("4pt spacing")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(spaces, id: \.0) { item in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(theme.primary.opacity(0.8))
                                    .frame(width: 12, height: item.0)
                                Text("\(Int(item.0))")
                                    .font(.system(size: 7.5, weight: .medium, design: .monospaced))
                                    .foregroundStyle(theme.textTertiary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }

                DKHairline()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Radius")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                    HStack(spacing: 6) {
                        ForEach(radii, id: \.0) { item in
                            RoundedRectangle(cornerRadius: item.0, style: .continuous)
                                .fill(theme.surfaceHigh)
                                .overlay(
                                    RoundedRectangle(cornerRadius: item.0, style: .continuous)
                                        .strokeBorder(theme.outline, lineWidth: 1)
                                )
                                .frame(width: 36, height: 36)
                        }
                        Spacer(minLength: 0)
                    }
                }

                DKHairline()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Control heights")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                    HStack(spacing: 6) {
                        ForEach(DKControlSize.allCases) { size in
                            VStack(spacing: 3) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(theme.primaryContainer)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .strokeBorder(theme.primary.opacity(0.2), lineWidth: 1)
                                    )
                                    .frame(width: 44, height: size.height)
                                Text(size.rawValue)
                                    .font(.system(size: 7.5, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.textTertiary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var tokens: [ColorToken] {
        [
            ColorToken("canvas", theme.canvas.hexDescription, theme.canvas),
            ColorToken("surface", theme.surface.hexDescription, theme.surface),
            ColorToken("surfaceLow", theme.surfaceLow.hexDescription, theme.surfaceLow),
            ColorToken("surfaceHigh", theme.surfaceHigh.hexDescription, theme.surfaceHigh),
            ColorToken("outline", theme.outline.hexDescription, theme.outline),
            ColorToken("textPrimary", theme.textPrimary.hexDescription, theme.textPrimary),
            ColorToken("textSecondary", theme.textSecondary.hexDescription, theme.textSecondary),
            ColorToken("primary", theme.primary.hexDescription, theme.primary),
            ColorToken("primaryContainer", theme.primaryContainer.hexDescription, theme.primaryContainer),
            ColorToken("secondary", theme.secondary.hexDescription, theme.secondary),
            ColorToken("success", theme.success.hexDescription, theme.success),
            ColorToken("warning", theme.warning.hexDescription, theme.warning),
            ColorToken("danger", theme.danger.hexDescription, theme.danger),
            ColorToken("info", theme.info.hexDescription, theme.info)
        ]
    }

    private var samples: [(String, String, DKTextStyle)] {
        [
            ("display", "Aa", .display),
            ("titleXL", "Design", .titleXL),
            ("titleL", "Every window", .titleL),
            ("title", "Panel title", .title),
            ("headline", "Section heading", .headline),
            ("body", "The quick brown fox jumps over the lazy dog.", .body),
            ("label", "Field label", .label),
            ("caption", "Secondary caption", .caption),
            ("eyebrow", "Eyebrow", .eyebrow),
            ("mono", "v1.0.0 (1)", .mono)
        ]
    }

    private var spaces: [(CGFloat, String)] {
        [(4, ""), (8, ""), (12, ""), (16, ""), (24, ""), (32, ""), (48, "")]
    }

    private var radii: [(CGFloat, String)] {
        [(8, ""), (12, ""), (16, ""), (20, ""), (24, ""), (28, "")]
    }

    private func chip(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(color)
            .frame(height: 12)
    }
}

private struct ColorToken: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let color: Color

    init(_ name: String, _ value: String, _ color: Color) {
        self.name = name
        self.value = value
        self.color = color
    }
}
