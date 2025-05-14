//
import UIKit
import FirebaseCore
import FirebaseMessaging
import IQKeyboardManagerSwift
import PromiseKit
import SDWebImage
import Lottie

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var applePushToken: String?
    var fcmPushToken: String?
    var blockRotation: Bool = !UIDevice.isPad
    private var enterInBackgroundDate: Date?
    private var activationObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard
            let configPath = Bundle.main.path(forResource: "build_config", ofType: "json"),
            let data = try? Data(
                contentsOf: URL(fileURLWithPath: configPath),
                options: .mappedIfSafe
            ),
            let appSpecification = try? JSONDecoder().decode(AppSpecification.self, from: data)
        else {
            fatalError("build_config.json is required")
        }
        
        appConfig = .init(
            appSpecification: appSpecification
        )

//        FirebaseService.shared.appName = appConfig.appSpecification.appName

        initThirdPartyLibs(launchOptions: launchOptions)
        prepareStart()
        application.applicationIconBadgeNumber = 0
        window?.rootViewController = initRootViewController()
//        window?.backgroundColor = .globalDynamicColor
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        enterInBackgroundDate = Date()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}

// MARK: - Internal methods
extension AppDelegate {

    //MARK: - Initialize 3rd party libs
    private func initThirdPartyLibs(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let urlType = (Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]])?.first,
            let scheme = (urlType["CFBundleURLSchemes"] as? [String])?.first {
            FirebaseOptions.defaultOptions()?.deepLinkURLScheme = scheme
        }
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    func prepareStart() {
        _ = phoneNumberKit
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        _ = DeeplinkManager.shared
    }
    
    private func initRootViewController() -> UIViewController {
        return SplashScreenConfigurator.createModule()
        UIViewController()
    }
    
//    private func handleActivation() {
//        // Здесь вызываем нужный сетевой запрос
//        IPLocationAPI.getIPInfo { response in
//            switch response {
//            case .Success(let dict):
//                print("Успешный ответ getIPInfo:", dict)
//            case .Error(let code, let message, _, _):
//                print("Ошибка в getIPInfo:", message ?? "—")
//            }
//        }
//        
//        IPLocationAPI.getIPv6 { response in
//            switch response {
//            case .Success(let dict):
//                print("Успешный ответ getIPInfo:", dict)
//            case .Error(let code, let message, _, _):
//                print("Ошибка в getIPInfo:", message ?? "—")
//            }
//        }
//    }
}

extension UIApplication {

    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 5111
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag

                self.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}
