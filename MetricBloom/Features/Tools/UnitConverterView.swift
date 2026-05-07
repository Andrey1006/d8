
import SwiftUI

struct UnitConverterView: View {
    @State private var mmText = "1"

    private var mm: Double? { MBNumberParse.double(mmText) }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    MBCard {
                        MBNumericField(title: "Value in millimeters", text: $mmText)
                    }
                    if let mm {
                        MBCard {
                            VStack(alignment: .leading, spacing: 10) {
                                row("Micrometers", String(format: "%.3f µm", mm * 1000))
                                row("Inches", String(format: "%.6f in", mm / 25.4))
                            }
                        }
                    } else {
                        Text("Enter a number")
                            .font(.footnote)
                            .foregroundStyle(MBColor.textSecondary)
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Converter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(MBColor.textSecondary)
            Spacer()
            Text(value)
                .font(.body.weight(.semibold).monospacedDigit())
                .foregroundStyle(MBColor.textPrimary)
        }
        .font(.subheadline)
    }
}
