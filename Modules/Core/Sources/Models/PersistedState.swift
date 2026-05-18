import Foundation

struct PersistedState: Codable {
    var apps: [ManagedApp]
    var profiles: [NetworkProfile]
    var selectedProfileID: UUID
    var monitoringEnabled: Bool
    var dailyUsage: [DailyUsageRecord]

    init(
        apps: [ManagedApp],
        profiles: [NetworkProfile],
        selectedProfileID: UUID,
        monitoringEnabled: Bool,
        dailyUsage: [DailyUsageRecord]
    ) {
        self.apps = apps
        self.profiles = profiles
        self.selectedProfileID = selectedProfileID
        self.monitoringEnabled = monitoringEnabled
        self.dailyUsage = dailyUsage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        apps = try container.decode([ManagedApp].self, forKey: .apps)
        profiles = try container.decode([NetworkProfile].self, forKey: .profiles)
        selectedProfileID = try container.decode(UUID.self, forKey: .selectedProfileID)
        monitoringEnabled = try container.decode(Bool.self, forKey: .monitoringEnabled)
        dailyUsage = try container.decodeIfPresent([DailyUsageRecord].self, forKey: .dailyUsage) ?? []
    }
}
