import XCTest
@testable import BandwidthGuardCore

final class TrafficModelTests: XCTestCase {
    func testManagedAppTotalsUseMatchingReportRange() {
        let app = ManagedApp(
            bundleIdentifier: "com.example.browser",
            name: "Example Browser",
            executablePath: nil,
            category: .browser,
            isAllowed: true,
            downloadedToday: 100,
            uploadedToday: 25,
            downloadedThisWeek: 700,
            uploadedThisWeek: 125,
            downloadedThisMonth: 3_000,
            uploadedThisMonth: 500,
            blockedBytes: 50,
            lastSeen: Date(timeIntervalSince1970: 0)
        )

        XCTAssertEqual(app.totalToday, 125)
        XCTAssertEqual(app.totalThisWeek, 825)
        XCTAssertEqual(app.totalThisMonth, 3_500)
        XCTAssertEqual(app.total(for: .today), 125)
        XCTAssertEqual(app.total(for: .week), 825)
        XCTAssertEqual(app.total(for: .month), 3_500)
    }

    func testSummaryAndDailyTotalsExcludeBlockedTrafficFromUsageTotal() {
        let summary = AppTrafficSummary(
            bundleIdentifier: "com.example.editor",
            appName: "Example Editor",
            category: .developer,
            downloaded: 400,
            uploaded: 75,
            blocked: 200
        )
        let dailyTotal = DailyTrafficTotal(dateKey: "2026-05-18", downloaded: 1_000, uploaded: 250, blocked: 500)

        XCTAssertEqual(summary.id, "com.example.editor")
        XCTAssertEqual(summary.total, 475)
        XCTAssertEqual(dailyTotal.id, "2026-05-18")
        XCTAssertEqual(dailyTotal.total, 1_250)
    }

    func testFormattedBytesUsesReadableUnits() {
        let value = Int64(1_024).formattedBytes

        XCTAssertTrue(value.contains("KB") || value.contains("kB"), "Expected a kilobyte unit, got: \(value)")
    }
}
