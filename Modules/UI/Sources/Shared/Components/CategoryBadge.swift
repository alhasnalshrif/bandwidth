import BandwidthGuardCore
import SwiftUI

struct CategoryBadge: View {
    var category: AppCategory

    var body: some View {
        Text(category.rawValue)
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(color)
            .background(Capsule().fill(color.opacity(0.12)))
            .lineLimit(1)
    }

    private var color: Color {
        switch category {
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
