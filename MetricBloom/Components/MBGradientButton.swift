
import SwiftUI

struct MBGradientButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(MBColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LinearGradient.mbBrand)
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(MBColor.glowSoft, lineWidth: 1)
                    }
                    .shadow(color: MBColor.accentOrange.opacity(isEnabled ? 0.45 : 0), radius: 12, y: 4)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }
}
