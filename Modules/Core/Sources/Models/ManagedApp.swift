import Foundation

public struct ManagedApp: Identifiable, Codable, Equatable, Sendable {
    public var id: String {
        bundleIdentifier
    }

    public var bundleIdentifier: String
    public var name: String
    public var executablePath: String?
    public var category: AppCategory
    public var isAllowed: Bool
    public var downloadedToday: Int64
    public var uploadedToday: Int64
    public var downloadedThisWeek: Int64
    public var uploadedThisWeek: Int64
    public var downloadedThisMonth: Int64
    public var uploadedThisMonth: Int64
    public var blockedBytes: Int64
    public var lastSeen: Date

    public var totalToday: Int64 {
        downloadedToday + uploadedToday
    }

    public var totalThisWeek: Int64 {
        downloadedThisWeek + uploadedThisWeek
    }

    public var totalThisMonth: Int64 {
        downloadedThisMonth + uploadedThisMonth
    }

    public init(
        bundleIdentifier: String,
        name: String,
        executablePath: String?,
        category: AppCategory,
        isAllowed: Bool,
        downloadedToday: Int64,
        uploadedToday: Int64,
        downloadedThisWeek: Int64,
        uploadedThisWeek: Int64,
        downloadedThisMonth: Int64,
        uploadedThisMonth: Int64,
        blockedBytes: Int64,
        lastSeen: Date
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.executablePath = executablePath
        self.category = category
        self.isAllowed = isAllowed
        self.downloadedToday = downloadedToday
        self.uploadedToday = uploadedToday
        self.downloadedThisWeek = downloadedThisWeek
        self.uploadedThisWeek = uploadedThisWeek
        self.downloadedThisMonth = downloadedThisMonth
        self.uploadedThisMonth = uploadedThisMonth
        self.blockedBytes = blockedBytes
        self.lastSeen = lastSeen
    }

    public func total(for range: ReportRange) -> Int64 {
        switch range {
        case .today:
            totalToday
        case .week:
            totalThisWeek
        case .month:
            totalThisMonth
        }
    }
}
