import BandwidthGuardCore
import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    SummaryTile(title: "Download", value: store.totalDownloadedToday.formattedBytes, icon: "arrow.down", tint: .green)
                    SummaryTile(title: "Upload", value: store.totalUploadedToday.formattedBytes, icon: "arrow.up", tint: .orange)
                    SummaryTile(title: "Apps", value: "\(store.apps.count)", icon: "square.grid.3x3", tint: .blue)
                }

                SectionHeader(title: "Top apps", trailing: "Running apps")

                VStack(spacing: 8) {
                    ForEach(store.apps.sorted { $0.totalToday > $1.totalToday }.prefix(6)) { app in
                        CompactUsageRow(app: app, maximum: max(1, store.apps.map(\.totalToday).max() ?? 1))
                    }
                }

                SectionHeader(title: "Quick controls", trailing: nil)

                HStack(spacing: 10) {
                    Button {
                        store.setDefaultAllowed(true)
                    } label: {
                        Label("Allow default", systemImage: "checkmark.shield")
                    }
                    .controlSize(.small)

                    Button {
                        store.setDefaultAllowed(false)
                    } label: {
                        Label("Block default", systemImage: "lock.shield")
                    }
                    .controlSize(.small)

                    Spacer()

                    Button(role: .destructive) {
                        store.resetUsage()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .controlSize(.small)
                    .help("Reset usage counters")
                }
                .padding(.top, 2)
            }
            .padding(14)
        }
    }
}

struct SummaryTile: View {
    var title: String
    var value: String
    var icon: String
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 26, height: 26)
                .background(RoundedRectangle(cornerRadius: 7).fill(tint.opacity(0.14)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))
    }
}

struct CompactUsageRow: View {
    var app: ManagedApp
    var maximum: Int64

    var body: some View {
        HStack(spacing: 10) {
            AppIconView(path: app.executablePath)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(app.name)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                    Text(app.totalToday.formattedBytes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                GeometryReader { proxy in
                    let width = max(3, proxy.size.width * CGFloat(Double(app.totalToday) / Double(maximum)))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(app.isAllowed ? Color.green : Color.red)
                        .frame(width: width)
                }
                .frame(height: 6)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color(nsColor: .separatorColor).opacity(0.22)))
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .textBackgroundColor)))
    }
}
