
import SwiftUI
import UIKit

struct CheckHomeView: View {
    @EnvironmentObject private var stores: AppStores
    @Binding var path: NavigationPath

    @State private var kind: CheckKind = .shaftHole
    @State private var holeMin = "10.0"
    @State private var holeMax = "10.025"
    @State private var shaftMin = "9.975"
    @State private var shaftMax = "10.0"
    @State private var minClearance = "0.01"
    @State private var useMinClearance = true
    @State private var jointPress = false
    @State private var maxInterference = "0.05"

    @State private var cMinText = "0.02"
    @State private var cMaxText = "0.06"
    @State private var cReqText = "0.01"
    @State private var cUseReq = true

    @State private var validationMessage: String?

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    kindPicker
                    if kind == .shaftHole {
                        shaftHoleCard
                    } else {
                        clearanceOnlyCard
                    }
                    if let validationMessage {
                        Text(validationMessage)
                            .font(.footnote)
                            .foregroundStyle(MBColor.critical)
                    }
                    MBGradientButton(title: "Calculate", isEnabled: canRun) {
                        runCheck()
                    }
                    NavigationLink(value: "history") {
                        rowLabel("Check history", icon: "clock.arrow.circlepath")
                    }
                    NavigationLink(value: "compare") {
                        rowLabel("Compare scenarios", icon: "square.split.2x1")
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Check")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: stores.catalogPreset) { preset in
            guard let preset else { return }
            applyPreset(preset)
            kind = .shaftHole
            stores.catalogPreset = nil
        }
    }

    private var shaftHoleCard: some View {
        MBCard {
            VStack(spacing: 14) {
                MBNumericField(title: "Hole, min (mm)", text: $holeMin)
                MBNumericField(title: "Hole, max (mm)", text: $holeMax)
                MBNumericField(title: "Shaft, min (mm)", text: $shaftMin)
                MBNumericField(title: "Shaft, max (mm)", text: $shaftMax)
                Toggle("Interference / press (overlap allowed)", isOn: $jointPress)
                    .tint(MBColor.accentOrange)
                    .foregroundStyle(MBColor.textPrimary)
                if jointPress {
                    MBNumericField(title: "Max. allowed overlap (mm)", text: $maxInterference)
                }
                Toggle("Enforce min. clearance", isOn: $useMinClearance)
                    .tint(MBColor.accentOrange)
                    .foregroundStyle(MBColor.textPrimary)
                if useMinClearance {
                    MBNumericField(title: "Min. allowed clearance (mm)", text: $minClearance)
                }
            }
        }
    }

    private var clearanceOnlyCard: some View {
        MBCard {
            VStack(spacing: 14) {
                Text("Enter a known clearance range (mm).")
                    .font(.caption)
                    .foregroundStyle(MBColor.textSecondary)
                MBNumericField(title: "Clearance, min", text: $cMinText)
                MBNumericField(title: "Clearance, max", text: $cMaxText)
                Toggle("Min. required clearance", isOn: $cUseReq)
                    .tint(MBColor.accentOrange)
                    .foregroundStyle(MBColor.textPrimary)
                if cUseReq {
                    MBNumericField(title: "Min. allowed (mm)", text: $cReqText)
                }
            }
        }
    }

    private func rowLabel(_ title: String, icon: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: icon)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(MBColor.textSecondary)
        .padding(14)
        .background(MBColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(MBColor.border, lineWidth: 1)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick check")
                .font(.title2.bold())
                .foregroundStyle(MBColor.textPrimary)
            Text(kind == .shaftHole
                ? "Enter limit dimensions for hole and shaft — the app estimates clearance and Bloom Score."
                : "Enter a clearance band directly — useful when you are not breaking the stack into parts.")
                .font(.subheadline)
                .foregroundStyle(MBColor.textSecondary)
        }
    }

    private var kindPicker: some View {
        MBCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Task type")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MBColor.textSecondary)
                Picker("Type", selection: $kind) {
                    ForEach(CheckKind.allCases) { k in
                        Text(k.rawValue).tag(k)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private func applyPreset(_ p: ShaftHoleInput) {
        holeMin = format(p.holeMin)
        holeMax = format(p.holeMax)
        shaftMin = format(p.shaftMin)
        shaftMax = format(p.shaftMax)
        jointPress = p.jointIntent == .intendedPress
        if let m = p.maxInterferenceMm {
            maxInterference = format(m)
        }
        if let m = p.minRequiredClearance {
            useMinClearance = true
            minClearance = format(m)
        }
    }

    private func format(_ v: Double) -> String {
        String(format: "%g", v)
    }

    private func parsedShaftHole() -> ShaftHoleInput? {
        guard
            let hMin = MBNumberParse.double(holeMin),
            let hMax = MBNumberParse.double(holeMax),
            let sMin = MBNumberParse.double(shaftMin),
            let sMax = MBNumberParse.double(shaftMax)
        else { return nil }
        guard hMax >= hMin, sMax >= sMin else { return nil }
        let req: Double? = useMinClearance ? MBNumberParse.double(minClearance) : nil
        if useMinClearance && req == nil { return nil }
        let maxI: Double?
        if jointPress {
            maxI = MBNumberParse.double(maxInterference) ?? 0.05
        } else {
            maxI = nil
        }
        return ShaftHoleInput(
            holeMin: hMin,
            holeMax: hMax,
            shaftMin: sMin,
            shaftMax: sMax,
            minRequiredClearance: req,
            jointIntent: jointPress ? .intendedPress : .slidingClearance,
            maxInterferenceMm: jointPress ? maxI : nil
        )
    }

    private func parsedClearanceOnly() -> ClearanceOnlyInput? {
        guard let mn = MBNumberParse.double(cMinText), let mx = MBNumberParse.double(cMaxText) else { return nil }
        guard mx >= mn else { return nil }
        let req: Double? = cUseReq ? MBNumberParse.double(cReqText) : nil
        if cUseReq && req == nil { return nil }
        return ClearanceOnlyInput(clearanceMin: mn, clearanceMax: mx, minRequired: req)
    }

    private var canRun: Bool {
        switch kind {
        case .shaftHole: return parsedShaftHole() != nil
        case .clearanceOnly: return parsedClearanceOnly() != nil
        }
    }

    private func runCheck() {
        validationMessage = nil
        let result: CheckResult?
        switch kind {
        case .shaftHole:
            guard let i = parsedShaftHole() else {
                validationMessage = "Check numeric input and that max ≥ min."
                return
            }
            result = BloomCalculator.evaluateShaftHole(i)
        case .clearanceOnly:
            guard let i = parsedClearanceOnly() else {
                validationMessage = "Check numeric input and that max ≥ min."
                return
            }
            result = BloomCalculator.evaluateClearanceOnly(i)
        }
        guard let result else { return }
        stores.recordCheck(result)
        if stores.settings.hapticsEnabled {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        path.append(result)
    }
}
