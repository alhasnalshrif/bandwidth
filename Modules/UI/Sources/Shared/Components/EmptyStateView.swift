import BandwidthGuardCore
import SwiftUI

struct EmptyStateView: View {
    var title = "No matching apps"
    var message = "Running apps appear here automatically."
    var icon = "network.slash"

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
