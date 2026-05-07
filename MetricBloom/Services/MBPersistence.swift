
import Foundation

enum MBPersistence {
    private static let historyKey = "mb.history"
    private static let projectsKey = "mb.projects"
    private static let favoritesKey = "mb.catalog.favorites"
    private static let settingsKey = "mb.settings.blob"
    private static let compareScenariosKey = "mb.compare.scenarios"

    static func loadHistory() -> [CheckResult] {
        decode([CheckResult].self, from: UserDefaults.standard.data(forKey: historyKey)) ?? []
    }

    static func saveHistory(_ items: [CheckResult]) {
        UserDefaults.standard.set(encode(items), forKey: historyKey)
    }

    static func loadProjects() -> [MBProject] {
        decode([MBProject].self, from: UserDefaults.standard.data(forKey: projectsKey)) ?? []
    }

    static func saveProjects(_ items: [MBProject]) {
        UserDefaults.standard.set(encode(items), forKey: projectsKey)
    }

    static func loadFavorites() -> Set<String> {
        let arr = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        return Set(arr)
    }

    static func saveFavorites(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: favoritesKey)
    }

    static func loadSettings() -> MBSettings {
        decode(MBSettings.self, from: UserDefaults.standard.data(forKey: settingsKey)) ?? MBSettings()
    }

    static func saveSettings(_ settings: MBSettings) {
        UserDefaults.standard.set(encode(settings), forKey: settingsKey)
    }

    static func loadCompareScenarios() -> [SavedCompareScenario] {
        decode([SavedCompareScenario].self, from: UserDefaults.standard.data(forKey: compareScenariosKey)) ?? []
    }

    static func saveCompareScenarios(_ items: [SavedCompareScenario]) {
        UserDefaults.standard.set(encode(items), forKey: compareScenariosKey)
    }

    private static func encode<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

struct MBSettings: Codable, Equatable {
    var hapticsEnabled: Bool = true
    var hasCompletedOnboarding: Bool = false
}
