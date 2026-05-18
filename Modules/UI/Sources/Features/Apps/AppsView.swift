import BandwidthGuardCore
import SwiftUI

struct AppsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 10) {
            SearchField(text: $store.searchText)
                .padding(.horizontal, 14)
                .padding(.top, 12)

            if store.filteredApps.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.filteredApps) { app in
                            AppRuleRow(app: app) {
                                store.toggleAllowed(for: app)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

struct AppRuleRow: View {
    var app: ManagedApp
    var onToggle: () -> Void

    var body: some View {
        HStack(spacing: 11) {
            AppIconView(path: app.executablePath)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(app.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    CategoryBadge(category: app.category)
                }

                Text(app.bundleIdentifier)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label(app.totalToday.formattedBytes, systemImage: "arrow.up.arrow.down")
                    Label(app.blockedBytes.formattedBytes, systemImage: "hand.raised")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { app.isAllowed },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .help(app.isAllowed ? "Allowed on this profile" : "Blocked on this profile")
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))
    }
}
