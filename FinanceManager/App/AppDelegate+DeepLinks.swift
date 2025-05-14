import UIKit

extension AppDelegate {

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL else {
                return false
        }
        return handleLink(incomingURL.absoluteString)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return application(
            app,
            open: url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation] ?? ""
        )
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return handleLink(url.absoluteString)
    }
    
    @discardableResult
    func handleLink(_ link: String?) -> Bool {
        guard let url = link else { return false }
        
        var isEnabledToOpenWebScreen = true
        
        if url.contains("://link") {
            isEnabledToOpenWebScreen = false
        } else if url.contains("://webview") {
            isEnabledToOpenWebScreen = false
        } else if url.contains("://linkInside") {
            isEnabledToOpenWebScreen = false
        }
        
        if url.contains("://promo") {
            if AppSettings.isActivated {
                return false
            } else if AppSettings.isLoggedIn {
                return false
            }
        }
         
        guard isEnabledToOpenWebScreen else {
            return false
        }
        
        DeeplinkManager.shared.handle(url)
        guard DeeplinkManager.shared.deeplink != nil else { return false }
        
        let disallowedControllers: [String] = [
            "SplashScreenViewController"
        ]
        
        if
            let className = UIApplication.topViewController()?.classForCoder.description(),
            !(disallowedControllers.contains { className.contains($0) })
        {
            DeeplinkManager.shared.executeDeeplinkTask()
        }

        return true
    }
}
