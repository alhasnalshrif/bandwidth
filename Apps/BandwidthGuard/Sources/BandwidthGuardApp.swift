import BandwidthGuardCore
import BandwidthGuardDiscovery
import BandwidthGuardUI
import SwiftUI

@main
struct BandwidthGuardApp: App {
    @StateObject private var store = AppStore(discovery: WorkspaceAppDiscovery())
    @StateObject private var integration = SystemIntegrationStore()

    var body: some Scene {
        MenuBarExtra {
            RootView()
                .environmentObject(store)
                .frame(width: 460, height: 640)
        } label: {
            Label("Bandwidth Guard", systemImage: store.monitoringEnabled ? "speedometer" : "speedometer")
        }
        .menuBarExtraStyle(.window)

        Settings {
            AppSettingsView()
                .environmentObject(store)
                .environmentObject(integration)
                .frame(width: 560, height: 680)
        }
    }
}
