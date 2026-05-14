
import SwiftUI

private struct MBCheckNavigationPathKey: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath>? = nil
}

extension EnvironmentValues {
    var mbCheckNavigationPath: Binding<NavigationPath>? {
        get { self[MBCheckNavigationPathKey.self] }
        set { self[MBCheckNavigationPathKey.self] = newValue }
    }
}

struct CheckRootView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            CheckHomeView(path: $path)
                .navigationDestination(for: CheckResult.self) { result in
                    CheckResultView(result: result)
                }
                .navigationDestination(for: String.self) { token in
                    switch token {
                    case "history":
                        CheckHistoryView()
                    case "compare":
                        CompareScenariosView(path: $path)
                    default:
                        EmptyView()
                    }
                }
                .navigationDestination(for: SavedCompareScenario.self) { scenario in
                    CompareDetailView(scenario: scenario)
                }
        }
        .environment(\.mbCheckNavigationPath, $path)
        .toolbar(path.isEmpty ? .visible : .hidden, for: .tabBar)
    }
}
