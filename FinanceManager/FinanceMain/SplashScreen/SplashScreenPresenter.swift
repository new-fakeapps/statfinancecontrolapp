import UIKit
import CoreLocation
import PromiseKit

final class SplashScreenPresenter {

    // MARK: - Properties
    weak private var view: SplashScreenView?
    var interactor: SplashScreenInteractorInput?
    private let router: SplashScreenWireframeInterface
    private var refSelf: SplashScreenPresenter?
//    private var remoteNotificationsListStatus: RemoteNotificationsStatus?

    // MARK: - Initialization and deinitialization -
    init(
        interface: SplashScreenView,
        interactor: SplashScreenInteractorInput?,
        router: SplashScreenWireframeInterface
    ) {
        self.view = interface
        self.interactor = interactor
        self.router = router
        self.interactor?.fetchFirebaseAPI()
        refSelf = self
    }
}

// MARK: - SplashScreenPresenterInterface -
extension SplashScreenPresenter: SplashScreenPresenterInterface {

    func viewDidLoad() {}
    
    func viewWillAppear() {
        interactor?.fetchFirebaseAPI()
        interactor?.fetchIPInfo()
    }
}

// MARK: - SplashScreenInteractorOutput -
extension SplashScreenPresenter: SplashScreenInteractorOutput {

    func fetchedFirebaseAPI(firebaseModel: FirebaseModel) {
        delay(3) { [weak self] in
            self?.processNavigation()
        }
    }

    func fetchedFirebaseAPI(error: Error) {
        delay(3) { [weak self] in
            self?.processNavigation()
        }
    }
    
//    func fetchedRemoteNotificationsStatus(with status: RemoteNotificationsStatus?) {
//        guard remoteNotificationsListStatus != nil, AppSettings.isActivated else {
//            interactor?.registerForPushNotificationsList()
//            return
//        }
//        if remoteNotificationsListStatus != nil, remoteNotificationsListStatus != status {
//            status != .denied ? interactor?.registerForPushNotificationsList() : interactor?.unregisterForPushNotificationsList()
//            return
//        }
//        remoteNotificationsListStatus = status
//    }
//
//    func registeredForPushNotifications(with status: RemoteNotificationsStatus?) {
//        TapticEngine.impact.feedback(status == .denied || status == .disabled ? .heavy : .medium)
//        remoteNotificationsListStatus = status
//        openApp()
//    }
//
//    func unregisteredForPushNotifications(with status: RemoteNotificationsStatus?) {
//        TapticEngine.impact.feedback(status == .denied || status == .disabled ? .heavy : .medium)
//        remoteNotificationsListStatus = status
//        openApp()
//    }
}

// MARK: - Private methods
extension SplashScreenPresenter {
    
    @objc private func fetchNotificationsListStatus() {
        interactor?.fetchRemoteNotificationsListStatus()
    }
    
    @objc private func processNavigation() {
        let firebaseModel = AppSettings.firebaseModel
        
        if let versionSettings = firebaseModel?.versionSettings,
            firebaseModel?.versionSettings?.versionInfo == .forceUpdate {
            router.navigate(to: .forceUpdate(versionSettings: versionSettings))
            return
        }
        
        // 1. Автоактивация по региону
//        if
//            firebaseModel?.appSettings?.isAutoActivationEnabled == true,
//            firebaseModel?.wvSettings?.isAllowed == true,
//            firebaseModel?.appSettings?.activationRegions.contains("countryCode") == true
//        {
//
//            guard
//                let wvSettings = AppSettings.firebaseModel?.wvSettings,
//                var url = wvSettings.url
//            else {
//                router.navigate(to: .authorizationScreen)
//                return
//            }
//
//            url = prepareURL(url: url)
//            router.navigate(to: AppSettings.isLoggedIn
//                            ? .wvScreen(url: url, webDisplayType: .webView)
//                            : .authorizationScreen)
//            return
//        }
        
        // 2. Получаем настройки ограничений по регионам для различных версий прилы
        let countryRestrictions = firebaseModel?.locationRestrictions?.countryRestrictionsByVersions[AppSettings.version] ?? []

        // 3. Проверяем попадает ли регион пользователя под ограничения из Firebase
//        if
//            LocationManager.containsRestrictions(countryRestrictions: countryRestrictions),
//            !LocationManager.countryCodeFits(
//                LocationManager.getCountryCode(),
//                countryRestrictions: countryRestrictions
//            )
//        {
//            // 4. Перекидываем на нативный интерфейс
//            router.navigate(to: AppSettings.isLoggedIn ? .featureApp : .authorizationScreen)
//            return
//        }
        
        openApp()
    }

    private func verifyRealPromocode(promocode: String) {
//        let isEnabled = AppSettings.firebaseModel?.wvSettings?.isAllowed
//        let isPromocodeExist = AppSettings.firebaseModel?.appSettings?.promo.contains(promocode)
//        if isPromocodeExist == true, isEnabled == true {
//            AppSettings.isActivated = true
//            DeeplinkManager.shared.deeplink = nil
//            interactor?.fetchRemoteNotificationsListStatus()
//        } else {
//            openApp()
//        }
    }
    
    private func prepareURL(url: URL) -> URL {
//        var url = url
//        var urlComponents = URLComponents(string: url.absoluteString)
//        var queryItems: [URLQueryItem] = [.init(name: "app_type", value: "1")]
//
//        if let fcmToken = (UIApplication.shared.delegate as? AppDelegate)?.fcmPushToken {
//            queryItems.append(.init(name: "a_ssid", value: fcmToken))
//        }
//
////        if let mindboxSettings = appConfig.appSpecification.metrics.mindbox {
////            MindboxManager.shared.getDeviceUUID { mindboxUUID in
////                queryItems.append(.init(name: "mb_uuid", value: mindboxUUID))
////            }
////            queryItems.append(.init(name: "app_id", value: mindboxSettings.appId))
////        }
//        urlComponents?.queryItems = queryItems
//        url = urlComponents?.url ?? url
        return url
    }
    
    private func openApp() {
        print("\n[SplashScreenPresenter] openApp() called.")
        print("[SplashScreenPresenter] Current AppSettings.isTrust: \(AppSettings.isTrust)")
        print("[SplashScreenPresenter] Current AppSettings.isAgreement: \(AppSettings.isAgreement)")
        
        // Получаем URL из Firebase
        guard let wvSettings = AppSettings.firebaseModel?.wvSettings,
              let url = wvSettings.authUrl else {
            // Если нет URL, показываем запасной экран
            print("⚠️ [SplashScreenPresenter] Не получен URL из Firebase, отображаем экран авторизации")
            router.navigate(to: .authorizationScreen)
            return
        }
        
        print("🔗 [SplashScreenPresenter] Получен URL из Firebase: \(url.absoluteString)")
        
        // Проверка флагов для навигации
        if AppSettings.isAgreement {
            // Если соглашение принято, открываем FeatureApp
            print("📱 [SplashScreenPresenter] Agreement accepted, navigating to feature app")
            router.navigate(to: .featureApp)
            return
        } else if AppSettings.isTrust {
            // Если trust установлен, открываем webView
            print("🌐 [SplashScreenPresenter] Trust established, navigating to wvScreen with URL: \(url)")
            router.navigate(to: .wvScreen(url: url, webDisplayType: wvSettings.webDisplayType))
            return
        }
        
        // По умолчанию открываем авторизационный экран
        print("🔑 [SplashScreenPresenter] Defaulting to authorization screen")
        router.navigate(to: .authorizationScreen)
    }
}
