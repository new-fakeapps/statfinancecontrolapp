import UIKit
import WebKit
import CollectionKit

class WebScreenViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: WebScreenPresenterInterface?
    
    private let progressBar = TimerProgressBar()
    private var isSideMenuRevealable: Bool = false
    private var lastError: Error?
    
    private lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences = preferences
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "iosListener")
        configuration.userContentController = contentController

        if #available(iOS 10, *) {
            configuration.processPool = AppSettings.wkProcessPool
        }
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        if let defaultUserAgent = webView.value(forKey: "userAgent") as? String {
            webView.customUserAgent = defaultUserAgent + " native"
        }
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()
    
    private lazy var backButton: UIBarButtonItem = {
        let backButton = UIBarButtonItem(
            image: UIImage(named: "backIcon"),
            style: .done,
            target: self,
            action: #selector(btnBackAction)
        )
        backButton.tintColor = .white
        return backButton
    }()
    
    private lazy var refreshButton: UIBarButtonItem = {
        let refreshButton = UIBarButtonItem(
            image: UIImage(named: "refreshItemIcon"),
            style: .plain,
            target: self,
            action: #selector(btnReloadAction)
        )
        refreshButton.tintColor = .white
        return refreshButton
    }()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureUI()
        configureJavaScriptLogging()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.viewDidDisappear()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }
    
    private func configureJavaScriptLogging() {
        // Перехватываем JavaScript консоль для отладки
        let script = """
        console.log = function(message) {
            window.webkit.messageHandlers.iosListener.postMessage('JS_LOG: ' + message);
        };
        console.error = function(message) {
            window.webkit.messageHandlers.iosListener.postMessage('JS_ERROR: ' + message);
        };
        """
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(userScript)
    }
}

// MARK: - UIConfiguration
extension WebScreenViewController {
    
    func setupLayout() {
        view.addSubview(webView)
        webView.fillSuperview()
    }
    
    func configureUI() {
        navigationItem.rightBarButtonItems = [refreshButton]

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        webView.addSubview(progressBar)
    }
}

// MARK: - PayScreenView
extension WebScreenViewController: WebScreenView {
    
    func display(url: URL) {
        print("📱 Загружаем URL: \(url.absoluteString)")
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 60.0 // Увеличиваем таймаут до 60 секунд
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData // Игнорируем кэш для свежих данных
        
        if let authUrl = AppSettings.firebaseModel?.wvSettings?.authUrl, authUrl == url {
            navigationItem.leftBarButtonItems = []
        } else {
            navigationItem.leftBarButtonItems = [backButton]
        }
        
        // Сбрасываем последнюю ошибку при новой загрузке
        lastError = nil
        webView.load(urlRequest)
    }
    
    func display(htmlString: String, baseURL: URL?) {
        print("📄 Загружаем HTML контент с базовым URL: \(baseURL?.absoluteString ?? "nil")")
        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }
    
    func stopLoading() {
        print("⛔ Остановка загрузки")
        webView.stopLoading()
    }
    
    func sideMenuRevealable(isActive: Bool) {
        isSideMenuRevealable = isActive
    }
    
    // Добавляем публичный метод для перезагрузки при ошибке
    func reloadAfterError() {
        print("🔄 Перезагрузка после ошибки")
        webView.reload()
    }
}

// MARK: - Actions
extension WebScreenViewController {

    @objc
    private func didRefreshWebView() {
        presenter?.viewDidLoad()
    }
    
    @objc
    private func btnBackAction(_ sender: UIButton) {
        webView.goBack()
    }
    
    @objc
    private func btnReloadAction(_ sender: Any) {
        print("🔄 Ручная перезагрузка")
        webView.reload()
    }
}

