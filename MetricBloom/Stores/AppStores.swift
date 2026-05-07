
import Combine
import SwiftUI

enum MBTab: Int, CaseIterable {
    case check = 0
    case catalog = 1
    case projects = 2
    case tools = 3
    case settings = 4
}

@MainActor
final class AppStores: ObservableObject {
    @Published var history: [CheckResult] = []
    @Published var projects: [MBProject] = []
    @Published var favoriteFitIds: Set<String> = []
    @Published var settings: MBSettings = .init()
    @Published var catalogPreset: ShaftHoleInput?
    @Published var navigateToTab: MBTab?
    @Published var replayOnboardingVisible: Bool = false
    @Published var compareScenarios: [SavedCompareScenario] = []

    private let maxHistory = 60
    private let maxCompareSaved = 30

    init() {
        history = MBPersistence.loadHistory()
        projects = MBPersistence.loadProjects()
        favoriteFitIds = MBPersistence.loadFavorites()
        settings = MBPersistence.loadSettings()
        compareScenarios = MBPersistence.loadCompareScenarios()
    }

    func recordCheck(_ result: CheckResult) {
        history.removeAll { $0.id == result.id }
        history.insert(result, at: 0)
        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }
        MBPersistence.saveHistory(history)
    }

    func deleteHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        MBPersistence.saveHistory(history)
    }

    func clearHistory() {
        history.removeAll()
        MBPersistence.saveHistory(history)
    }

    func toggleFavorite(fitId: String) {
        if favoriteFitIds.contains(fitId) {
            favoriteFitIds.remove(fitId)
        } else {
            favoriteFitIds.insert(fitId)
        }
        MBPersistence.saveFavorites(favoriteFitIds)
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteFitIds.contains(id)
    }

    func upsertProject(_ project: MBProject) {
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
        } else {
            projects.insert(project, at: 0)
        }
        MBPersistence.saveProjects(projects)
    }

    func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        MBPersistence.saveProjects(projects)
    }

    func deleteProject(_ project: MBProject) {
        projects.removeAll { $0.id == project.id }
        MBPersistence.saveProjects(projects)
    }

    func renameProject(projectId: UUID, name: String) {
        guard var p = projects.first(where: { $0.id == projectId }) else { return }
        p.name = name
        p.updatedAt = Date()
        upsertProject(p)
    }

    func renameNode(projectId: UUID, nodeId: UUID, name: String) {
        guard var p = projects.first(where: { $0.id == projectId }) else { return }
        guard let ni = p.nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        p.nodes[ni].name = name
        p.updatedAt = Date()
        upsertProject(p)
    }

    func removeCheck(projectId: UUID, nodeId: UUID, checkId: UUID) {
        guard var p = projects.first(where: { $0.id == projectId }) else { return }
        guard let ni = p.nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        p.nodes[ni].checks.removeAll { $0.id == checkId }
        p.updatedAt = Date()
        upsertProject(p)
    }

    func updateSettings(_ block: (inout MBSettings) -> Void) {
        block(&settings)
        MBPersistence.saveSettings(settings)
    }

    func completeOnboarding() {
        updateSettings { $0.hasCompletedOnboarding = true }
    }

    func applyCatalogPreset(_ input: ShaftHoleInput) {
        catalogPreset = input
        navigateToTab = .check
    }

    func saveCompareScenario(title: String, a: CheckResult, b: CheckResult) {
        let entry = SavedCompareScenario(title: title, resultA: a, resultB: b)
        compareScenarios.insert(entry, at: 0)
        if compareScenarios.count > maxCompareSaved {
            compareScenarios = Array(compareScenarios.prefix(maxCompareSaved))
        }
        MBPersistence.saveCompareScenarios(compareScenarios)
    }

    func deleteCompareScenario(at offsets: IndexSet) {
        compareScenarios.remove(atOffsets: offsets)
        MBPersistence.saveCompareScenarios(compareScenarios)
    }

    func deleteCompareScenario(_ id: UUID) {
        compareScenarios.removeAll { $0.id == id }
        MBPersistence.saveCompareScenarios(compareScenarios)
    }
}
