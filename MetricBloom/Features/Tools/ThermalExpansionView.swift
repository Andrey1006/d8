
import SwiftUI

private enum ThermalMaterial: String, CaseIterable, Identifiable {
    case steel = "Steel (~12·10⁻⁶ K⁻¹)"
    case aluminum = "Aluminum (~23·10⁻⁶ K⁻¹)"
    case copper = "Copper (~17·10⁻⁶ K⁻¹)"
    case custom = "Custom α"

    var id: String { rawValue }

    var alphaPerK: Double? {
        switch self {
        case .steel: return 12e-6
        case .aluminum: return 23e-6
        case .copper: return 17e-6
        case .custom: return nil
        }
    }
}

struct ThermalExpansionView: View {
    @State private var material: ThermalMaterial = .steel
    @State private var lengthMm = "100"
    @State private var deltaT = "50"
    @State private var customAlpha = "17e-6"
    @State private var clearanceMm: String = ""

    private var alpha: Double? {
        if let a = material.alphaPerK { return a }
        let s = customAlpha.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".").uppercased()
        return Double(s)
    }

    private var length: Double? { MBNumberParse.double(lengthMm) }
    private var dT: Double? { MBNumberParse.double(deltaT) }

    private var deltaLmm: Double? {
        guard let a = alpha, let L = length, let t = dT else { return nil }
        return a * L * t
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Linear expansion ΔL = α · L · ΔT. Clearance impact is simplified (axis along growth direction).")
                        .font(.subheadline)
                        .foregroundStyle(MBColor.textSecondary)
                    MBCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Material / α")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MBColor.textSecondary)
                            Picker("Material", selection: $material) {
                                ForEach(ThermalMaterial.allCases) { m in
                                    Text(m.rawValue).tag(m)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(MBColor.accentOrange)
                            if material == .custom {
                                MBNumericField(title: "α, 1/K (e.g. 17e-6)", text: $customAlpha)
                            }
                            MBNumericField(title: "Length L, mm", text: $lengthMm)
                            MBNumericField(title: "ΔT, °C", text: $deltaT)
                        }
                    }
                    if let dL = deltaLmm {
                        MBCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Length change ΔL")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(MBColor.textSecondary)
                                Text(String(format: "%.4f mm", dL))
                                    .font(.title2.bold().monospacedDigit())
                                    .foregroundStyle(MBColor.textPrimary)
                            }
                        }
                    }
                    MBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Optional: nominal clearance (mm)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MBColor.textSecondary)
                            TextField("not set", text: $clearanceMm)
                                .keyboardType(.decimalPad)
                                .font(.body.monospacedDigit())
                                .foregroundStyle(MBColor.textPrimary)
                            if let dL = deltaLmm, let c0 = MBNumberParse.double(clearanceMm) {
                                Text(String(format: "Estimated clearance after heating (shaft grows in hole): ≈ %.4f mm", c0 - dL))
                                    .font(.caption)
                                    .foregroundStyle(MBColor.textSecondary)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Heat & clearance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
