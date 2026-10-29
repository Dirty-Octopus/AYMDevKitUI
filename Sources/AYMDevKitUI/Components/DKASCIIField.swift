import SwiftUI
import AppKit
import Foundation

/// Deterministic 2D Perlin noise used by the ambient ASCII field. Kept
/// dependency-free so the background costs nothing but a few Maths calls.
public enum DKNoise {
    public static func perlin(_ x: Double, _ y: Double) -> Double {
        let floorX = floor(x)
        let floorY = floor(y)
        let xi = Int(floorX) & 255
        let yi = Int(floorY) & 255
        let xf = x - floorX
        let yf = y - floorY

        let u = fade(xf)
        let v = fade(yf)

        let aa = permutation[permutation[xi] + yi]
        let ab = permutation[permutation[xi] + yi + 1]
        let ba = permutation[permutation[xi + 1] + yi]
        let bb = permutation[permutation[xi + 1] + yi + 1]

        let top = lerp(gradient(aa, xf, yf), gradient(ba, xf - 1, yf), u)
        let bottom = lerp(gradient(ab, xf, yf - 1), gradient(bb, xf - 1, yf - 1), u)
        return lerp(top, bottom, v)
    }

    /// Fractal Brownian motion: a few Perlin octaves give the field depth without
    /// any visible grid repetition.
    public static func fbm(_ x: Double, _ y: Double, octaves: Int = 2) -> Double {
        var amplitude = 0.5
        var frequency = 1.0
        var sum = 0.0
        var normalisation = 0.0
        for _ in 0..<max(1, octaves) {
            sum += perlin(x * frequency, y * frequency) * amplitude
            normalisation += amplitude
            amplitude *= 0.5
            frequency *= 2
        }
        return normalisation > 0 ? sum / normalisation : 0
    }

    private static let permutation: [Int] = {
        var values = Array(0..<256)
        var state: UInt64 = 0x9E37_79B9_7F4A_7C15
        for index in stride(from: 255, through: 1, by: -1) {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            let other = Int((state >> 33) % UInt64(index + 1))
            values.swapAt(index, other)
        }
        return values + values
    }()

    private static func fade(_ value: Double) -> Double {
        value * value * value * (value * (value * 6 - 15) + 10)
    }

    private static func lerp(_ a: Double, _ b: Double, _ ratio: Double) -> Double {
        a + (b - a) * ratio
    }

    private static func gradient(_ hash: Int, _ x: Double, _ y: Double) -> Double {
        switch hash & 7 {
        case 0: return x + y
        case 1: return -x + y
        case 2: return x - y
        case 3: return -x - y
        case 4: return x
        case 5: return -x
        case 6: return y
        default: return -y
        }
    }
}

/// One click ripple. `center` is normalised to the window's bounds so a ripple
/// spawned in the main window also shows up in the Settings window.
public struct DKRipple: Identifiable {
    public let id: UUID
    public let center: CGPoint
    public let startedAt: TimeInterval

    public init(id: UUID = UUID(), center: CGPoint, startedAt: TimeInterval) {
        self.id = id
        self.center = center
        self.startedAt = startedAt
    }
}

/// One point on the pointer trail. Stored in normalised coordinates and drawn
/// as short-lived ASCII glyphs by every `DKASCIIField`.
public struct DKTrailPoint: Identifiable {
    public let id: UUID
    public let center: CGPoint
    public let startedAt: TimeInterval

    public init(id: UUID = UUID(), center: CGPoint, startedAt: TimeInterval) {
        self.id = id
        self.center = center
        self.startedAt = startedAt
    }
}

/// Shared ambient state for the ASCII ripple field. A root modifier feeds it
/// every tap and every hover movement; every `DKAppBackground` observes it.
public final class DKAmbient: ObservableObject {
    public static let shared = DKAmbient()

    @Published public private(set) var ripples: [DKRipple] = []
    @Published public private(set) var trail: [DKTrailPoint] = []

    private var lastTrailTime: TimeInterval = 0
    private var lastTrailCenter: CGPoint = .zero
    private let trailLifetime: TimeInterval = 0.9

    private init() {}

    /// Spawns a ripple at a point in a view of `size`, stored in normalised
    /// coordinates.
    public func spawn(at point: CGPoint, in size: CGSize) {
        guard size.width > 1, size.height > 1 else { return }
        let now = Date().timeIntervalSinceReferenceDate
        ripples.removeAll { now - $0.startedAt > 2.6 }
        ripples.append(
            DKRipple(
                center: CGPoint(x: point.x / size.width, y: point.y / size.height),
                startedAt: now
            )
        )
        if ripples.count > 8 {
            ripples.removeFirst(ripples.count - 8)
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            let cutoff = Date().timeIntervalSinceReferenceDate - 2.6
            self.ripples.removeAll { $0.startedAt < cutoff }
        }
    }

