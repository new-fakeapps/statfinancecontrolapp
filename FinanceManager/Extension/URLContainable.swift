import Foundation

protocol Host {
    var host: String { get }
    var url: String { get }
    var rawValue: String { get }
}

extension Host {
    public var url: String {
        return "\(self.host)\(self.rawValue)"
    }
}

protocol Endpoint {
    var path: String { get }
    var url: String { get }
    var rawValue: String { get }
}

extension Endpoint {
    public var url: String {
        return "\(self.path)\(self.rawValue)"
    }
}
