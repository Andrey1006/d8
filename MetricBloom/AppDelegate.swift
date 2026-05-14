import SwiftUI
import OneSignalFramework
import FirebaseCore

@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    private var pushid = UUID().uuidString
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        OneSignal.initialize("5bc06d0d-a30c-4a08-b0ec-2dc10d8fbf43", withLaunchOptions: launchOptions)
        
        let id = UserDefaults.standard.string(forKey: "pushid")
        if id == nil {
            UserDefaults.standard.set(pushid, forKey: "pushid")
            OneSignal.login(pushid)
        } else {
            pushid = id!
        }
        
        let window = UIWindow()
        window.rootViewController = UIHostingController(rootView: StartView())
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
}
