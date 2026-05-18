import AppKit
import BandwidthGuardCore
import SwiftUI

struct AppIconView: View {
    var path: String?

    var body: some View {
        Group {
            if let image = icon {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "app.dashed")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 34, height: 34)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    private var icon: NSImage? {
        guard let path else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: path)
    }
}
