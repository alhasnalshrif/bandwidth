import AppKit
import BandwidthGuardCore
import SwiftUI

enum MainSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case apps = "Apps"
    case reports = "Reports"
    case networks = "Networks"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .overview:
            "gauge.with.dots.needle.bottom.50percent"
        case .apps:
            "app.badge"
        case .reports:
            "chart.bar.xaxis"
        case .networks:
            "wifi.router"
        }
    }
}

public struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var section: MainSection = .overview

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HeaderView()

            Picker("Section", selection: $section) {
                ForEach(MainSection.allCases) { section in
                    Label(section.rawValue, systemImage: section.icon)
                        .tag(section)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 14)
            .padding(.bottom, 10)

            Divider()

            Group {
                switch section {
                case .overview:
                    OverviewView()
                case .apps:
                    AppsView()
                case .reports:
                    ReportsView()
                case .networks:
                    NetworksView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct HeaderView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bandwidth Guard")
                        .font(.system(size: 20, weight: .semibold))
                    Text(store.selectedProfile.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    store.toggleMonitoring()
                } label: {
                    Label(store.monitoringEnabled ? "Pause" : "Resume", systemImage: store.monitoringEnabled ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .help(store.monitoringEnabled ? "Pause monitoring" : "Resume monitoring")

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("Quit", systemImage: "power")
                }
                .controlSize(.small)
                .help("Quit Bandwidth Guard")
            }

            HStack(spacing: 10) {
                MetricPill(
                    title: "Used today",
                    value: (store.totalDownloadedToday + store.totalUploadedToday).formattedBytes,
                    icon: "arrow.up.arrow.down"
                )
                MetricPill(title: "Blocked", value: store.totalBlocked.formattedBytes, icon: "hand.raised.fill")
            }
        }
        .padding(14)
    }
}

struct MetricPill: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(RoundedRectangle(cornerRadius: 7).fill(Color.accentColor))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 54)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))
    }
}
