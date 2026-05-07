
import SwiftUI

struct MBNumericField: View {
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .decimalPad

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MBColor.textSecondary)
            TextField("0", text: $text)
                .keyboardType(keyboard)
                .font(.body.monospacedDigit())
                .foregroundStyle(MBColor.textPrimary)
                .padding(12)
                .background(MBColor.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(MBColor.border, lineWidth: 1)
                )
        }
    }
}

enum MBNumberParse {
    static func double(_ s: String) -> Double? {
        let trimmed = s.replacingOccurrences(of: ",", with: ".")
        return Double(trimmed)
    }
}
