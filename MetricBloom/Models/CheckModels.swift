
import Foundation

enum CheckKind: String, CaseIterable, Identifiable {
    case shaftHole = "Shaft & hole"
    case clearanceOnly = "Clearance only"

    var id: String { rawValue }
}

extension CheckKind: Codable {
    private enum LegacyUTF8 {
        static let shaftHole = String(decoding: [
            208, 146, 208, 176, 208, 187, 32, 226, 128, 148, 32,
            208, 190, 209, 130, 208, 178, 208, 181, 209, 128, 209, 129, 209, 130, 208, 184, 208, 181,
        ], as: UTF8.self)
        static let clearanceOnly = String(decoding: [
            208, 162, 208, 190, 208, 187, 209, 140, 208, 186, 208, 190, 32,
            208, 183, 208, 176, 208, 183, 208, 190, 209, 128,
        ], as: UTF8.self)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let s = try c.decode(String.self)
        switch s {
        case Self.shaftHole.rawValue, LegacyUTF8.shaftHole:
            self = .shaftHole
        case Self.clearanceOnly.rawValue, LegacyUTF8.clearanceOnly:
            self = .clearanceOnly
        default:
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unknown CheckKind: \(s)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

enum MBCheckStatus: String, Codable {
    case ok
    case warn
    case critical

    var title: String {
        switch self {
        case .ok: return "OK"
        case .warn: return "Warning"
        case .critical: return "Critical"
        }
    }
}

struct ClearanceOnlyInput: Codable, Hashable, Equatable {
    var clearanceMin: Double
    var clearanceMax: Double
    var minRequired: Double?
}

enum ShaftJointIntent: String, Codable, Hashable, Equatable {
    case slidingClearance
    case intendedPress
}

struct ShaftHoleInput: Codable, Hashable, Equatable {
    var holeMin: Double
    var holeMax: Double
    var shaftMin: Double
    var shaftMax: Double
    var minRequiredClearance: Double?
    var jointIntent: ShaftJointIntent
    var maxInterferenceMm: Double?

    static let `default` = ShaftHoleInput(
        holeMin: 10.0,
        holeMax: 10.025,
        shaftMin: 9.975,
        shaftMax: 10.0,
        minRequiredClearance: 0.01,
        jointIntent: .slidingClearance,
        maxInterferenceMm: nil
    )

    enum CodingKeys: String, CodingKey {
        case holeMin, holeMax, shaftMin, shaftMax, minRequiredClearance, jointIntent, maxInterferenceMm
    }

    init(
        holeMin: Double,
        holeMax: Double,
        shaftMin: Double,
        shaftMax: Double,
        minRequiredClearance: Double?,
        jointIntent: ShaftJointIntent = .slidingClearance,
        maxInterferenceMm: Double? = nil
    ) {
        self.holeMin = holeMin
        self.holeMax = holeMax
        self.shaftMin = shaftMin
        self.shaftMax = shaftMax
        self.minRequiredClearance = minRequiredClearance
        self.jointIntent = jointIntent
        self.maxInterferenceMm = maxInterferenceMm
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        holeMin = try c.decode(Double.self, forKey: .holeMin)
        holeMax = try c.decode(Double.self, forKey: .holeMax)
        shaftMin = try c.decode(Double.self, forKey: .shaftMin)
        shaftMax = try c.decode(Double.self, forKey: .shaftMax)
        minRequiredClearance = try c.decodeIfPresent(Double.self, forKey: .minRequiredClearance)
        jointIntent = try c.decodeIfPresent(ShaftJointIntent.self, forKey: .jointIntent) ?? .slidingClearance
        maxInterferenceMm = try c.decodeIfPresent(Double.self, forKey: .maxInterferenceMm)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(holeMin, forKey: .holeMin)
        try c.encode(holeMax, forKey: .holeMax)
        try c.encode(shaftMin, forKey: .shaftMin)
        try c.encode(shaftMax, forKey: .shaftMax)
        try c.encodeIfPresent(minRequiredClearance, forKey: .minRequiredClearance)
        try c.encode(jointIntent, forKey: .jointIntent)
        try c.encodeIfPresent(maxInterferenceMm, forKey: .maxInterferenceMm)
    }
}

enum CheckInputPayload: Hashable, Equatable {
    case shaftHole(ShaftHoleInput)
    case clearanceOnly(ClearanceOnlyInput)
}

extension CheckInputPayload: Codable {
    private enum CodingKeys: String, CodingKey {
        case payloadKind, shaft, clearance
    }

    private enum PayloadKind: String, Codable {
        case shaftHole
        case clearanceOnly
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let k = try c.decode(PayloadKind.self, forKey: .payloadKind)
        switch k {
        case .shaftHole:
            self = .shaftHole(try c.decode(ShaftHoleInput.self, forKey: .shaft))
        case .clearanceOnly:
            self = .clearanceOnly(try c.decode(ClearanceOnlyInput.self, forKey: .clearance))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .shaftHole(let s):
            try c.encode(PayloadKind.shaftHole, forKey: .payloadKind)
            try c.encode(s, forKey: .shaft)
        case .clearanceOnly(let cl):
            try c.encode(PayloadKind.clearanceOnly, forKey: .payloadKind)
            try c.encode(cl, forKey: .clearance)
        }
    }
}

struct CheckResult: Identifiable, Hashable, Equatable {
    var id: UUID
    var kind: CheckKind
    var payload: CheckInputPayload
    var clearanceMin: Double
    var clearanceMax: Double
    var status: MBCheckStatus
    var bloomScore: Int
    var summary: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        kind: CheckKind,
        payload: CheckInputPayload,
        clearanceMin: Double,
        clearanceMax: Double,
        status: MBCheckStatus,
        bloomScore: Int,
        summary: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.payload = payload
        self.clearanceMin = clearanceMin
        self.clearanceMax = clearanceMax
        self.status = status
        self.bloomScore = bloomScore
        self.summary = summary
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, kind, payload, input, clearanceMin, clearanceMax, status, bloomScore, summary, createdAt
    }
}

extension CheckResult: Codable {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        kind = try c.decode(CheckKind.self, forKey: .kind)
        clearanceMin = try c.decode(Double.self, forKey: .clearanceMin)
        clearanceMax = try c.decode(Double.self, forKey: .clearanceMax)
        status = try c.decode(MBCheckStatus.self, forKey: .status)
        bloomScore = try c.decode(Int.self, forKey: .bloomScore)
        summary = try c.decode(String.self, forKey: .summary)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        if let p = try c.decodeIfPresent(CheckInputPayload.self, forKey: .payload) {
            payload = p
        } else {
            let legacy = try c.decode(ShaftHoleInput.self, forKey: .input)
            payload = .shaftHole(legacy)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(kind, forKey: .kind)
        try c.encode(payload, forKey: .payload)
        try c.encode(clearanceMin, forKey: .clearanceMin)
        try c.encode(clearanceMax, forKey: .clearanceMax)
        try c.encode(status, forKey: .status)
        try c.encode(bloomScore, forKey: .bloomScore)
        try c.encode(summary, forKey: .summary)
        try c.encode(createdAt, forKey: .createdAt)
    }
}

enum CheckFormPrefill: Equatable {
    case shaftHole(ShaftHoleInput)
    case clearanceOnly(ClearanceOnlyInput)
}

struct SavedCompareScenario: Identifiable, Codable, Hashable, Equatable {
    var id: UUID
    var title: String
    var resultA: CheckResult
    var resultB: CheckResult
    var createdAt: Date

    init(id: UUID = UUID(), title: String, resultA: CheckResult, resultB: CheckResult, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.resultA = resultA
        self.resultB = resultB
        self.createdAt = createdAt
    }
}
