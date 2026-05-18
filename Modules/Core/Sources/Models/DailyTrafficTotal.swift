import Foundation

public struct DailyTrafficTotal: Identifiable, Equatable, Sendable {
    public var id: String { dateKey }
    public var dateKey: String
    public var downloaded: Int64
    public var uploaded: Int64
    public var blocked: Int64

    public var total: Int64 { downloaded + uploaded }

    public init(dateKey: String, downloaded: Int64, uploaded: Int64, blocked: Int64) {
        self.dateKey = dateKey
        self.downloaded = downloaded
        self.uploaded = uploaded
        self.blocked = blocked
    }
}
