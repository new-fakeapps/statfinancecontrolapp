import UIKit
import SafariServices
import FloatingPanel
import NVActivityIndicatorView

// placeholder protocol to detect vc's with sidemenu button
protocol MenuRevealable: AnyObject {
    var isActiveSideMenuRevealable: Bool { get }
}

extension MenuRevealable {
    var isActiveSideMenuRevealable: Bool { true }
}

protocol TabBarInsidable: AnyObject {
    var tabIndex: Int { get }
    var tabTitle: String { get }
    var tabImage: UIImage? { get }
}

class DeeplinkManager {
    static let shared = DeeplinkManager()
    var haveExecutedTask: Bool = false
    var deeplink: Deeplink?
    var previousDeeplinkDate: Date?
    
    private init() {}
    
    static func getViewController(by link: String) -> UIViewController? {
        guard let link = Deeplink.from(link) else { return nil }
        return link.vc
    }
    
    func handleRemoteNotification(with userInfo: [AnyHashable: Any]) {
        let firebaseDeeplink = userInfo["link"] as? String
        let mindboxDeeplink = userInfo["clickUrl"] as? String
        guard let link: String = firebaseDeeplink ?? mindboxDeeplink else { return }
        if link.contains(AppSettings.appScheme) {
            handle(link)
        } else {
            AppSettings.pushURL = link
            NotificationCenter.default.post(name: AppNotes.didReceivePushURL.notification, object: nil)
        }
    }
    
    func handle(_ link: String) {
        guard let deeplink = Deeplink.from(link) else { return }
        guard previousDeeplinkDate == nil || Date().timeIntervalSince(previousDeeplinkDate!) > 0.3 else { return }
        self.deeplink = deeplink
    }
    
    static func chooseVCAndTransition(vc: UIViewController) {
        vc.changeModalPresentationStyle()
        
        guard !AlertManager.isCurrentlyDisplaying else {
            AlertManager.closeCurrentAlert() {
                delay(0.1) {
                    DeeplinkManager.chooseVCAndTransition(vc: vc)
                }
            }
            return
        }
        guard let top = UIApplication.topViewController() else {
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
            return
        }
        
        if let nav = top.navigationController {
            if let vcNav = vc as? UINavigationController {
                if let menuRevealable = (vcNav.viewControllers.get(0) as? MenuRevealable),
                   menuRevealable.isActiveSideMenuRevealable {
                } else {
                    nav.present(vcNav, animated: false)
                }
            } else {
                if vc is SFSafariViewController {
                    nav.present(vc, animated: true)
                } else if vc is FloatingPanelController {
                    nav.present(vc, animated: true)
                } else {

                }
            }
        } else {
            top.present(vc, animated: true, completion: nil)
        }
    }
    
    @discardableResult
    func executeDeeplinkTask() -> Bool {
        if let deeplink = deeplink {
            let isHandledAppOpen = deeplink.task()
            self.deeplink = nil
            haveExecutedTask = isHandledAppOpen
            previousDeeplinkDate = Date()
            return true
        }
        return false
    }
    
    static var scheme: String {
        var appScheme: String = appConfig.appSpecification.appName
        if let urlType = (Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]])?.first,
           let scheme = (urlType["CFBundleURLSchemes"] as? [String])?.first {
            appScheme = scheme
        }
        appScheme += "://"
        return appScheme
    }
}

enum Deeplink {
    case safari(url: String)
    case link(url: String)
    case webView(url: String)
    case ourClubs
    case helpPage
    case promocodeScreen(promocode: String)
    case qrCodeScreen(promocode: String)
    case profilePage
    case authorization
    case fakeHistory

    var vc: UIViewController? {
        switch self {
        case .safari(let url):
            guard let url = URL(customLink: url) else { return nil }
            return SFSafariViewController(url: url)
        case let .webView(url):
            guard let url = URL(customLink: url) else { return nil }            
            let info: [WebScreenInfoKey: Any]? = nil
            let data = WebScreenData(url: url, htmlString: nil, info: info)
            let vc = WebScreenConfigurator.createModule(with: data, isVCModalPresented: true)
            
            return UINavigationController(rootViewController: vc)
        case .link(_), .ourClubs, .fakeHistory, .helpPage, .profilePage, .authorization:
            return nil
        case .promocodeScreen(let promocode):
            let data = WebScreenData(url: nil, htmlString: nil, info: nil, onViewDidDisappear: nil)
            let vc = WebScreenConfigurator.createModule(
                with: data,
                promocode: promocode
            )
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = vc
            return nil
        case .qrCodeScreen(let promocode):
            return nil
        }
    }

