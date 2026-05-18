import Foundation

public enum AppCategory: String, Codable, CaseIterable, Sendable {
    case browser = "Browser"
    case messaging = "Messaging"
    case media = "Media"
    case developer = "Developer"
    case system = "System"
    case other = "Other"
}
