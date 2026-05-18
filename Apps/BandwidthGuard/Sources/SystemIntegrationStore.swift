import Foundation
import ServiceManagement

@MainActor
final class SystemIntegrationStore: ObservableObject {
    @Published private(set) var launchAtLoginEnabled = false
    @Published private(set) var launchAtLoginDetail = "Checking..."
    @Published private(set) var installLocationDetail = "Checking..."
    @Published private(set) var networkExtensionDetail = "Not installed"
    @Published var errorMessage: String?

    init() {
        refresh()
    }

    func refresh() {
        refreshInstallLocation()
        refreshLaunchAtLogin()
        refreshNetworkExtensionStatus()
    }

    func setLaunchAtLoginEnabled(_ isEnabled: Bool) {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        refreshLaunchAtLogin()
    }

    private func refreshInstallLocation() {
        let bundlePath = Bundle.main.bundleURL.path(percentEncoded: false)
        if bundlePath.hasPrefix("/Applications/") {
            installLocationDetail = "Installed in Applications"
        } else {
            installLocationDetail = "Running outside Applications"
        }
    }

    private func refreshLaunchAtLogin() {
        switch SMAppService.mainApp.status {
        case .enabled:
            launchAtLoginEnabled = true
            launchAtLoginDetail = "Enabled"
        case .requiresApproval:
            launchAtLoginEnabled = true
            launchAtLoginDetail = "Needs approval in System Settings"
        case .notRegistered:
            launchAtLoginEnabled = false
            launchAtLoginDetail = "Disabled"
        case .notFound:
            launchAtLoginEnabled = false
            launchAtLoginDetail = "App service not found"
        @unknown default:
            launchAtLoginEnabled = false
            launchAtLoginDetail = "Unknown"
        }
    }

    private func refreshNetworkExtensionStatus() {
        networkExtensionDetail = "Target scaffolded; signing and entitlements required before install"
    }
}
