public protocol AppDiscovery: Sendable {
    func runningApps() -> [RunningAppSnapshot]
}
