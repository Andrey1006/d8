
import Foundation

struct AssemblyNode: Identifiable, Codable, Hashable, Equatable {
    var id: UUID
    var name: String
    var checks: [CheckResult]

    init(id: UUID = UUID(), name: String, checks: [CheckResult] = []) {
        self.id = id
        self.name = name
        self.checks = checks
    }

    var worstStatus: MBCheckStatus {
        if checks.contains(where: { $0.status == .critical }) { return .critical }
        if checks.contains(where: { $0.status == .warn }) { return .warn }
        return .ok
    }

    var minBloom: Int {
        checks.map(\.bloomScore).min() ?? 100
    }
}

struct MBProject: Identifiable, Codable, Hashable, Equatable {
    var id: UUID
    var name: String
    var notes: String
    var nodes: [AssemblyNode]
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, notes: String = "", nodes: [AssemblyNode] = [], updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.notes = notes
        self.nodes = nodes
        self.updatedAt = updatedAt
    }

    var worstStatus: MBCheckStatus {
        if nodes.contains(where: { $0.worstStatus == .critical }) { return .critical }
        if nodes.contains(where: { $0.worstStatus == .warn }) { return .warn }
        return .ok
    }

    var projectBloom: Int {
        let scores = nodes.map(\.minBloom)
        return scores.min() ?? 100
    }
}