    /// Adds a pointer-trail point. Movement is throttled by time and distance so
    /// a fast pointer leaves a readable trail instead of a solid smear.
    public func addTrailPoint(at point: CGPoint, in size: CGSize) {
        guard size.width > 1, size.height > 1 else { return }
        let now = Date().timeIntervalSinceReferenceDate
        guard now - lastTrailTime >= 0.025 else { return }

        let normalised = CGPoint(x: point.x / size.width, y: point.y / size.height)
        let dx = (normalised.x - lastTrailCenter.x) * size.width
        let dy = (normalised.y - lastTrailCenter.y) * size.height
        if !trail.isEmpty, hypot(dx, dy) < 2.5 { return }

        lastTrailTime = now
        lastTrailCenter = normalised
        trail.removeAll { now - $0.startedAt > trailLifetime }
        trail.append(DKTrailPoint(center: normalised, startedAt: now))
        if trail.count > 48 {
            trail.removeFirst(trail.count - 48)
        }
    }
}

/// Cached, tinted glyph images. Drawing pre-rendered images is far cheaper than
/// shaping a `Text` for every cell on every frame, which matters once the field
/// becomes dense.
private enum DKASCIIAtlas {
    private static var cache: [String: [Image]] = [:]

    static func images(for characters: [String], color: Color, size: CGFloat) -> [Image] {
        let key = "\(color.hexDescription)|\(size)|\(characters.joined(separator: ","))"
        if let cached = cache[key] { return cached }

        let rendered = characters.map { makeImage($0, color: color, size: size) }
        cache[key] = rendered
        return rendered
    }

    private static func makeImage(_ character: String, color: Color, size: CGFloat) -> Image {
        let font = NSFont.monospacedSystemFont(ofSize: size, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(color)
        ]
        let attributed = NSAttributedString(string: character, attributes: attributes)
        let measured = attributed.size()
        let canvas = NSSize(
            width: max(ceil(measured.width) + 4, size * 0.9),
            height: max(ceil(measured.height) + 2, size * 1.3)
        )
        let image = NSImage(size: canvas, flipped: false) { _ in
            attributed.draw(at: NSPoint(x: 2, y: 1))
            return true
        }
        return Image(nsImage: image)
    }
}

