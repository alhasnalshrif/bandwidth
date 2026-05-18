import AppKit
import BandwidthGuardCore
import Foundation

public struct WorkspaceAppDiscovery: AppDiscovery {
    public init() {}

    public func runningApps() -> [RunningAppSnapshot] {
        NSWorkspace.shared.runningApplications
            .filter { app in
                guard app.activationPolicy == .regular || app.activationPolicy == .accessory else {
                    return false
                }
                return app.bundleIdentifier != nil
            }
            .compactMap { app in
                guard let bundleIdentifier = app.bundleIdentifier else {
                    return nil
                }

                let name = app.localizedName ?? URL(fileURLWithPath: app.executableURL?.path ?? bundleIdentifier).lastPathComponent
                return RunningAppSnapshot(
                    bundleIdentifier: bundleIdentifier,
                    name: name,
                    executablePath: app.bundleURL?.path ?? app.executableURL?.path,
                    category: categorize(bundleIdentifier: bundleIdentifier, name: name)
                )
            }
            .uniqued(on: \.bundleIdentifier)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func categorize(bundleIdentifier: String, name: String) -> AppCategory {
        let key = "\(bundleIdentifier) \(name)".lowercased()

        let isBrowser = key.contains("safari") || key.contains("chrome") || key.contains("firefox") || key.contains("browser") || key
            .contains("arc")
        let isMessaging = key.contains("telegram") || key.contains("slack") || key.contains("discord") || key.contains("whatsapp") || key
            .contains("messages")
        let isMedia = key.contains("music") || key.contains("vlc") || key.contains("youtube") || key.contains("tv")
        let isDeveloper = key.contains("xcode") || key.contains("terminal") || key.contains("iterm") || key.contains("code") || key
            .contains("github")

        if isBrowser {
            return .browser
        }
        if isMessaging {
            return .messaging
        }
        if isMedia {
            return .media
        }
        if isDeveloper {
            return .developer
        }
        if bundleIdentifier.hasPrefix("com.apple.") {
            return .system
        }
        return .other
    }
}

private extension Array {
    func uniqued<Key: Hashable>(on keyPath: KeyPath<Element, Key>) -> [Element] {
        var seen = Set<Key>()
        return filter { element in
            seen.insert(element[keyPath: keyPath]).inserted
        }
    }
}
