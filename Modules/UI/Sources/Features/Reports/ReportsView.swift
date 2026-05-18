import BandwidthGuardCore
import SwiftUI

struct ReportsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 12) {
            Picker("Range", selection: $store.selectedRange) {
                ForEach(ReportRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 14)
            .padding(.top, 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(store.totalForSelectedRange.formattedBytes)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(store.blockedForSelectedRange.formattedBytes) blocked in saved \(store.selectedRange.rawValue.lowercased()) history")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)

            if store.trafficSummariesForSelectedRange.isEmpty {
                EmptyStateView(
                    title: "No traffic history",
                    message: "Real traffic history will appear here after the Network Extension is connected.",
                    icon: "chart.bar.xaxis"
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        if !store.dailyTotalsForSelectedRange.isEmpty {
                            SectionHeader(title: "Saved history", trailing: nil)
                                .padding(.horizontal, 4)

                            let maximum = max(1, store.dailyTotalsForSelectedRange.map(\.total).max() ?? 1)
                            ForEach(store.dailyTotalsForSelectedRange) { total in
                                DailyHistoryRow(total: total, maximum: maximum)
                            }
                        }

                        SectionHeader(title: "Apps", trailing: nil)
                            .padding(.horizontal, 4)

                        let maximum = max(1, store.trafficSummariesForSelectedRange.map(\.total).max() ?? 1)
                        ForEach(store.trafficSummariesForSelectedRange) { summary in
                            ReportRow(summary: summary, maximum: maximum)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

struct DailyHistoryRow: View {
    var total: DailyTrafficTotal
    var maximum: Int64

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(displayDate)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(total.total.formattedBytes)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }

            GeometryReader { proxy in
                let ratio = CGFloat(Double(total.total) / Double(maximum))
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: max(4, proxy.size.width * ratio))
                    Spacer(minLength: 0)
                }
            }
            .frame(height: 8)
            .background(RoundedRectangle(cornerRadius: 4).fill(Color(nsColor: .separatorColor).opacity(0.18)))

            HStack(spacing: 10) {
                Label(total.downloaded.formattedBytes, systemImage: "arrow.down")
                Label(total.uploaded.formattedBytes, systemImage: "arrow.up")
                Label(total.blocked.formattedBytes, systemImage: "hand.raised")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))
    }

    private var displayDate: String {
        let parts = total.dateKey.split(separator: "-")
        guard let year = parts.first, parts.count == 3 else {
            return total.dateKey
        }
        let month = parts[parts.index(after: parts.startIndex)]
        let day = parts[parts.index(parts.startIndex, offsetBy: 2)]
        return "\(month)/\(day)/\(year)"
    }
}

struct ReportRow: View {
    var summary: AppTrafficSummary
    var maximum: Int64

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(categoryColor)
                    .frame(width: 34, height: 34)
                    .background(RoundedRectangle(cornerRadius: 7).fill(categoryColor.opacity(0.13)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(summary.appName)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    Text(summary.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(summary.total.formattedBytes)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }

            GeometryReader { proxy in
                let ratio = CGFloat(Double(summary.total) / Double(maximum))
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(categoryColor)
                        .frame(width: max(4, proxy.size.width * ratio))
                    Spacer(minLength: 0)
                }
            }
            .frame(height: 8)
            .background(RoundedRectangle(cornerRadius: 4).fill(Color(nsColor: .separatorColor).opacity(0.18)))

            HStack(spacing: 10) {
                Label(summary.downloaded.formattedBytes, systemImage: "arrow.down")
                Label(summary.uploaded.formattedBytes, systemImage: "arrow.up")
                Label(summary.blocked.formattedBytes, systemImage: "hand.raised")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))
    }

    private var categoryIcon: String {
        switch summary.category {
        case .browser:
            "safari"
        case .messaging:
            "bubble.left.and.bubble.right"
        case .media:
            "play.rectangle"
        case .developer:
            "hammer"
        case .system:
            "gearshape"
        case .other:
            "app"
        }
    }

    private var categoryColor: Color {
        switch summary.category {
        case .browser:
            .green
        case .messaging:
            .blue
        case .media:
            .pink
        case .developer:
            .orange
        case .system:
            .gray
        case .other:
            .teal
        }
    }
}