    var fullURL: String {
        let host = DeeplinkManager.scheme

        switch self {
        case .promocodeScreen(let code):
            return "\(host)\(DeeplinkPathName.promocodeScreen.rawValue)?code=\(code)"
        default:
            return ""
        }
    }
    
    ///Returns a value indicating whether the deeplink handle app launching (open first screens after SplashScreen)
    var task: (() -> Bool) {
        guard isAvailable else {
            return { return false }
        }

        DeeplinkManager.shared.previousDeeplinkDate = Date()

        switch self {
        case .link(let url):
            return {
                delay(0.001) {//Fixing app freeze. .main.asyc doesn't help.
                    guard let url = URL(customLink: url) else { return }
                    guard UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url)
                }
                return false
            }
        default:
            return {
                guard let vc = vc else {
                    return false
                }
                DeeplinkManager.chooseVCAndTransition(vc: vc)
                return true
            }
        }
    }
    
    var needAuth: Bool {
        return true
    }
    
    var isAvailable: Bool {
       return true
    }
    
    static func from(_ link: String) -> Deeplink? {
        let link = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? link
        guard
            let url = URL(customLink: link),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            var host = components.host
        else {
            return nil
        }

        var pathComponents = components.path.components(separatedBy: "/")
        pathComponents.removeFirst()

        var queryItems = components.queryItems
        if
            let items = queryItems,
            items.count > 1,
            let queryItemIndexWithURL = items.firstIndex(where: { $0.name == "url" })
        {
            let queryItemsBeforeURL = items[..<queryItemIndexWithURL]
            let value = items[queryItemIndexWithURL..<items.endIndex]
                .reduce("") { $0 + "\($1.name)=\($1.value ?? "")" + "&" }
                .drop { $0 != "=" }
                .dropFirst()
                .dropLast()
            let queryItemWithURL = URLQueryItem(
                name: "url",
                value: String(value)
            )
            queryItems = queryItemsBeforeURL + [queryItemWithURL]
        }

        host = pathComponents.first ?? host
        let deeplinkPathName = DeeplinkPathName(rawValue: host.lowercased())
        
        guard let hostType = deeplinkPathName else {
            let supportedURLTypes = (Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]])?.compactMap { $0["CFBundleURLSchemes"] as? [String] }.flatMap { $0 } ?? []
            if let scheme = components.scheme, supportedURLTypes.contains(scheme) {
                return nil
            } else {
                return .safari(url: url.absoluteString)
            }
        }
        
        switch hostType {
        case .link:
            guard
                var urlString = (queryItems?.first{ $0.name == "url" }?.value),
                let _ = URL(customLink: urlString)
            else {
                return nil
            }
            
            if let fragment = url.fragment {
                urlString = urlString + "#\(fragment)"
            }
            
            return .link(url: urlString)
        case .linkInside:
            guard
                var urlString = (queryItems?.first{ $0.name == "url" }?.value),
                let _ = URL(customLink: urlString)
            else {
                return nil
            }
            
            if let fragment = url.fragment {
                urlString = urlString + "#\(fragment)"
            }
            
            return .safari(url: urlString)
        case .webView:
            guard
                var urlString = (queryItems?.first{ $0.name == "url" }?.value),
                let _ = URL(customLink: urlString)
            else {
                return nil
            }
            let menuTypeString = queryItems?.first{ $0.name.lowercased() == "menuitemtype" }?.value?.getNilIfEmpty()
            
            if let fragment = url.fragment {
                urlString = urlString + "#\(fragment)"
            }
            
            return .webView(url: urlString)
        case .ourClubs:
            return .ourClubs
        case .fakeHistory:
            return .fakeHistory
        case .helpPage:
            return .helpPage
        case .qrCodeScreen:
               guard let promocode = (queryItems?.first{ $0.name == "code" }?.value)
            else {
                return nil
            }
            return .qrCodeScreen(promocode: promocode)
        case .promocodeScreen:
               guard let promocode = (queryItems?.first{ $0.name == "code" }?.value)
            else {
                return nil
            }
            return .promocodeScreen(promocode: promocode)
        case .profilePage:
            return .profilePage
        case .authorization:
            return .authorization
        }
    }
}

enum DeeplinkPathName: String, CaseIterable {
    case link            = "link"
    case linkInside      = "linkinside"
    case webView         = "webview"
    case ourClubs        = "ourclubs"
    case fakeHistory     = "fakehistory"
    case profilePage     = "profilepage"
    case authorization   = "authorization"
    case helpPage        = "helppage"
    case qrCodeScreen    = "qr"
    case promocodeScreen = "promo"
    
    init?(rawValue: String) {
        guard
            let type = (DeeplinkPathName.allCases.first { $0.rawValue.lowercased() == rawValue.lowercased() })
        else {
            return nil
        }
        self = type
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