// MARK: - WKNavigationDelegate
extension WebScreenViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("🚀 Начало загрузки: \(webView.url?.absoluteString ?? "unknown")")
        progressBar.startLoading(frequency: 0.1)
        presenter?.didStartProvisionalNavigation(url: webView.url)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("📶 Получены первые данные: \(webView.url?.absoluteString ?? "unknown")")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ Загрузка успешно завершена: \(webView.url?.absoluteString ?? "unknown")")
        
        // Проверяем, загрузилась ли страница действительно
        webView.evaluateJavaScript("document.body.innerHTML.length") { (result, error) in
            if let contentLength = result as? Int {
                print("📏 Длина контента страницы: \(contentLength)")
                if contentLength < 10 {
                    print("⚠️ Страница загрузилась, но контент очень короткий")
                }
            }
        }
        
        presenter?.didFinishLoad()
        progressBar.stopLoading()
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        
        let url = navigationAction.request.url
        print("🧭 Решение о навигации: тип=\(navigationAction.navigationType.rawValue), URL=\(url?.absoluteString ?? "nil")")

        if let mainHostURL = AppSettings.firebaseModel?.wvSettings?.authUrl?.host,
           let currentHostURL = navigationAction.request.url?.host,
           currentHostURL.contains(mainHostURL) {
            presenter?.didSetPreviousPage(url: navigationAction.request.url)
        }
        
        let handler = presenter?.shouldStartLoadWith(url: url) ?? .allow
        print(handler == .allow ? "✅ Разрешено" : "❌ Запрещено")
        return decisionHandler(handler)
    }
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        let nsError = error as NSError
        lastError = error
        
        print("❌ Ошибка при подготовке навигации: код=\(nsError.code), описание=\(error.localizedDescription)")
        if let urlString = nsError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String {
            print("🔗 URL с ошибкой: \(urlString)")
        }
        
        // Обработка конкретных ошибок
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut:
                print("⏱️ Таймаут соединения. Попробуйте увеличить timeoutInterval")
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                print("🔍 Не удалось найти или подключиться к хосту. Проверьте доступность сервера")
            case NSURLErrorNetworkConnectionLost:
                print("📡 Соединение потеряно. Проверьте стабильность сети")
            case NSURLErrorNotConnectedToInternet:
                print("🌐 Нет подключения к интернету")
            default:
                print("🧩 Другая ошибка URL: \(nsError.code)")
            }
        }
        
        presenter?.didFailLoadWithError(error, url: nsError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String)
        progressBar.stopLoading()
        
        // Автоматическая повторная попытка для определенных ошибок
        if nsError.domain == NSURLErrorDomain &&
           (nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorNetworkConnectionLost) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                if self?.webView.isLoading == false {
                    print("🔄 Автоматическая повторная попытка после ошибки сети")
                    self?.webView.reload()
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Ошибка во время загрузки: \(error.localizedDescription)")
        lastError = error
        progressBar.stopLoading()
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("↪️ Получен редирект на: \(webView.url?.absoluteString ?? "unknown")")
        presenter?.didReceiveServerRedirectForProvisionalNavigation(url: webView.url)
    }
}

// MARK: - WKUIDelegate
extension WebScreenViewController: WKUIDelegate {
    
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        print("🔗 Запрос на открытие нового окна: \(navigationAction.request.url?.absoluteString ?? "unknown")")
        if navigationAction.targetFrame == nil {
            print("🔄 Загружаем в текущем окне, т.к. targetFrame == nil")
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("🔔 JavaScript Alert: \(message)")
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        
        present(alertController, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("❓ JavaScript Confirm: \(message)")
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        
        present(alertController, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension WebScreenViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
}

// MARK: - WKScriptMessageHandler
extension WebScreenViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "iosListener" else { return }

        print("📩 Получено сообщение из JS: \(message.body)")

        // Игнорируем JavaScript логи
        if let body = message.body as? String {
            if body.hasPrefix("JS_LOG:") || body.hasPrefix("JS_ERROR:") {
                return
            }
        }

        // Обрабатываем сообщения от JavaScript
        if let jsonString = message.body as? String,
           let data = jsonString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            if let isTrust = json["is_trust"] as? String, isTrust == "true" {
                print("✅ is_trust = true → сохраняем в Storage")
                AppSettings.isTrust = true
                
                // Просто устанавливаем флаг и позволяем сайту самому управлять навигацией
                // НЕ хардкодим URL для перехода
                print("🔄 Установлен флаг доверия, ожидаем навигацию от сайта")
                return
            }

            if let agreement = json["agreement"] as? String, agreement == "accepted" {
                print("📄 agreement = accepted → сохраняем в Storage и переходим в featureApp")
                AppSettings.isAgreement = true
                presenter?.didReceiveAgreement()
                return
            }
        } else {
            print("⚠️ Не удалось распарсить message.body:", message.body)
        }
    }
}

