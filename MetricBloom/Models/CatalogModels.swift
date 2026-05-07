
import Foundation

struct CatalogFit: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var system: String
    var diameterRange: String
    var description: String
    var suggestedHoleMin: Double
    var suggestedHoleMax: Double
    var suggestedShaftMin: Double
    var suggestedShaftMax: Double
    var minClearanceHint: Double?
}

enum CatalogData {
    static let referenceNominal: Double = 10.0

    static let fits: [CatalogFit] = [
        CatalogFit(
            id: "H7-h6",
            title: "Fit H7/h6",
            system: "ISO 286",
            diameterRange: "6…18 mm (typ.)",
            description: "Sliding fit with small clearance, good centering.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.015,
            suggestedShaftMin: 9.985,
            suggestedShaftMax: 10.0,
            minClearanceHint: 0.0
        ),
        CatalogFit(
            id: "H7-f7",
            title: "Fit H7/f7",
            system: "ISO 286",
            diameterRange: "6…18 mm (typ.)",
            description: "Normal clearance for moving assemblies.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.015,
            suggestedShaftMin: 9.944,
            suggestedShaftMax: 9.970,
            minClearanceHint: 0.015
        ),
        CatalogFit(
            id: "H7-g6",
            title: "Fit H7/g6",
            system: "ISO 286",
            diameterRange: "6…18 mm (typ.)",
            description: "Small clearance, precise sliding.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.015,
            suggestedShaftMin: 9.973,
            suggestedShaftMax: 9.987,
            minClearanceHint: 0.01
        ),
        CatalogFit(
            id: "H8-f8",
            title: "Fit H8/f8",
            system: "ISO 286",
            diameterRange: "≈ 10 mm",
            description: "Slightly wider tolerance fields, easier to manufacture.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.022,
            suggestedShaftMin: 9.940,
            suggestedShaftMax: 9.967,
            minClearanceHint: 0.018
        ),
        CatalogFit(
            id: "H7-k6",
            title: "Fit H7/k6",
            system: "ISO 286",
            diameterRange: "6…18 mm (typ.)",
            description: "Transition: small clearance or light interference possible.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.015,
            suggestedShaftMin: 9.996,
            suggestedShaftMax: 10.009,
            minClearanceHint: nil
        ),
        CatalogFit(
            id: "H7-p6",
            title: "Fit H7/p6",
            system: "ISO 286",
            diameterRange: "6…18 mm (typ.)",
            description: "Light interference; control press-in force.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.015,
            suggestedShaftMin: 10.012,
            suggestedShaftMax: 10.028,
            minClearanceHint: nil
        ),
        CatalogFit(
            id: "H7-s6",
            title: "Fit H7/s6",
            system: "ISO 286",
            diameterRange: "6…18 mm (typ.)",
            description: "Heavy interference — calculate forces.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.015,
            suggestedShaftMin: 10.022,
            suggestedShaftMax: 10.035,
            minClearanceHint: nil
        ),
        CatalogFit(
            id: "H11-c11",
            title: "Fit H11/c11",
            system: "ISO 286",
            diameterRange: "≈ 10 mm",
            description: "Loose machining, large clearance.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.090,
            suggestedShaftMin: 9.880,
            suggestedShaftMax: 9.940,
            minClearanceHint: 0.02
        ),
        CatalogFit(
            id: "G7-h6",
            title: "Fit G7/h6",
            system: "ISO 286",
            diameterRange: "≈ 10 mm",
            description: "Clearance with a “floating” shaft (shaft h, hole G).",
            suggestedHoleMin: 10.009,
            suggestedHoleMax: 10.028,
            suggestedShaftMin: 9.985,
            suggestedShaftMax: 10.0,
            minClearanceHint: 0.01
        ),
        CatalogFit(
            id: "js7-H7",
            title: "Fit js7/H7",
            system: "ISO 286",
            diameterRange: "≈ 10 mm",
            description: "Shaft with symmetric deviation about nominal.",
            suggestedHoleMin: 10.0,
            suggestedHoleMax: 10.015,
            suggestedShaftMin: 9.987,
            suggestedShaftMax: 10.013,
            minClearanceHint: nil
        ),
    ]
}

extension CatalogFit {
    func shaftHoleInput(forUserNominal nominal: Double) -> ShaftHoleInput {
        let n0 = CatalogData.referenceNominal
        guard n0 > 0, nominal > 0 else {
            return ShaftHoleInput(
                holeMin: suggestedHoleMin,
                holeMax: suggestedHoleMax,
                shaftMin: suggestedShaftMin,
                shaftMax: suggestedShaftMax,
                minRequiredClearance: minClearanceHint,
                jointIntent: .slidingClearance,
                maxInterferenceMm: nil
            )
        }
        let k = nominal / n0
        func scale(_ value: Double) -> Double {
            nominal + (value - n0) * k
        }
        let hint = minClearanceHint.map { $0 * k }
        return ShaftHoleInput(
            holeMin: scale(suggestedHoleMin),
            holeMax: scale(suggestedHoleMax),
            shaftMin: scale(suggestedShaftMin),
            shaftMax: scale(suggestedShaftMax),
            minRequiredClearance: hint,
            jointIntent: .slidingClearance,
            maxInterferenceMm: nil
        )
    }
}
