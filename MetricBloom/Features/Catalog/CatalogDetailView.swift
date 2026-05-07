
import SwiftUI
import UIKit

struct CatalogDetailView: View {
    @EnvironmentObject private var stores: AppStores
    let fit: CatalogFit
    @State private var nominalText = "10"

    private var nominal: Double? {
        MBNumberParse.double(nominalText.trimmingCharacters(in: .whitespaces))
    }

    private var scaledInput: ShaftHoleInput? {
        guard let n = nominal, n > 0 else { return nil }
        return fit.shaftHoleInput(forUserNominal: n)
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    MBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(fit.title)
                                .font(.title3.bold())
                                .foregroundStyle(MBColor.textPrimary)
                            Text("\(fit.system) · \(fit.diameterRange)")
                                .font(.subheadline)
                                .foregroundStyle(MBColor.textSecondary)
                            Text(fit.description)
                                .font(.body)
                                .foregroundStyle(MBColor.textSecondary)
                        }
                    }
                    MBCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Nominal diameter (mm)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MBColor.textSecondary)
                            TextField("10", text: $nominalText)
                                .keyboardType(.decimalPad)
                                .font(.body.monospacedDigit())
                                .foregroundStyle(MBColor.textPrimary)
                                .padding(12)
                                .background(MBColor.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(MBColor.border, lineWidth: 1)
                                )
                            Text("Limits below are scaled linearly from reference \(String(format: "%.0f", CatalogData.referenceNominal)) mm (simplified).")
                                .font(.caption2)
                                .foregroundStyle(MBColor.textSecondary)
                        }
                    }
                    if let s = scaledInput {
                        MBCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Scaled limits")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(MBColor.textSecondary)
                                valueRow("Hole min", s.holeMin)
                                valueRow("Hole max", s.holeMax)
                                valueRow("Shaft min", s.shaftMin)
                                valueRow("Shaft max", s.shaftMax)
                                if let hint = s.minRequiredClearance {
                                    valueRow("Min. clearance (hint)", hint, suffix: " mm")
                                } else {
                                    Text("Min. clearance: depends on joint (interference / press).")
                                        .font(.caption)
                                        .foregroundStyle(MBColor.textSecondary)
                                }
                            }
                        }
                    }
                    MBGradientButton(title: "Use in Check", isEnabled: scaledInput != nil) {
                        guard let input = scaledInput else { return }
                        stores.applyCatalogPreset(input)
                        if stores.settings.hapticsEnabled {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    MBSecondaryButton(title: stores.isFavorite(fit.id) ? "Remove from favorites" : "Add to favorites") {
                        stores.toggleFavorite(fitId: fit.id)
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Fit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private func valueRow(_ title: String, _ value: Double, suffix: String = " mm") -> some View {
        HStack {
            Text(title)
                .foregroundStyle(MBColor.textSecondary)
            Spacer()
            Text(String(format: "%.4f%@", value, suffix))
                .font(.body.weight(.semibold).monospacedDigit())
                .foregroundStyle(MBColor.textPrimary)
        }
        .font(.subheadline)
    }
}
