import UIKit
import WebKit

final class WebScreenPresenter {
    
    // MARK: - Properties
    weak private var view: WebScreenView?
    var interactor: WebScreenInteractorInput?
    private let router: WebScreenWireframeInterface
    
    private var data: WebScreenData
    var previousURL: URL?
    private var errorsCount = 0
    private var isVCModalPresented: Bool
    private var promocode: String?
//    private var remoteNotificationsListStatus: RemoteNotificationsStatus?
    
    // MARK: - Initialization and deinitialization -
    init(
        interface: WebScreenView,
        interactor: WebScreenInteractorInput?,
        router: WebScreenWireframeInterface,
        data: WebScreenData,
        isVCModalPresented: Bool,
        promocode: String?
    ) {
        self.view = interface
        self.interactor = interactor
        self.router = router
        self.data = data
        self.isVCModalPresented = isVCModalPresented
        self.promocode = promocode
    }
}

// MARK: - PayScreenPresenterInterface -
extension WebScreenPresenter: WebScreenPresenterInterface {
    
    func didReceiveTrustEvent() {
        // При получении события is_trust просто устанавливаем флаг
        // и позволяем сайту самому решать куда переходить
        print("📱 didReceiveTrustEvent: Флаг доверия установлен, ожидаем навигацию от сайта")
        
        // Теперь выполняем перезапуск приложения для проверки флага при запуске
        // Это необходимо, чтобы SplashScreenRouter проверил флаг и открыл webView
        DispatchQueue.main.async {
            // Получаем URL из Firebase для WebView
            if let authUrl = AppSettings.firebaseModel?.wvSettings?.authUrl {
                print("🔄 Перезапускаем навигацию с установленным флагом доверия")
                self.router.navigate(to: .webView)
            }
        }
    }
    
    func didReceiveAgreement() {
        router.navigate(to: .featureApp)
    }
    
    func shouldStartLoadWith(url: URL?) -> WKNavigationActionPolicy {
        let urlAbsoluteString = url?.absoluteString ?? ""
        print("🌐 Checking navigation policy for URL:", urlAbsoluteString)

        // Разрешаем about:blank, который используется многими WebView компонентами
        if urlAbsoluteString == "about:blank" {
            print("✓ Allowing about:blank")
            return .allow
        }

        // Если уже есть agreement, переходим в featureApp
        if AppSettings.isAgreement {
            print("📱 Agreement accepted, navigating to feature app")
            router.navigate(to: .featureApp)
            return .cancel
        }

        // После установки флага доверия разрешаем все навигации безусловно
        if AppSettings.isTrust {
            print("✅ Trust flag is set, allowing navigation to any URL: \(urlAbsoluteString)")
            return .allow
        }

        // По умолчанию также разрешаем все навигации
        print("✅ Allowing navigation to URL: \(urlAbsoluteString)")
        return .allow
    }

    func didSetPreviousPage(url: URL?) {
        self.previousURL = url
    }
    
    func didStartProvisionalNavigation(url: URL?) { }
    
    func didReceiveServerRedirectForProvisionalNavigation(url: URL?) {
        if let url = url, (data.info?[.redirect] as? Bool) == true {
            view?.stopLoading()
            router.navigate(to: .redirect(url: url))
            return
        }
    }
    
    func didFailLoadWithError(_ error: Error, url: String?) {
        guard
            (error as NSError).code == NSURLErrorCannotConnectToHost
        else {
            //displayError()
            return
        }
        errorsCount += 1
        guard errorsCount < 5 else {
            //displayError()
            return
        }
        delay(1.5) { [weak self] in
            self?.display()
        }
    }
    
    func didFinishLoad() {
        errorsCount = 0
        
        delay(1) { [weak self] in
            self?.didReceivePushURL()
        }
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        addNotificationObservers()
        
        if AppSettings.pushURL != nil {
            guard let url = URL(string: AppSettings.pushURL ?? "") else { return }
            data.url = url
            AppSettings.pushURL = nil
        }
        
        display()
        DeeplinkManager.shared.executeDeeplinkTask()
    }
    
    func viewDidDisappear() {
        data.onViewDidDisappear?()
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePushURL),
            name: AppNotes.didReceivePushURL.notification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
}

// MARK: - PayScreenInteractorOutput -
extension WebScreenPresenter: WebScreenInteractorOutput {
//
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
//        router.navigate(to: .webView)
//    }
//
//    func unregisteredForPushNotifications(with status: RemoteNotificationsStatus?) {
//        TapticEngine.impact.feedback(status == .denied || status == .disabled ? .heavy : .medium)
//        remoteNotificationsListStatus = status
//        router.navigate(to: .webView)
//    }
}

// MARK: - Privates
extension WebScreenPresenter {
    ///Метод вызывается при закртытии приложения
    @objc
    private func willResignActive() { }
    
    @objc
    private func didReceivePushURL() {
        guard let url = URL(string: AppSettings.pushURL ?? "") else { return }
        data.url = url
        AppSettings.pushURL = nil
        display()
    }
    
    private func display() {
        if let promocode {
            verifyRealPromocode(promocode: promocode)
            return
        }
        if let htmlString = data.htmlString {
            view?.display(htmlString: htmlString, baseURL: data.url)
        } else if let url = data.url {
            view?.display(url: url)
        }

    }
    
    private func verifyRealPromocode(promocode: String) {
//        let isEnabled = AppSettings.firebaseModel?.wvSettings?.isAllowed
//        let isPromocodeExist = AppSettings.firebaseModel?.appSettings?.promo.contains(promocode)
//        let isActivated = AppSettings.isActivated
//        self.promocode = nil
//
//        if isPromocodeExist == true, isEnabled == true, !isActivated {
//            AppSettings.isActivated = true
//            interactor?.fetchRemoteNotificationsStatus()
//        } else {
//            guard let authUrl = AppSettings.firebaseModel?.wvSettings?.authUrl, data.url != authUrl else { return }
//            view?.display(url: authUrl)
//        }
    }
}
