import Foundation

enum WebDisplayType: String, Codable, CaseIterable {
    case webView
    case nativeSafari
    case safari
    
    init?(rawValue: String) {
        guard
            let type = (WebDisplayType.allCases.first {
                $0.rawValue.lowercased() == rawValue.lowercased()
            })
        else {
            return nil
        }
        self = type
    }
}
