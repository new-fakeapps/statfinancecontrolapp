import UIKit

struct WebScreenConfigurator {
    
    static func createModule(with data: WebScreenData, promocode: String? = nil, isVCModalPresented: Bool = false) -> UIViewController {
        let view = WebScreenViewController()
        let navigationController = UINavigationController(rootViewController: view) 

        let interactor = WebScreenInteractor()
        let router = WebScreenRouter()
        let presenter = WebScreenPresenter(
            interface: view,
            interactor: interactor,
            router: router,
            data: data,
            isVCModalPresented: isVCModalPresented,
            promocode: promocode
        )
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view

        return navigationController
    }
}
