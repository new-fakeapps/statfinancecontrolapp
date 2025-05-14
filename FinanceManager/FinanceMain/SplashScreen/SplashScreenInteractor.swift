import UIKit
import PromiseKit

class SplashScreenInteractor: SplashScreenInteractorInput {

    // MARK: - Properties
    weak var presenter: SplashScreenInteractorOutput?
//    private var remoteNotificationsListStatus: RemoteNotificationsStatus?

    // MARK: - SplashScreenInteractorInput -

    init() { }

    func fetchFirebaseAPI() {
        FirebaseService.shared.getAppSettings()
            .done { [self] firebaseModel in
                self.presenter?.fetchedFirebaseAPI(firebaseModel: firebaseModel)
            }
            .catch { [weak self] error in
                self?.presenter?.fetchedFirebaseAPI(error: error)
            }
        FirebaseService.shared.enableAutoSync()
    }

    func fetchIPInfo() {
//        LocationManager.fetchIPInfo().cauterize()
//        LocationManager.fetchCoutryCodeBySimCard().cauterize()
    }
    
    func fetchRemoteNotificationsListStatus() {
//        RemoteNotificationManager.getStatus()
//            .done {[weak self] (status) in
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

}
