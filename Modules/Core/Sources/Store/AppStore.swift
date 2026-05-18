import Combine
import Foundation

@MainActor
public final class AppStore: ObservableObject {
    @Published public var apps: [ManagedApp] = []
    @Published public var profiles: [NetworkProfile] = NetworkProfile.defaults
    @Published public var selectedProfileID: UUID = NetworkProfile.fallback.id
    @Published public var monitoringEnabled = true
    @Published public var selectedRange: ReportRange = .today
    @Published public var searchText = ""
    @Published public var lastUpdated = Date()
    @Published public private(set) var appErrorMessage: String?
    @Published public private(set) var dailyUsage: [DailyUsageRecord] = []

    private let persistence = PersistenceController()
    private let discovery: AppDiscovery
    private var timer: AnyCancellable?
    private var saveTick = 0
    private let calendar = Calendar.current

    public init(discovery: AppDiscovery) {
        self.discovery = discovery
        restore()
        start()
    }

    public var selectedProfile: NetworkProfile {
        profiles.first(where: { $0.id == selectedProfileID })
            ?? profiles.first
            ?? NetworkProfile.fallback
    }

    public var filteredApps: [ManagedApp] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = apps.sorted { $0.total(for: selectedRange) > $1.total(for: selectedRange) }

        guard !trimmed.isEmpty else {
            return source
        }

