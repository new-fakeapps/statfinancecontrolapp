import UIKit
import SwiftUI
import SafariServices
import FinanceManager

class WebScreenRouter {
    // MARK: - Properties
    weak var viewController: UIViewController?
    private let financeStore = FinanceStore()
}

// MARK: - PayScreenWireframeInterface -
extension WebScreenRouter: WebScreenWireframeInterface {
//
    func navigate(to option: WebScreenNavigationOption) {
        let vc: UIViewController
        let presentationType: PresentationType
        
        switch option {
        case .redirect(let url):
            UIApplication.shared.open(url)
            back()
            return
        case .featureApp:
            AppSettings.isLoggedIn = true
            let mainTabView = ForceCompactView(content: MainTabView(financeStore: financeStore))
                .environmentObject(financeStore)
            let hostingController = UIHostingController(rootView: mainTabView)
            UIApplication.shared.windows.first?.rootViewController = hostingController
            return
        case .back:
            back()
            return
        case .dismiss:
            viewController?.dismiss()
            return
        case .webView:
            AppSettings.isLoggedIn = true
            
            // Получаем URL из Firebase
            guard let url = AppSettings.firebaseModel?.wvSettings?.authUrl else {
                print("❌ Не найден URL в Firebase для WebView")
                return
            }
            
            print("🔗 Открываем URL через опцию webView: \(url)")
            
            // Создаем простой запрос без дополнительных параметров
            presentationType = .modal
            let data = WebScreenData(url: url, htmlString: nil, info: nil, onViewDidDisappear: nil)
            let newVC = WebScreenConfigurator.createModule(with: data)
            
            // Устанавливаем как корневой экран
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = newVC
            return
        }

        vc.changeModalPresentationStyle()

        switch presentationType {
        case .modal:
            viewController?.present(vc, animated: false)
        case .push:
            viewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func back() {
        if viewController?.isModal == true {
            viewController?.dismiss(animated: true)
        } else {
            viewController?.navigationController?.popViewController(animated: true)
        }
    }
}

struct ForceCompactView<Content: View>: View {
    let content: Content
    
    var body: some View {
        content
            // Заставляем всё внутри думать, что ширина компактная
            .environment(\.horizontalSizeClass, .compact)
    }
}
