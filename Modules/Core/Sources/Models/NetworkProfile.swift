import Foundation

public struct NetworkProfile: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var networkHint: String
    public var isMetered: Bool
    public var defaultAllowed: Bool
    public var appRules: [String: Bool]

    public init(id: UUID, name: String, networkHint: String, isMetered: Bool, defaultAllowed: Bool, appRules: [String: Bool]) {
        self.id = id
        self.name = name
        self.networkHint = networkHint
        self.isMetered = isMetered
        self.defaultAllowed = defaultAllowed
        self.appRules = appRules
    }

    public static let defaults: [NetworkProfile] = [
        NetworkProfile(
            id: UUID(),
            name: "Home Wi-Fi",
            networkHint: "trusted",
            isMetered: false,
            defaultAllowed: true,
            appRules: [:]
        ),
        NetworkProfile(
            id: UUID(),
            name: "Phone Hotspot",
            networkHint: "metered",
            isMetered: true,
            defaultAllowed: false,
            appRules: [:]
        ),
        NetworkProfile(
            id: UUID(),
            name: "Public Wi-Fi",
            networkHint: "shared",
            isMetered: true,
            defaultAllowed: false,
            appRules: [:]
        )
    ]

    public static var fallback: NetworkProfile {
        defaults.first ?? NetworkProfile(
            id: UUID(),
            name: "Default",
            networkHint: "local",
            isMetered: false,
            defaultAllowed: true,
            appRules: [:]
        )
    }
}
