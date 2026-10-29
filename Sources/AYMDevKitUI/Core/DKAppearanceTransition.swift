import SwiftUI
import AppKit
import QuartzCore

/// Library-provided appearance transition.
///
/// AppKit switches `NSApp.appearance` instantly, which makes light/dark changes
/// feel abrupt. DevKit snapshots every visible window, lays the old frame over
/// the new one and crossfades it, so the whole app — including the Settings
/// window and sheets — changes in one smooth pass.
@MainActor
public enum DKAppearanceTransition {
    static let overlayIdentifier = NSUserInterfaceItemIdentifier("app.aymdevkit.appearance-transition")

    /// Applies `appearance` with a crossfade. Falls back to an instant switch when
    /// Reduce Motion is enabled or when no window is available.
    public static func apply(
        _ appearance: DKAppearance,
        duration: TimeInterval = DKMotion.appearanceDuration
    ) {
        guard let app = NSApp else { return }

        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        guard !reduceMotion, duration > 0 else {
            appearance.apply()
            return
        }

        let windows = app.windows.filter { window in
            window.isVisible
                && window.alphaValue > 0.01
                && window.contentView != nil
                && (window.contentView?.bounds.width ?? 0) > 1
        }

        var overlays: [PassthroughImageView] = []

        for window in windows {
            guard let content = window.contentView else { continue }
            // The theme frame contains both the content and the titlebar. Fading
            // that whole surface keeps the seamless chrome in step with the
            // content in both directions.
            let host = content.superview ?? content
            host.layoutSubtreeIfNeeded()
            window.displayIfNeeded()

            // Drop any overlay from a previous, still-running transition so rapid
            // toggles never stack stale frames.
            for subview in host.subviews where subview.identifier == overlayIdentifier {
                subview.removeFromSuperview()
            }

            guard let image = snapshot(of: host) else { continue }

            let overlay = PassthroughImageView(frame: host.bounds)
            overlay.identifier = overlayIdentifier
            overlay.image = image
            overlay.imageScaling = .scaleAxesIndependently
            overlay.autoresizingMask = [.width, .height]
            overlay.wantsLayer = true
            overlay.layer?.backgroundColor = NSColor.clear.cgColor
            overlay.alphaValue = 1
            host.addSubview(overlay, positioned: .above, relativeTo: nil)
            overlays.append(overlay)
        }


        guard !overlays.isEmpty else {
            appearance.apply()
            return
        }

        appearance.apply()

        // Give SwiftUI one run-loop turn to resolve the new colour scheme, then
        // reveal it under the old frame by fading the overlay out.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            guard overlays.contains(where: { $0.superview != nil }) else { return }
            // Make sure SwiftUI has committed the new colour scheme before the
            // old frame starts fading out.
            for window in windows {
                window.contentView?.displayIfNeeded()
            }

            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                for overlay in overlays {
                    overlay.animator().alphaValue = 0
                }
            } completionHandler: {
                for overlay in overlays {
                    overlay.removeFromSuperview()
                }
            }
        }
    }

    private static func snapshot(of view: NSView) -> NSImage? {
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            return nil
        }
        view.cacheDisplay(in: view.bounds, to: rep)
        let image = NSImage(size: view.bounds.size)
        image.addRepresentation(rep)
        return image
    }
}

/// Overlay that never intercepts clicks during the crossfade.
final class PassthroughImageView: NSImageView {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
