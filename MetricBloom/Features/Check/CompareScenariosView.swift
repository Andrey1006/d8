
import SwiftUI
import UIKit

struct CompareScenariosView: View {
    @EnvironmentObject private var stores: AppStores
    @Binding var path: NavigationPath

    @State private var aHoleMin = "10.0"
    @State private var aHoleMax = "10.025"
    @State private var aShaftMin = "9.975"
    @State private var aShaftMax = "10.0"
    @State private var aReq = "0.01"

    @State private var bHoleMin = "10.0"
    @State private var bHoleMax = "10.04"
    @State private var bShaftMin = "9.96"
    @State private var bShaftMax = "9.99"
    @State private var bReq = "0.01"

    @State private var saveTitle = ""

    private var resultA: CheckResult? {
        guard let input = parse(aHoleMin, aHoleMax, aShaftMin, aShaftMax, aReq) else { return nil }
        return BloomCalculator.evaluateShaftHole(input)
    }

    private var resultB: CheckResult? {
        guard let input = parse(bHoleMin, bHoleMax, bShaftMin, bShaftMax, bReq) else { return nil }
        return BloomCalculator.evaluateShaftHole(input)
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("Two parameter sets and Bloom Score. Open the full result or save the pair.")
                        .font(.subheadline)
                        .foregroundStyle(MBColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    scenarioCard(title: "Scenario A", holeMin: $aHoleMin, holeMax: $aHoleMax, shaftMin: $aShaftMin, shaftMax: $aShaftMax, req: $aReq)
                    scenarioCard(title: "Scenario B", holeMin: $bHoleMin, holeMax: $bHoleMax, shaftMin: $bShaftMin, shaftMax: $bShaftMax, req: $bReq)

                    HStack(alignment: .top, spacing: 12) {
                        resultColumn(title: "A", result: resultA)
                        resultColumn(title: "B", result: resultB)
                    }

                    if let a = resultA, let b = resultB {
                        MBCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Save scenario pair")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(MBColor.textSecondary)
                                TextField("Title", text: $saveTitle)
                                    .foregroundStyle(MBColor.textPrimary)
                                MBGradientButton(title: "Save A and B", isEnabled: !saveTitle.trimmingCharacters(in: .whitespaces).isEmpty) {
                                    stores.saveCompareScenario(title: saveTitle.trimmingCharacters(in: .whitespaces), a: a, b: b)
                                    if stores.settings.hapticsEnabled {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                            }
                        }
                    }

                    if !stores.compareScenarios.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Saved pairs")
                                .font(.headline)
                                .foregroundStyle(MBColor.textPrimary)
                            ForEach(stores.compareScenarios) { sc in
                                NavigationLink(value: sc) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(sc.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(MBColor.textPrimary)
                                            Text(sc.createdAt.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption2)
                                                .foregroundStyle(MBColor.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(MBColor.textSecondary)
                                    }
                                    .padding(12)
                                    .background(MBColor.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(MBColor.border, lineWidth: 1)
                                    )
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        stores.deleteCompareScenario(sc.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private func scenarioCard(
        title: String,
        holeMin: Binding<String>,
        holeMax: Binding<String>,
        shaftMin: Binding<String>,
        shaftMax: Binding<String>,
        req: Binding<String>
    ) -> some View {
        MBCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(MBColor.textPrimary)
                MBNumericField(title: "Hole min", text: holeMin)
                MBNumericField(title: "Hole max", text: holeMax)
                MBNumericField(title: "Shaft min", text: shaftMin)
                MBNumericField(title: "Shaft max", text: shaftMax)
                MBNumericField(title: "Min. clearance", text: req)
            }
        }
    }

    private func parse(
        _ hm: String,
        _ hM: String,
        _ sm: String,
        _ sM: String,
        _ r: String
    ) -> ShaftHoleInput? {
        guard let hMin = MBNumberParse.double(hm),
              let hMax = MBNumberParse.double(hM),
              let sMin = MBNumberParse.double(sm),
              let sMax = MBNumberParse.double(sM),
              let req = MBNumberParse.double(r),
              hMax >= hMin, sMax >= sMin
        else { return nil }
        return ShaftHoleInput(
            holeMin: hMin,
            holeMax: hMax,
            shaftMin: sMin,
            shaftMax: sMax,
            minRequiredClearance: req,
            jointIntent: .slidingClearance,
            maxInterferenceMm: nil
        )
    }

    @ViewBuilder
    private func resultColumn(title: String, result: CheckResult?) -> some View {
        if let result {
            VStack(spacing: 8) {
                NavigationLink(value: result) {
                    resultMini(title: title, result: result)
                }
                .buttonStyle(.plain)
                MBSecondaryButton(title: "Add to history") {
                    stores.recordCheck(result)
                    if stores.settings.hapticsEnabled {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            MBCard {
                Text("Invalid input (\(title))")
                    .font(.caption)
                    .foregroundStyle(MBColor.critical)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func resultMini(title: String, result: CheckResult) -> some View {
        MBCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MBColor.textSecondary)
                MBStatusPill(status: result.status)
                MBBloomGauge(score: result.bloomScore)
                Text(String(format: "Clearance %.3f…%.3f mm", result.clearanceMin, result.clearanceMax))
                    .font(.caption2)
                    .foregroundStyle(MBColor.textSecondary)
                Text("Details")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MBColor.accentOrange)
            }
        }
    }
}

struct CompareDetailView: View {
    @EnvironmentObject private var stores: AppStores
    @Environment(\.dismiss) private var dismiss
    let scenario: SavedCompareScenario

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(scenario.title)
                        .font(.title2.bold())
                        .foregroundStyle(MBColor.textPrimary)
                    Text("Created \(scenario.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(MBColor.textSecondary)
                    scenarioBlock(label: "Scenario A", result: scenario.resultA)
                    scenarioBlock(label: "Scenario B", result: scenario.resultB)
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    stores.deleteCompareScenario(scenario.id)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }

    private func scenarioBlock(label: String, result: CheckResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.headline)
                .foregroundStyle(MBColor.textPrimary)
            NavigationLink(value: result) {
                MBCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            MBStatusPill(status: result.status)
                            Spacer()
                            Text("Bloom \(result.bloomScore)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(MBColor.highlight)
                        }
                        Text(result.summary)
                            .font(.caption)
                            .foregroundStyle(MBColor.textSecondary)
                            .lineLimit(3)
                        Text("Open result →")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MBColor.accentOrange)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
