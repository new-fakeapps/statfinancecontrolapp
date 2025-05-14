import Foundation
import WebKit

//MARK: Wireframe -
enum WebScreenNavigationOption {
    case back
    case redirect(url: URL)
    case featureApp
    case dismiss
    case webView
}

struct WebScreenData {
    var url: URL?
    let htmlString: String?
    let info: [WebScreenInfoKey: Any]?
    var onViewDidDisappear: (() -> Void)?
}

enum WebScreenInfoKey: String {
    case returnURLs
    case redirect
    case comment
    case title
    case menuRevealable
}

enum WebScreenReturnKey: String {
    case returnURL
    case info
}

protocol WebScreenWireframeInterface: AnyObject {
    func navigate(to option: WebScreenNavigationOption)
}

//MARK: Presenter -
protocol WebScreenPresenterInterface: AnyObject {

    var interactor: WebScreenInteractorInput? { get set }
    
    func shouldStartLoadWith(url: URL?) -> WKNavigationActionPolicy
    func didStartProvisionalNavigation(url: URL?)
    func didReceiveServerRedirectForProvisionalNavigation(url: URL?)

    func didSetPreviousPage(url: URL?)
    func didFailLoadWithError(_ error: Error, url: String?)
    func didFinishLoad()
    
    // MARK: - JavaScript Events -
    func didReceiveTrustEvent()
    func didReceiveAgreement()
    
    // MARK: - Lifecycle -
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDisappear()

}

extension WebScreenPresenterInterface {
    func viewDidLoad() {/*leaves this empty*/}
    func viewWillAppear() {/*leaves this empty*/}
    func viewDidAppear() {/*leaves this empty*/}
    func viewWillDisappear() {/*leaves this empty*/}
    func viewDidDisappear() {/*leaves this empty*/}
}


//MARK: Interactor -
protocol WebScreenInteractorOutput: AnyObject {

    
    /* Interactor -> Presenter */
//    func fetchedRemoteNotificationsStatus(with status: RemoteNotificationsStatus?)
//    func registeredForPushNotifications(with status: RemoteNotificationsStatus?)
//    func unregisteredForPushNotifications(with status: RemoteNotificationsStatus?)
}

protocol WebScreenInteractorInput: AnyObject {

    var presenter: WebScreenInteractorOutput?  { get set }
    
    /* Presenter -> Interactor */
    func fetchRemoteNotificationsStatus()
    func registerForPushNotificationsList()
    func unregisterForPushNotificationsList()
    func fetchIPInfo()
}

//MARK: View -
protocol WebScreenView: AnyObject {

    var presenter: WebScreenPresenterInterface?  { get set }

    func display(url: URL)
    func display(htmlString: String, baseURL: URL?)
    func stopLoading()
    func sideMenuRevealable(isActive: Bool)
    /* Presenter -> ViewController */
}