/// Animated, dense ASCII code field.
///
/// A deterministic code alphabet forms the baseline; crossing sine waves, three
/// Perlin octaves, click rings and the pointer wake brighten cells on top of it.
/// The result reads as ambient code rather than decoration, and the pointer
/// leaves a wake in the same grid instead of a separate overlay.
public struct DKASCIIField: View {
    @DKThemeValue private var theme
    @ObservedObject private var ambient: DKAmbient
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.controlActiveState) private var controlActiveState

    private let intensity: Double
    private let cell: CGSize

    public init(
        intensity: Double = 1,
        cell: CGSize = CGSize(width: 10, height: 10)
    ) {
        self.intensity = intensity
        self.cell = cell
        self.ambient = DKAmbient.shared
    }

    public var body: some View {
        Group {
            if intensity <= 0.001 {
                Color.clear
            } else {
                TimelineView(
                    .animation(
                        minimumInterval: (ambient.ripples.isEmpty && ambient.trail.isEmpty) ? 1.0 / 6.0 : 1.0 / 12.0,
                        paused: reduceMotion || controlActiveState == .inactive
                    )
                ) { timeline in
                    Canvas { context, size in
                        draw(&context, size: size, date: timeline.date)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { prewarmAtlas() }
    }

    private func prewarmAtlas() {
        // Generate the glyph images for both appearances before the first
        // light/dark switch. Without this the first dark -> light change pays
        // for hundreds of AppKit glyph renders while the crossfade is running.
        let light = DKTheme(scheme: .light, brand: theme.brand)
        let dark = DKTheme(scheme: .dark, brand: theme.brand)
        let colors = [
            light.brand.primary,
            light.brand.secondaryDeep,
            dark.brand.primarySoft,
            dark.brand.secondary
        ]
        for color in colors {
            _ = DKASCIIAtlas.images(for: Self.alphabet, color: color, size: 8.5)
            _ = DKASCIIAtlas.images(for: Self.rippleAlphabet, color: color, size: 8.5)
            _ = DKASCIIAtlas.images(for: Self.trailAlphabet, color: color, size: 8.5)
        }
    }

    private func draw(_ context: inout GraphicsContext, size: CGSize, date: Date) {
        guard size.width > 40, size.height > 40 else { return }

        let time = date.timeIntervalSinceReferenceDate
        let columns = max(1, Int(size.width / cell.width))
        let rows = max(1, Int(size.height / cell.height))
        let gridWidth = CGFloat(max(columns - 1, 1)) * cell.width
        let gridHeight = CGFloat(max(rows - 1, 1)) * cell.height
        let originX = (size.width - gridWidth) / 2
        let originY = (size.height - gridHeight) / 2
        let aspect = Double(size.width / max(size.height, 1))

        let ripples = ambient.ripples
        let color = theme.isDark ? theme.brand.primarySoft : theme.brand.primary
        let peakColor = theme.isDark ? theme.brand.secondary : theme.brand.secondaryDeep

        let monoSize: CGFloat = 8.5
        let monoFont = NSFont.monospacedSystemFont(ofSize: monoSize, weight: .regular)
        let sample = NSAttributedString(string: "0000000000", attributes: [.font: monoFont])
        let advance = max(sample.size().width / 10, 1)
        var kerning = cell.width - advance
        if columns > 1 {
            let probe = NSAttributedString(
                string: String(repeating: "0", count: columns),
                attributes: [.font: monoFont, .kern: kerning]
            )
            let measured = probe.size().width
            kerning += (CGFloat(columns) * cell.width - measured) / CGFloat(columns - 1)
        }
        let rowFont = Font.system(size: monoSize, weight: .regular, design: .monospaced)

        // Dense dynamic baseline. Each cell re-rolls its code character on its
        // own staggered clock; the row is still shaped as one string.
        var rowTexts: [GraphicsContext.ResolvedText] = []
        rowTexts.reserveCapacity(rows)
        for row in 0..<rows {
            var characters = ""
            characters.reserveCapacity(columns)
            for column in 0..<columns {
                let generation = Self.generation(row: row, column: column, time: time)
                characters.append(contentsOf: Self.alphabet[Self.glyphIndex(row: row, column: column, generation: generation)])
            }
            rowTexts.append(
                context.resolve(
                    Text(characters)
                        .font(rowFont)
                        .kerning(kerning)
                        .foregroundColor(color)
                )
            )
        }

        context.opacity = (theme.isDark ? 0.075 : 0.06) * intensity
        for row in 0..<rows {
            context.draw(
                rowTexts[row],
                at: CGPoint(
                    x: originX - advance / 2,
                    y: originY + CGFloat(row) * cell.height
                ),
                anchor: .leading
            )
        }

        let baselineGlyphs = DKASCIIAtlas.images(for: Self.alphabet, color: color, size: monoSize).map {
            context.resolve($0)
        }
        let rippleGlyphs = DKASCIIAtlas.images(for: Self.rippleAlphabet, color: peakColor, size: monoSize).map {
            context.resolve($0)
        }
        let trailGlyphs: [[GraphicsContext.ResolvedImage]] = Self.trailSizes.map { size in
            DKASCIIAtlas.images(for: Self.trailAlphabet, color: peakColor, size: size).map {
                context.resolve($0)
            }
        }

        // Pointer wake: rasterised into the same grid as the field. Stronger
        // (newer, nearer) points select a larger glyph tier, so the trail
        // shrinks as it decays.
        var wake: [Int: Double] = [:]
        for point in ambient.trail {
            let age = time - point.startedAt
            guard age >= 0, age < 0.9 else { continue }
            let fade = 1 - age / 0.9
            let centreX = (point.center.x * size.width - originX) / cell.width
            let centreY = (point.center.y * size.height - originY) / cell.height
            let radius = 2.8

            let minColumn = max(0, Int(floor(centreX - radius)))
            let maxColumn = min(columns - 1, Int(ceil(centreX + radius)))
            let minRow = max(0, Int(floor(centreY - radius)))
            let maxRow = min(rows - 1, Int(ceil(centreY + radius)))
            guard minColumn <= maxColumn, minRow <= maxRow else { continue }

            for row in minRow...maxRow {
                for column in minColumn...maxColumn {
                    let dx = Double(column) - centreX
                    let dy = Double(row) - centreY
                    let distanceSquared = dx * dx + dy * dy
                    guard distanceSquared <= radius * radius else { continue }
                    let weight = exp(-distanceSquared / 1.7) * fade
                    wake[row * columns + column, default: 0] += weight
                }
            }
        }

        // Dynamic layer. Crests brighten in the primary hue; click rings and the
        // pointer wake are the only things allowed to bring in the accent and a
        // different character set.
        for row in 0..<rows {
            let ny = Double(row) / Double(max(rows - 1, 1))
            for column in 0..<columns {
                let nx = Double(column) / Double(max(columns - 1, 1))
                let key = row * columns + column
                let wakeValue = wake[key] ?? 0

                let wave =
                    (
                        sin(nx * 11.5 + ny * 3.5 + time * 1.15) +
                        sin(ny * 13.0 - nx * 2.5 - time * 0.85)
                    ) * 0.5
                let noise = DKNoise.fbm(
                    nx * 3.0 + time * 0.06,
                    ny * 3.0 - time * 0.04,
                    octaves: 3
                )
                var height = wave * 0.92 + noise * 0.62 + wakeValue * 1.4
                var glow = wakeValue

                for ripple in ripples {
                    let age = time - ripple.startedAt
                    guard age >= 0, age < 2.4 else { continue }
                    let dx = (nx - Double(ripple.center.x)) * max(aspect, 0.7)
                    let dy = ny - Double(ripple.center.y)
                    let distance = sqrt(dx * dx + dy * dy)
                    let radius = age * 0.42
                    let band = (distance - radius) / 0.07
                    let envelope = exp(-band * band) * exp(-age * 1.15)
                    height += sin((distance - radius) * 42) * envelope * 1.5
                    glow += envelope
                }

                let normalised = min(max((height + 1.4) / 2.8, 0), 1)
                let isWake = wakeValue > 0.02
                let isRipple = glow > wakeValue + 0.16
                let isCrest = normalised > 0.72 && height > 0.42
                guard isWake || isRipple || isCrest else { continue }

                let point = CGPoint(
                    x: originX + CGFloat(column) * cell.width,
                    y: originY + CGFloat(row) * cell.height
                )

                if isWake {
                    let tier = wakeValue > 0.60 ? 2 : (wakeValue > 0.26 ? 1 : 0)
                    let index = Self.interactionIndex(
                        row: row,
                        column: column,
                        tick: Int(time / 0.13),
                        count: Self.trailAlphabet.count
                    )
                    context.opacity = (0.30 + 0.28 * min(wakeValue, 1)) * intensity
                    context.draw(trailGlyphs[tier][index], at: point, anchor: .center)
                } else if isRipple {
                    let index = Self.interactionIndex(
                        row: row,
                        column: column,
                        tick: Int(time / 0.10),
                        count: Self.rippleAlphabet.count
                    )
                    context.opacity = (0.22 + 0.28 * min(glow, 1)) * intensity
                    context.draw(rippleGlyphs[index], at: point, anchor: .center)
                } else {
                    let generation = Self.generation(row: row, column: column, time: time)
                    let index = Self.glyphIndex(row: row, column: column, generation: generation)
                    context.opacity = (0.14 + 0.20 * normalised) * intensity
                    context.draw(baselineGlyphs[index], at: point, anchor: .center)
                }
            }
        }

        context.opacity = 1
    }

    private static func glyphIndex(row: Int, column: Int, generation: Int) -> Int {
        let seed =
            (row &* 73_856_093)
            &+ (column &* 19_349_663)
            &+ (generation &* 83_492_791)
        let mixed = seed ^ (seed >> 7) ^ (column &* 2_654_435_761)
        return abs(mixed) % alphabet.count
    }

    private static func interactionIndex(row: Int, column: Int, tick: Int, count: Int) -> Int {
        let seed =
            (row &* 92_837_111)
            &+ (column &* 68_917_531)
            &+ (tick &* 31_415_927)
        let mixed = seed ^ (seed >> 5) ^ (row &* 7_919)
        return abs(mixed) % max(count, 1)
    }

    private static func generation(row: Int, column: Int, time: TimeInterval) -> Int {
        let phase = Double((row &* 37 &+ column &* 91) % 145) / 100.0
        return Int((time + phase) / 1.35)
    }

    private static let trailSizes: [CGFloat] = [8.5, 11, 13.5]

    private static let rippleAlphabet: [String] = ["~", "=", "+", "*", "#"]
    private static let trailAlphabet: [String] = ["0", "1", "2", "<", ">", "/"]

    private static let alphabet: [String] = Array(
        "0123456789abcdefx+-=*/\\|<>{}[];:.#%&"
    ).map(String.init)
}

public extension View {
    /// Feeds every tap in this subtree into the shared ambient ripple field.
    /// Apply once at the root of a window.
    func dkAmbientRipples() -> some View {
        modifier(DKAmbientRippleModifier())
    }
}

struct DKAmbientRippleModifier: ViewModifier {
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { size = proxy.size }
                        .onChange(of: proxy.size) { _, newSize in
                            size = newSize
                        }
                }
            }
            .simultaneousGesture(
                SpatialTapGesture(coordinateSpace: .local)
                    .onEnded { value in
                        guard size.width > 1, size.height > 1 else { return }
                        DKAmbient.shared.spawn(at: value.location, in: size)
                    }
            )
            .onContinuousHover(coordinateSpace: .local) { phase in
                switch phase {
                case .active(let location):
                    guard size.width > 1, size.height > 1 else { return }
                    DKAmbient.shared.addTrailPoint(at: location, in: size)
                case .ended:
                    break
                }
            }
    }
}
