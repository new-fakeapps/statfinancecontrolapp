import UIKit

struct SplashScreenConfigurator {
    
    static func createModule() -> UIViewController {
        let view = SplashScreenViewController()

        let interactor = SplashScreenInteractor()
        let router = SplashScreenRouter()
        let presenter = SplashScreenPresenter(
            interface: view,
            interactor: interactor,
            router: router
        )

        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view

        return view
    }
}
