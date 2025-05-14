//import Foundation
//import PromiseKit
//import UserNotificationsUI
//
//struct RemoteNotificationManager {
//    
//    static var remoteNotificationsStatus: RemoteNotificationsStatus? {
//        didSet {
//            guard oldValue != remoteNotificationsStatus else { return }
//            NotificationCenter.default.post(name: AppNotes.didChangeRemoteNotificationStatus.notification, object: remoteNotificationsStatus)
//        }
//    }
//
//    ///returns nil if user not answered yet
//    @discardableResult
//    static func getStatus() -> Guarantee<RemoteNotificationsStatus?> {
//        return Guarantee { resolver in
//            let current = UNUserNotificationCenter.current()
//            current.getNotificationSettings() { settings in
//                DispatchQueue.main.async {
//                    var status: RemoteNotificationsStatus?
//                    switch settings.authorizationStatus {
//                    case .notDetermined:
//                        status = nil
//                    case .denied:
//                        status = .denied
//                    case .authorized, .provisional:
//                        status = UIApplication.shared.isRegisteredForRemoteNotifications ? .allowed : .disabled
//                    case .ephemeral: //AppClips
//                        break
//                    @unknown default:
//                        break
//                    }
//                    remoteNotificationsStatus = status
//                    resolver(status)
//                }
//            }
//        }
//    }
//    
//    @discardableResult
//    static func registerForPushNotifications() -> Promise<RemoteNotificationsStatus?> {
//        return Promise() { resolver in
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//                (granted, error) in
//                remoteNotificationsStatus = granted ? .allowed : .denied
//                DispatchQueue.main.async {
//                    if granted {
//                        UIApplication.shared.registerForRemoteNotifications()
//                    }
//                    resolver.fulfill(remoteNotificationsStatus)
//                }
//            }
//        }
//    }
//    
//    static func unregisterForPushNotifications() {
//        UIApplication.shared.unregisterForRemoteNotifications()
//        remoteNotificationsStatus = .disabled
//        (UIApplication.shared.delegate as? AppDelegate)?.applePushToken = nil
//    }
//    
//    @discardableResult
//    static func getNotificationSettings() -> Guarantee<RemoteNotificationsStatus?> {
//        let promise = getStatus()
//        promise.done { status in
//            MindboxManager.shared.notificationsRequestAuthorization(granted: status == .allowed)
//                guard status == .allowed else { return }
//                DispatchQueue.main.async {
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//            }
//        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
//        return promise
//    }
//}
