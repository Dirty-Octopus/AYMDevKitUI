import XCTest
import AYMDKUI

final class AliasModuleTests: XCTestCase {
    func testShortAliasReexportsTheCanonicalSurface() {
        let brand = DKBrand.ocean
        XCTAssertEqual(brand.name, "Ocean")

        let theme = DKTheme(scheme: .light, brand: brand)
        XCTAssertGreaterThan(DKContrast.ratio(theme.textPrimary, theme.surface), 7)

        let info = DKAppInfo(name: "AliasDemo", version: "1.0.0")
        XCTAssertEqual(info.name, "AliasDemo")
    }
}
