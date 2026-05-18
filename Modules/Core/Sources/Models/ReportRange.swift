import Foundation

public enum ReportRange: String, CaseIterable, Identifiable, Sendable {
    case today = "Today"
    case week = "Week"
    case month = "Month"

    public var id: String { rawValue }
}
