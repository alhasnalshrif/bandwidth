import AppKit
import BandwidthGuardUI
import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject private var integration: SystemIntegrationStore
    @State private var launchAtLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SettingsView()

                Divider()

                GroupBox("Installation") {
                    VStack(alignment: .leading, spacing: 12) {
                        IntegrationRow(
                            title: "Install location",
                            detail: integration.installLocationDetail,
                            icon: "internaldrive"
                        )

                        Button {
                            NSWorkspace.shared.open(URL(filePath: "/Applications"))
                        } label: {
                            Label("Open Applications Folder", systemImage: "folder")
                        }
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                }

                GroupBox("Startup") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Open Bandwidth Guard at login", isOn: $launchAtLogin)
                            .onChange(of: launchAtLogin) { _, newValue in
                                guard newValue != integration.launchAtLoginEnabled else {
                                    return
                                }
                                integration.setLaunchAtLoginEnabled(newValue)
                            }

                        IntegrationRow(
                            title: "Launch at login",
                            detail: integration.launchAtLoginDetail,
                            icon: "arrow.clockwise.circle"
                        )

                        Button {
                            openSystemSettings("x-apple.systempreferences:com.apple.LoginItems-Settings.extension")
                        } label: {
                            Label("Open Login Items Settings", systemImage: "gear")
                        }
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                }

                GroupBox("Permissions") {
                    VStack(alignment: .leading, spacing: 12) {
                        IntegrationRow(title: "App discovery", detail: "Available", icon: "app.badge.checkmark")
                        IntegrationRow(title: "Network Extension", detail: integration.networkExtensionDetail, icon: "network")

                        Button {
                            integration.requestNetworkExtensionApproval()
                        } label: {
                            Label("Request Network Extension Approval", systemImage: "checkmark.shield")
                        }
                        .controlSize(.small)

                        Text(
                            "macOS will only allow packet filtering after the Network Extension is signed "
                                + "with the correct Apple entitlements and approved by the user."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                }

                if let errorMessage = integration.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .padding(18)
        }
        .onAppear {
            integration.refresh()
            launchAtLogin = integration.launchAtLoginEnabled
        }
        .onReceive(integration.$launchAtLoginEnabled) { isEnabled in
            launchAtLogin = isEnabled
        }
    }

    private func openSystemSettings(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}

private struct IntegrationRow: View {
    var title: String
    var detail: String
    var icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}
