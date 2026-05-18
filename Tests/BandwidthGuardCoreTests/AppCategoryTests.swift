@testable import BandwidthGuardCore
import XCTest

final class AppCategoryTests: XCTestCase {
    func testRawValuesStayStable() {
        XCTAssertEqual(
            AppCategory.allCases.map(\.rawValue),
            [
                "Browser",
                "Messaging",
                "Media",
                "Developer",
                "System",
                "Other",
            ]
        )
    }
}
