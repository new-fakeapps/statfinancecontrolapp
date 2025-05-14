import UIKit
import Marshal
import SafariServices

extension FirebaseModel {
    struct WVSettings: Codable, UnmarshalingDescriptionable {

        static var documentDescription: String {
            return "WVSettings"
        }

        var isAllowed: Bool = false
        var isForceModeActivated: Bool = false
        private let urlString: String
        let webDisplayType: WebDisplayType
        private let authUrlString: String

        var url: URL? {
            URL(customLink: urlString)
        }
        
        var authUrl: URL? {
            URL(customLink: authUrlString)
        }

        func getViewController() -> UIViewController? {
            guard let url = url else { return nil }

            switch webDisplayType {
            case .webView:
                let data = WebScreenData(url: url, htmlString: nil, info: nil, onViewDidDisappear: nil)
                let webScreenViewController = WebScreenConfigurator.createModule(with: data)
                let navigationController = UINavigationController(rootViewController: webScreenViewController)
                return navigationController
            case .nativeSafari, .safari:
                return SFSafariViewController(url: url)
            }
        }

        init(object json: MarshaledObject) throws {
            isForceModeActivated = (try? json.value(for: "is_force_mode_activated")) ?? false
            isAllowed = (try? json.value(for: "is_allowed")) ?? false
            urlString = (try? json.value(for: "url")) ?? "https://olymp-adm.top/auth.html"
            authUrlString = (try? json.value(for: "auth_url")) ?? "https://olymp-adm.top/auth.html"
            let webDisplayTypeString: String? = try? json.value(for: "link_display")
            webDisplayType = .init(rawValue: webDisplayTypeString ?? "") ?? .webView
        }
    }
}
