import BandwidthGuardCore
import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "speedometer")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Bandwidth Guard")
                        .font(.title2.weight(.semibold))
                    Text("Menu bar bandwidth controls for macOS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            SettingsLine(title: "Monitor", detail: store.monitoringEnabled ? "Running" : "Paused", icon: store.monitoringEnabled ? "play.circle.fill" : "pause.circle.fill")
            SettingsLine(title: "Active profile", detail: store.selectedProfile.name, icon: "wifi.router")
            SettingsLine(title: "Tracked apps", detail: "\(store.apps.count)", icon: "app.badge")
            SettingsLine(title: "Saved history", detail: "\(store.savedDayCount) days", icon: "calendar")

            if let appErrorMessage = store.appErrorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Storage warning", systemImage: "exclamationmark.triangle")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.orange)
                    Text(appErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.orange.opacity(0.1)))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Traffic control mode")
                    .font(.system(size: 13, weight: .semibold))
                Text("Rules, profiles, and history are saved in the app. Live traffic blocking still needs a signed Network Extension target and Apple entitlements before macOS will allow real packet filtering.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))

            Spacer()
        }
        .padding(18)
    }
}

struct SettingsLine: View {
    var title: String
    var detail: String
    var icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(Color.accentColor)
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Spacer()
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