        return source.filter { app in
            app.name.localizedCaseInsensitiveContains(trimmed)
                || app.bundleIdentifier.localizedCaseInsensitiveContains(trimmed)
                || app.category.rawValue.localizedCaseInsensitiveContains(trimmed)
        }
    }

    public var totalDownloadedToday: Int64 {
        apps.reduce(0) { $0 + $1.downloadedToday }
    }

    public var totalUploadedToday: Int64 {
        apps.reduce(0) { $0 + $1.uploadedToday }
    }

    public var totalBlocked: Int64 {
        apps.reduce(0) { $0 + $1.blockedBytes }
    }

    public var totalForSelectedRange: Int64 {
        records(for: selectedRange).reduce(0) { $0 + $1.total }
    }

    public var blockedForSelectedRange: Int64 {
        records(for: selectedRange).reduce(0) { $0 + $1.blocked }
    }

    public var savedDayCount: Int {
        Set(dailyUsage.map(\.dateKey)).count
    }

    public var trafficSummariesForSelectedRange: [AppTrafficSummary] {
        let grouped = Dictionary(grouping: records(for: selectedRange), by: \.bundleIdentifier)
        return grouped.values.compactMap { records in
            guard let latest = records.max(by: { $0.dateKey < $1.dateKey }) else {
                return nil
            }
            return AppTrafficSummary(
                bundleIdentifier: latest.bundleIdentifier,
                appName: latest.appName,
                category: latest.category,
                downloaded: records.reduce(0) { $0 + $1.downloaded },
                uploaded: records.reduce(0) { $0 + $1.uploaded },
                blocked: records.reduce(0) { $0 + $1.blocked }
            )
        }
        .sorted {
            if $0.total == $1.total {
                return $0.blocked > $1.blocked
            }
            return $0.total > $1.total
        }
    }

    public var dailyTotalsForSelectedRange: [DailyTrafficTotal] {
        let grouped = Dictionary(grouping: records(for: selectedRange), by: \.dateKey)
        return grouped.map { dateKey, records in
            DailyTrafficTotal(
                dateKey: dateKey,
                downloaded: records.reduce(0) { $0 + $1.downloaded },
                uploaded: records.reduce(0) { $0 + $1.uploaded },
                blocked: records.reduce(0) { $0 + $1.blocked }
            )
        }
        .sorted { $0.dateKey < $1.dateKey }
    }

    public func toggleMonitoring() {
        monitoringEnabled.toggle()
        persist()
    }

    public func selectProfile(_ profile: NetworkProfile) {
        guard profiles.contains(where: { $0.id == profile.id }) else {
            return
        }
        selectedProfileID = profile.id
        applyProfileRules()
        persist()
    }

    public func toggleAllowed(for app: ManagedApp) {
        guard let index = apps.firstIndex(where: { $0.id == app.id }) else {
            return
        }
        apps[index].isAllowed.toggle()
        updateRule(bundleIdentifier: apps[index].bundleIdentifier, allowed: apps[index].isAllowed)
        persist()
    }

    public func setDefaultAllowed(_ isAllowed: Bool) {
        guard let index = profiles.firstIndex(where: { $0.id == selectedProfileID }) else {
            return
        }
        profiles[index].defaultAllowed = isAllowed
        for appIndex in apps.indices where profiles[index].appRules[apps[appIndex].bundleIdentifier] == nil {
            apps[appIndex].isAllowed = isAllowed
        }
        persist()
    }

    public func addProfile(name: String, networkHint: String, isMetered: Bool, defaultAllowed: Bool) {
        let profile = NetworkProfile(
            id: UUID(),
            name: sanitized(name, fallback: "New Profile"),
            networkHint: sanitized(networkHint, fallback: isMetered ? "metered" : "custom"),
            isMetered: isMetered,
            defaultAllowed: defaultAllowed,
            appRules: [:]
        )
        profiles.append(profile)
        selectProfile(profile)
    }

    public func updateProfile(_ profile: NetworkProfile, name: String, networkHint: String, isMetered: Bool, defaultAllowed: Bool) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
            return
        }

        profiles[index].name = sanitized(name, fallback: profile.name)
        profiles[index].networkHint = sanitized(networkHint, fallback: profile.networkHint)
        profiles[index].isMetered = isMetered
        profiles[index].defaultAllowed = defaultAllowed

        if profile.id == selectedProfileID {
            applyProfileRules()
        }

        persist()
    }

    public func deleteProfile(_ profile: NetworkProfile) {
        guard profiles.count > 1 else {
            return
        }

        profiles.removeAll { $0.id == profile.id }
        if selectedProfileID == profile.id {
            selectedProfileID = profiles.first?.id ?? NetworkProfile.fallback.id
            applyProfileRules()
        }
        persist()
    }

    public func resetRules(for profile: NetworkProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
            return
        }

        profiles[index].appRules.removeAll()
        if profile.id == selectedProfileID {
            applyProfileRules()
        }
        persist()
    }

    public func resetUsage() {
        clearUsageCounters()
        dailyUsage.removeAll()
        persist()
    }

    private func restore() {
        switch persistence.load() {
        case .success(.some(let state)):
            apps = state.apps
            profiles = sanitizedProfiles(state.profiles)
            selectedProfileID = state.selectedProfileID
            if !profiles.contains(where: { $0.id == selectedProfileID }) {
                selectedProfileID = selectedProfile.id
            }
            monitoringEnabled = state.monitoringEnabled
            applyProfileRules()
            clearUsageCounters()
            dailyUsage = []
            ingestRunningApps()
            persist()
        case .success(nil):
            ingestRunningApps()
            persist()
        case .failure(let error):
            appErrorMessage = error.localizedDescription
            profiles = sanitizedProfiles([])
            selectedProfileID = selectedProfile.id
            apps = []
            dailyUsage = []
            ingestRunningApps()
        }
    }

    private func start() {
        ingestRunningApps()

        timer = Timer.publish(every: 1.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.tick()
                }
            }
    }

    private func tick() {
        guard monitoringEnabled else {
            return
        }

        ingestRunningApps()
        lastUpdated = Date()

        saveTick += 1
        if saveTick >= 6 {
            saveTick = 0
            persist()
        }
    }

    private func ingestRunningApps() {
        let snapshots = discovery.runningApps()
        let runningBundleIdentifiers = Set(snapshots.map(\.bundleIdentifier))
        var existingIDs = Set(apps.map(\.bundleIdentifier))

        apps.removeAll { !runningBundleIdentifiers.contains($0.bundleIdentifier) }
        existingIDs = Set(apps.map(\.bundleIdentifier))

        for snapshot in snapshots where !existingIDs.contains(snapshot.bundleIdentifier) {
            apps.append(
                ManagedApp(
                    bundleIdentifier: snapshot.bundleIdentifier,
                    name: snapshot.name,
                    executablePath: snapshot.executablePath,
                    category: snapshot.category,
                    isAllowed: effectiveAllowed(for: snapshot.bundleIdentifier),
                    downloadedToday: 0,
                    uploadedToday: 0,
                    downloadedThisWeek: 0,
                    uploadedThisWeek: 0,
                    downloadedThisMonth: 0,
                    uploadedThisMonth: 0,
                    blockedBytes: 0,
                    lastSeen: Date()
                )
            )
            existingIDs.insert(snapshot.bundleIdentifier)
        }

        for index in apps.indices where snapshots.contains(where: { $0.bundleIdentifier == apps[index].bundleIdentifier }) {
            apps[index].lastSeen = Date()
        }
    }

    private func records(for range: ReportRange) -> [DailyUsageRecord] {
        dailyUsage.filter { record in
            isDateKey(record.dateKey, in: range)
        }
    }

    private func clearUsageCounters() {
        for index in apps.indices {
            apps[index].downloadedToday = 0
            apps[index].uploadedToday = 0
            apps[index].downloadedThisWeek = 0
            apps[index].uploadedThisWeek = 0
            apps[index].downloadedThisMonth = 0
            apps[index].uploadedThisMonth = 0
            apps[index].blockedBytes = 0
        }
    }

    private func updateRule(bundleIdentifier: String, allowed: Bool) {
        guard let index = profiles.firstIndex(where: { $0.id == selectedProfileID }) else {
            return
        }
        profiles[index].appRules[bundleIdentifier] = allowed
    }

    private func applyProfileRules() {
        let profile = selectedProfile
        for index in apps.indices {
            apps[index].isAllowed = profile.appRules[apps[index].bundleIdentifier] ?? profile.defaultAllowed
        }
    }

    private func effectiveAllowed(for bundleIdentifier: String) -> Bool {
        let profile = selectedProfile
        return profile.appRules[bundleIdentifier] ?? profile.defaultAllowed
    }

    private func sanitized(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private func sanitizedProfiles(_ loadedProfiles: [NetworkProfile]) -> [NetworkProfile] {
        loadedProfiles.isEmpty ? NetworkProfile.defaults : loadedProfiles
    }

    private func isDateKey(_ dateKey: String, in range: ReportRange) -> Bool {
        guard let date = Self.dateKeyFormatter.date(from: dateKey) else {
            return false
        }

        let now = Date()
        switch range {
        case .today:
            return calendar.isDate(date, inSameDayAs: now)
        case .week:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
                && calendar.isDate(date, equalTo: now, toGranularity: .yearForWeekOfYear)
        case .month:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
                && calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }

    private func persist() {
        let error = persistence.save(
            PersistedState(
                apps: apps,
                profiles: profiles,
                selectedProfileID: selectedProfileID,
                monitoringEnabled: monitoringEnabled,
                dailyUsage: dailyUsage
            )
        )
        if let error {
            appErrorMessage = error.localizedDescription
        }
    }

    private static let dateKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
