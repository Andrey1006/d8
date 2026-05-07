
import SwiftUI

struct MBSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MBColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(MBColor.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(MBColor.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
