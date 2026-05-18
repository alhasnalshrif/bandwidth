import BandwidthGuardCore
import SwiftUI

struct SectionHeader: View {
    var title: String
    var trailing: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 4)
    }
}
