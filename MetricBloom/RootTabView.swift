
import SwiftUI

struct RootTabView: View {
    @StateObject private var stores = AppStores()
    @State private var tabSelection = 0

    private var onboardingPresented: Binding<Bool> {
        Binding(
            get: { !stores.settings.hasCompletedOnboarding || stores.replayOnboardingVisible },
            set: { newValue in
                if !newValue {
                    stores.replayOnboardingVisible = false
                }
            }
        )
    }

    var body: some View {
        TabView(selection: $tabSelection) {
            CheckRootView()
                .tabItem { Label("Check", systemImage: "gauge.with.dots.needle.67percent") }
                .tag(MBTab.check.rawValue)

            CatalogRootView()
                .tabItem { Label("Catalog", systemImage: "books.vertical") }
                .tag(MBTab.catalog.rawValue)

            ProjectsRootView()
                .tabItem { Label("Projects", systemImage: "square.stack.3d.down.forward") }
                .tag(MBTab.projects.rawValue)

            ToolsRootView()
                .tabItem { Label("Tools", systemImage: "wrench.and.screwdriver") }
                .tag(MBTab.tools.rawValue)

            SettingsRootView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(MBTab.settings.rawValue)
        }
        .tint(MBColor.accentOrange)
        .environmentObject(stores)
        .onChange(of: stores.navigateToTab) { newValue in
            guard let newValue else { return }
            tabSelection = newValue.rawValue
            stores.navigateToTab = nil
        }
        .fullScreenCover(isPresented: onboardingPresented) {
            OnboardingView(isPresented: onboardingPresented)
                .environmentObject(stores)
        }
        .preferredColorScheme(.dark)
    }
}
