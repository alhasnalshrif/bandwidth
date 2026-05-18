import Foundation

public struct AppTrafficSummary: Identifiable, Equatable, Sendable {
    public var id: String { bundleIdentifier }
    public var bundleIdentifier: String
    public var appName: String
    public var category: AppCategory
    public var downloaded: Int64
    public var uploaded: Int64
    public var blocked: Int64

    public var total: Int64 { downloaded + uploaded }

    public init(bundleIdentifier: String, appName: String, category: AppCategory, downloaded: Int64, uploaded: Int64, blocked: Int64) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.category = category
        self.downloaded = downloaded
        self.uploaded = uploaded
        self.blocked = blocked
    }
}
