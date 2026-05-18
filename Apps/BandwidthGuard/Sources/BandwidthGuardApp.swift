import BandwidthGuardCore
import BandwidthGuardDiscovery
import BandwidthGuardUI
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}

@main
struct BandwidthGuardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = AppStore(discovery: WorkspaceAppDiscovery())
    @StateObject private var integration = SystemIntegrationStore()

    var body: some Scene {
        MenuBarExtra {
            RootView()
                .environmentObject(store)
                .frame(width: 460, height: 640)
        } label: {
            Label {
                Text("Bandwidth Guard")
            } icon: {
                Image("MenuBarLogo")
            }
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
