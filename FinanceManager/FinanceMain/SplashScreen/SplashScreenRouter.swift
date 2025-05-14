import UIKit
import SwiftUI
import Foundation
import FinanceManager

// Импортируем модель FinanceStore
// Для SwiftUI файлов модуль может быть доступен напрямую

class SplashScreenRouter {
    // MARK: - Properties
    weak var viewController: UIViewController?
    // Инициализируем FinanceStore для передачи в SwiftUI
    private let financeStore = FinanceStore()
}

// MARK: - SplashScreenWireframeInterface -
extension SplashScreenRouter: SplashScreenWireframeInterface {
    
    func navigate(to option: SplashScreenNavigationOption) {
        print("\n[SplashScreenRouter] navigate(to: \(option)) called.")
        let vc: UIViewController
        let presentationType: PresentationType
        
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        if topViewController is UINavigationController {
            topViewController = (topViewController as? UINavigationController)?.viewControllers.first
        }
        
        switch option {
        case .authorizationScreen:
            print("[SplashScreenRouter] Case: .authorizationScreen")
            guard var authUrl = AppSettings.firebaseModel?.wvSettings?.authUrl else {
                print("🚨 [SplashScreenRouter] Error: Authorization URL is missing.")
                return
            }
            print("[SplashScreenRouter] Initial authUrl: \(authUrl)")
            print("[SplashScreenRouter] Checking AppSettings.isTrust: \(AppSettings.isTrust)")
            
            // Add is_trust parameter if needed
            if AppSettings.isTrust {
                if var components = URLComponents(url: authUrl, resolvingAgainstBaseURL: true) {
                    var queryItems = components.queryItems ?? []
                    // Avoid adding duplicate parameters
                    if !queryItems.contains(where: { $0.name == "is_trust" }) {
                         queryItems.append(URLQueryItem(name: "is_trust", value: "true"))
                         components.queryItems = queryItems
                         if let modifiedUrl = components.url {
                            print("🔒 [SplashScreenRouter] Modifying auth URL with is_trust: \(modifiedUrl)")
                            authUrl = modifiedUrl
                         } else {
                             print("⚠️ [SplashScreenRouter] Failed to create modified URL from components.")
                         }
                    } else {
                        print("[SplashScreenRouter] is_trust parameter already exists or not needed.")
                    }
                } else {
                     print("⚠️ [SplashScreenRouter] Failed to create URLComponents from authUrl.")
                }
            }
            
            print("[SplashScreenRouter] Final URL for WebScreenData: \(authUrl)")
            let data = WebScreenData(url: authUrl, htmlString: nil, info: nil)
            vc = WebScreenConfigurator.createModule(with: data)
            // Ensure we set the rootViewController on the main thread
             DispatchQueue.main.async {
                 UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = vc
             }
            return
        case .featureApp:
            print("🚀 [SplashScreenRouter] Case: .featureApp. Preparing to set root view controller.")
            let mainTabView = ForceCompactView(content: MainTabView(financeStore: financeStore))
                .environmentObject(financeStore)
            let hostingController = UIHostingController(rootView: mainTabView)
            print("🔄 [SplashScreenRouter] Setting rootViewController to UIHostingController for ContentView.")
            DispatchQueue.main.async {
                guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
                    print("🚨 [SplashScreenRouter] Error: Could not find key window to set root view controller.")
                    return
                }
                window.rootViewController = hostingController
                print("✅ [SplashScreenRouter] Root view controller successfully set to feature app.")
                window.makeKeyAndVisible()
            }
            return
        case .forceUpdate(let versionSettings):
            print("[SplashScreenRouter] Case: .forceUpdate")
            // Handle force update navigation
            return
        case let .wvScreen(url, webDisplayType):
            print("[SplashScreenRouter] Case: .wvScreen(url: \(url), type: \(webDisplayType))")
            presentationType = .modal
            
            var finalUrl = url
            print("[SplashScreenRouter] Initial finalUrl: \(finalUrl)")
            print("[SplashScreenRouter] Checking AppSettings.isTrust: \(AppSettings.isTrust)")
            
            // Check if the URL is the auth URL and add is_trust parameter if needed
            if AppSettings.isTrust,
               let authUrl = AppSettings.firebaseModel?.wvSettings?.authUrl {
               print("[SplashScreenRouter] Comparing finalUrl host ('\(finalUrl.host ?? "nil")') with authUrl host ('\(authUrl.host ?? "nil")')")
               // More robust check: Compare scheme and host
               if finalUrl.scheme == authUrl.scheme && finalUrl.host == authUrl.host {
                   print("[SplashScreenRouter] URL matches auth URL host. Proceeding to check/add is_trust.")
                   if var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                       var queryItems = components.queryItems ?? []
                       // Avoid adding duplicate parameters
                       if !queryItems.contains(where: { $0.name == "is_trust" }) {
                          queryItems.append(URLQueryItem(name: "is_trust", value: "true"))
                          components.queryItems = queryItems
                          if let modifiedUrl = components.url {
                             print("🔒 [SplashScreenRouter] Modifying wvScreen URL with is_trust: \(modifiedUrl)")
                             finalUrl = modifiedUrl
                          } else {
                              print("⚠️ [SplashScreenRouter] Failed to create modified URL from components.")
                          }
                       } else {
                           print("[SplashScreenRouter] is_trust parameter already exists or not needed.")
                       }
                   } else {
                       print("⚠️ [SplashScreenRouter] Failed to create URLComponents from finalUrl.")
                   }
               } else {
                   print("[SplashScreenRouter] URL does not match auth URL host. Skipping is_trust modification.")
               }
            } else {
                print("[SplashScreenRouter] AppSettings.isTrust is false or authUrl is nil. Skipping is_trust modification.")
            }
            
            print("[SplashScreenRouter] Final URL for WebScreenData: \(finalUrl)")
            let data = WebScreenData(url: finalUrl, htmlString: nil, info: nil, onViewDidDisappear: nil)
            vc = WebScreenConfigurator.createModule(with: data)
            // Ensure we set the rootViewController on the main thread
            DispatchQueue.main.async {
                 UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = vc
            }
            return
        }
        
        vc.changeModalPresentationStyle()
        switch presentationType {
        case .modal:
            viewController?.modalPresentationStyle = .fullScreen
            viewController?.present(vc, animated: false)
        case .push:
            viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        
        delay(1) {
            AppSettings.showLastVersionUpdateInfoIfNeeded()
        }
    }
}
