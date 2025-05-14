import Foundation
import UserNotificationsUI
import FirebaseMessaging

// MARK: - Push Notifications
extension AppDelegate: UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        applePushToken = tokenParts.joined()

//        MindboxManager.shared.updatePushToken(deviceToken)
        print("Device Token: \(applePushToken ?? "")")
        NotificationCenter.default.post(name: AppNotes.didRegisterForRemoteNotifications.notification, object: nil)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register push: \(error)")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
//        MindboxManager.shared.track(type: .push(response))
        
        let buttonId = response.actionIdentifier
        if
            !buttonId.isEmpty,
            let buttonsData = userInfo["buttons"] as? [[String: Any]],
            let selectedButtonData = buttonsData.first(where: { $0["uniqueKey"] as? String == buttonId }),
            let buttonLink = selectedButtonData["url"] as? String,
            Deeplink.from(buttonLink) != nil
        {
            DeeplinkManager.shared.handle(buttonLink)
        } else {
            DeeplinkManager.shared.handleRemoteNotification(with: userInfo)
        }
        
        let disallowedControllers = [
            SplashScreenViewController.self
        ]

        if
            let topController = UIApplication.topViewController(),
           !disallowedControllers.contains(where: { topController.isKind(of: $0) })
        {
            DeeplinkManager.shared.executeDeeplinkTask()
        }
        
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
        ) -> Void) {
        let presentationOptions: UNNotificationPresentationOptions = [.alert, .sound]
        completionHandler(presentationOptions)
    }
}

// MARK: - Firebase Puush
extension AppDelegate: MessagingDelegate {

    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        print("Firebase registration token: \(fcmToken?.description ?? "")")
        fcmPushToken = fcmToken
    }
}
