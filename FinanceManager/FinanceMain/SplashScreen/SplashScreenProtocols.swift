import UIKit

//MARK: Wireframe -
enum SplashScreenNavigationOption {
    case authorizationScreen
    case wvScreen(url: URL, webDisplayType: WebDisplayType)
    case featureApp
    case forceUpdate(versionSettings: FirebaseModel.VersionSettings)
}

protocol SplashScreenWireframeInterface: AnyObject {
    func navigate(to option: SplashScreenNavigationOption)
}

//MARK: Presenter -
protocol SplashScreenPresenterInterface: AnyObject {

    var interactor: SplashScreenInteractorInput? { get set }
    
    // MARK: - Lifecycle -
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDisappear()

}
extension SplashScreenPresenterInterface {
    func viewDidLoad() {/*leaves this empty*/}
    func viewWillAppear() {/*leaves this empty*/}
    func viewDidAppear() {/*leaves this empty*/}
    func viewWillDisappear() {/*leaves this empty*/}
    func viewDidDisappear() {/*leaves this empty*/}
}


//MARK: Interactor -
protocol SplashScreenInteractorOutput: AnyObject {
    
    /* Interactor -> Presenter */
    func fetchedFirebaseAPI(firebaseModel: FirebaseModel)
    func fetchedFirebaseAPI(error: Error)
//    func fetchedRemoteNotificationsStatus(with status: RemoteNotificationsStatus?)
//    func registeredForPushNotifications(with status: RemoteNotificationsStatus?)
//    func unregisteredForPushNotifications(with status: RemoteNotificationsStatus?)
}

protocol SplashScreenInteractorInput: AnyObject {

    var presenter: SplashScreenInteractorOutput?  { get set }

    /* Presenter -> Interactor */

    func fetchFirebaseAPI()
    func fetchIPInfo()
    func fetchRemoteNotificationsListStatus()
    func registerForPushNotificationsList()
    func unregisterForPushNotificationsList()
}

//MARK: View -
protocol SplashScreenView: AnyObject {

    var presenter: SplashScreenPresenterInterface?  { get set }
    
    /* Presenter -> ViewController */}
