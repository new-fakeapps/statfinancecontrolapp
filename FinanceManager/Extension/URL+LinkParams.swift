import Foundation

extension URL {
    
    init?(customLink: String?) {
        guard var url = customLink?.getNilIfEmpty() else {
            return nil
        }

        let appScheme = DeeplinkManager.scheme.replacingOccurrences(of: "://", with: "")
        
        url = (url.removingPercentEncoding?.removingPercentEncoding ?? url)
            .replacingOccurrences(of: "{scheme}", with: appScheme)
        
        if #unavailable(iOS 17.0) {
            url = customLink ?? ""
        }
        
        if let url = URL(string: url) {
            self = url
        } else {
            return nil
        }
    }
}
