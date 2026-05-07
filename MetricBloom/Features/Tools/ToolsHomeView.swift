
import SwiftUI

struct ToolsHomeView: View {
    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    NavigationLink {
                        UnitConverterView()
                    } label: {
                        toolRow(title: "Unit converter", subtitle: "mm, µm, inches", icon: "ruler")
                    }
                    NavigationLink {
                        ToleranceStackView()
                    } label: {
                        toolRow(title: "Tolerance stack", subtitle: "Worst-case and RSS", icon: "sum")
                    }
                    NavigationLink {
                        ThermalExpansionView()
                    } label: {
                        toolRow(title: "Heat and clearance", subtitle: "ΔL and clearance impact", icon: "thermometer.medium")
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Tools")
    }

    private func toolRow(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(LinearGradient.mbBrand)
                .frame(width: 44, height: 44)
                .background(MBColor.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(MBColor.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(MBColor.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MBColor.textSecondary)
        }
        .padding(16)
        .background(MBColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MBColor.border, lineWidth: 1)
        )
    }
}
