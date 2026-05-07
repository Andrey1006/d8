
import Foundation

enum BloomCalculator {
    static func evaluateShaftHole(_ input: ShaftHoleInput) -> CheckResult {
        let clearanceMin = input.holeMin - input.shaftMax
        let clearanceMax = input.holeMax - input.shaftMin
        let band = max(clearanceMax - clearanceMin, 0)
        let required = input.minRequiredClearance ?? 0

        let status: MBCheckStatus
        switch input.jointIntent {
        case .slidingClearance:
            if clearanceMin < 0 {
                status = .critical
            } else if clearanceMin < required {
                status = .critical
            } else {
                status = slidingSecondary(clearanceMin: clearanceMin, required: required, band: band)
            }
        case .intendedPress:
            if clearanceMin >= 0 {
                status = .warn
            } else {
                let overlap = -clearanceMin
                if let cap = input.maxInterferenceMm {
                    if overlap > cap {
                        status = .critical
                    } else if overlap > cap * 0.85 {
                        status = .warn
                    } else {
                        status = .ok
                    }
                } else {
                    if overlap > 0.08 {
                        status = .critical
                    } else if overlap > 0.035 {
                        status = .warn
                    } else {
                        status = .ok
                    }
                }
            }
        }

        let bloomScore = score(
            clearanceMin: clearanceMin,
            clearanceMax: clearanceMax,
            required: required,
            status: status,
            jointIntent: input.jointIntent
        )

        let summary = makeShaftHoleSummary(
            input: input,
            clearanceMin: clearanceMin,
            clearanceMax: clearanceMax,
            required: required,
            status: status
        )

        return CheckResult(
            kind: .shaftHole,
            payload: .shaftHole(input),
            clearanceMin: clearanceMin,
            clearanceMax: clearanceMax,
            status: status,
            bloomScore: bloomScore,
            summary: summary
        )
    }

    static func evaluateClearanceOnly(_ input: ClearanceOnlyInput) -> CheckResult {
        let cMin = input.clearanceMin
        let cMax = input.clearanceMax
        let band = max(cMax - cMin, 0)
        let required = input.minRequired ?? 0

        let status: MBCheckStatus
        if cMin < 0 {
            status = .critical
        } else if cMin < required {
            status = .critical
        } else {
            status = slidingSecondary(clearanceMin: cMin, required: required, band: band)
        }

        let bloomScore = score(
            clearanceMin: cMin,
            clearanceMax: cMax,
            required: required,
            status: status,
            jointIntent: .slidingClearance
        )

        let summary = makeClearanceOnlySummary(
            clearanceMin: cMin,
            clearanceMax: cMax,
            required: required,
            status: status
        )

        return CheckResult(
            kind: .clearanceOnly,
            payload: .clearanceOnly(input),
            clearanceMin: cMin,
            clearanceMax: cMax,
            status: status,
            bloomScore: bloomScore,
            summary: summary
        )
    }

    private static func slidingSecondary(clearanceMin: Double, required: Double, band: Double) -> MBCheckStatus {
        let marginRatio: Double = required > 0 ? clearanceMin / required : min(clearanceMin * 1000, 10) / 10
        let spreadPenalty = band > 0.05 ? true : band > 0.02 && clearanceMin < 0.05
        if marginRatio < 1.35 || spreadPenalty {
            return .warn
        }
        return .ok
    }

    private static func score(
        clearanceMin: Double,
        clearanceMax: Double,
        required: Double,
        status: MBCheckStatus,
        jointIntent: ShaftJointIntent
    ) -> Int {
        let band = max(clearanceMax - clearanceMin, 0)
        switch status {
        case .critical:
            if jointIntent == .intendedPress, clearanceMin < 0 {
                let overlap = -clearanceMin
                return max(0, min(30, 30 - Int(overlap * 200)))
            }
            if clearanceMin < 0 {
                return max(0, min(25, Int((clearanceMin + 0.05) * -400)))
            }
            return max(5, 35 - Int((required - clearanceMin) * 5000))
        case .warn:
            let base = 55 + Int(min(20, max(0, clearanceMin) * 3000))
            let penalized = base - min(15, Int(band * 120))
            return min(79, max(40, penalized))
        case .ok:
            let margin = max(0, clearanceMin - required)
            let tight = max(0, 0.02 - band)
            let raw = 72 + Int(min(28, margin * 2500 + tight * 200))
            return min(100, max(70, raw))
        }
    }

    private static func makeShaftHoleSummary(
        input: ShaftHoleInput,
        clearanceMin: Double,
        clearanceMax: Double,
        required: Double,
        status: MBCheckStatus
    ) -> String {
        let fmt = { (v: Double) -> String in String(format: "%.4f mm", v) }
        switch input.jointIntent {
        case .intendedPress:
            switch status {
            case .critical:
                return "Interference fit: overlap \(fmt(-clearanceMin)) exceeds the allowed limit for these limits."
            case .warn:
                if clearanceMin >= 0 {
                    return "Limits show clearance \(fmt(clearanceMin))…\(fmt(clearanceMax)): interference was expected — review tolerances."
                }
                return "Interference in a risky band: overlap \(fmt(-clearanceMin)). Check shrink allowance and tool tolerances."
            case .ok:
                return "Interference within a safe band: overlap \(fmt(-clearanceMin)), limits yield \(fmt(clearanceMin))…\(fmt(clearanceMax))."
            }
        case .slidingClearance:
            return makeClearanceOnlySummary(
                clearanceMin: clearanceMin,
                clearanceMax: clearanceMax,
                required: required,
                status: status
            )
        }
    }

    private static func makeClearanceOnlySummary(
        clearanceMin: Double,
        clearanceMax: Double,
        required: Double,
        status: MBCheckStatus
    ) -> String {
        let fmt = { (v: Double) -> String in String(format: "%.4f mm", v) }
        switch status {
        case .critical:
            if clearanceMin < 0 {
                return "Interference: minimum clearance \(fmt(clearanceMin)). Risk of tight assembly or seizure."
            }
            return "Minimum clearance \(fmt(clearanceMin)) is below the required \(fmt(required))."
        case .warn:
            return "Within limits but tight margin: clearance \(fmt(clearanceMin))…\(fmt(clearanceMax)). Review tolerance stack and tool wear."
        case .ok:
            return "Clearance \(fmt(clearanceMin))…\(fmt(clearanceMax)) is in a comfortable band."
        }
    }
}
