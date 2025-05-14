import UIKit
import PromiseKit

class WebScreenInteractor: WebScreenInteractorInput {
    
    // MARK: - Properties
    weak var presenter: WebScreenInteractorOutput?
    
    // MARK: - PayScreenInteractorInput -
    func fetchRemoteNotificationsStatus() {
//        RemoteNotificationManager.getStatus()
//            .done { [weak self] (status) in
//                self?.presenter?.fetchedRemoteNotificationsStatus(with: status)
//            }.cauterize()
    }
    
    func registerForPushNotificationsList() {
//        firstly {
//            RemoteNotificationManager.registerForPushNotifications()
//        }
//        .done {[weak self] (status) in
//            self?.presenter?.registeredForPushNotifications(with: status)
//        }.cauterize()
    }
    
    func unregisterForPushNotificationsList() {
//        RemoteNotificationManager.unregisterForPushNotifications()
//        RemoteNotificationManager.getStatus()
//            .done {[weak self] (status) in
//                self?.presenter?.unregisteredForPushNotifications(with: status)
//            }.cauterize()
    }
    
    func fetchIPInfo() {
//        LocationManager.fetchIPInfo().cauterize()
//        LocationManager.fetchCoutryCodeBySimCard().cauterize()
    }
}
