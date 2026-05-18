import Foundation

public struct DailyUsageRecord: Identifiable, Codable, Equatable, Sendable {
    public var id: String { "\(dateKey)-\(bundleIdentifier)" }
    public var dateKey: String
    public var bundleIdentifier: String
    public var appName: String
    public var category: AppCategory
    public var downloaded: Int64
    public var uploaded: Int64
    public var blocked: Int64

    public var total: Int64 { downloaded + uploaded }

    public init(dateKey: String, bundleIdentifier: String, appName: String, category: AppCategory, downloaded: Int64, uploaded: Int64, blocked: Int64) {
        self.dateKey = dateKey
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.category = category
        self.downloaded = downloaded
        self.uploaded = uploaded
        self.blocked = blocked
    }
}
