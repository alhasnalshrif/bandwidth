import Foundation
import NetworkExtension
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

    func requestNetworkExtensionApproval() {
        networkExtensionDetail = "Requesting approval..."

        NEFilterManager.shared().loadFromPreferences { [weak self] error in
            Task { @MainActor in
                guard let self else {
                    return
                }

                if let error {
                    self.errorMessage = error.localizedDescription
                    self.refreshNetworkExtensionStatus()
                    return
                }

                let configuration = NEFilterProviderConfiguration()
                configuration.filterSockets = true
                configuration.filterPackets = false

                let manager = NEFilterManager.shared()
                manager.localizedDescription = "Bandwidth Guard"
                manager.providerConfiguration = configuration
                manager.isEnabled = true

                manager.saveToPreferences { [weak self] error in
                    Task { @MainActor in
                        guard let self else {
                            return
                        }

                        if let error {
                            self.errorMessage = error.localizedDescription
                            self.networkExtensionDetail = "Approval failed"
                        } else {
                            self.errorMessage = nil
                            self.networkExtensionDetail = "Enabled or waiting for user approval"
                        }
                    }
                }
            }
        }
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
