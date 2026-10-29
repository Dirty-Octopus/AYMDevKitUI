import XCTest
import AppKit
@testable import AYMDevKitUI

@MainActor
final class WindowGeometryTests: XCTestCase {
    func testPresetResizeKeepsTheVisualTopLeftCorner() {
        let current = NSRect(x: 240, y: 120, width: 1040, height: 720)
        let target = DKWindowManager.anchoredFrame(
            currentFrame: current,
            newFrameSize: CGSize(width: 1380, height: 920),
            visibleFrame: nil
        )

        XCTAssertEqual(target.minX, current.minX, accuracy: 0.001)
        XCTAssertEqual(target.maxY, current.maxY, accuracy: 0.001)
        XCTAssertEqual(target.width, 1380, accuracy: 0.001)
        XCTAssertEqual(target.height, 920, accuracy: 0.001)
    }

    func testResizeClampsToTheVisibleScreenWithoutChangingTheAnchorNeedlessly() {
        let visible = NSRect(x: 0, y: 25, width: 1440, height: 975)
        let current = NSRect(x: 100, y: 150, width: 1040, height: 720)
        let target = DKWindowManager.anchoredFrame(
            currentFrame: current,
            newFrameSize: CGSize(width: 1380, height: 920),
            visibleFrame: visible
        )

        XCTAssertGreaterThanOrEqual(target.minX, visible.minX)
        XCTAssertGreaterThanOrEqual(target.minY, visible.minY)
        XCTAssertLessThanOrEqual(target.maxX, visible.maxX)
        XCTAssertLessThanOrEqual(target.maxY, visible.maxY)
    }

    func testShrinkingAlsoKeepsTheTopLeftCorner() {
        let current = NSRect(x: 50, y: 60, width: 1380, height: 920)
        let target = DKWindowManager.anchoredFrame(
            currentFrame: current,
            newFrameSize: CGSize(width: 1040, height: 720),
            visibleFrame: nil
        )

        XCTAssertEqual(target.minX, current.minX, accuracy: 0.001)
        XCTAssertEqual(target.maxY, current.maxY, accuracy: 0.001)
    }
}
