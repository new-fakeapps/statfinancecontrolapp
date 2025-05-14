import Foundation

protocol Response {}

enum APIResponse: Response {
    case Success (response: [String: Any])
    case Error (code: Int?, message: String?, customData: [String: Any]?, requestId: String?)
}

enum APIDataResponse {
    case Success (response: Data)
    case Error (code: Int?, message: String?, customData: [String: Any]?, requestId: String?)
}

enum APIArrayResponse: Response {
    case Success (response: [[String: Any]])
    case Error (code: Int?, message: String?, customData: [String: Any]?, requestId: String?)
}

typealias ServerDataResult  = (_ response: APIDataResponse) -> Void
typealias ServerResult      = (_ response: APIResponse) -> Void
typealias ServerArrayResult = (_ response: APIArrayResponse) -> Void

typealias ServerResponse = (_ response: Response) -> Void

enum ResponseError: Error {
    case with(code: Int?, message: String?, requestId: String?)
}

extension Error {
    
    var code: Int {
        switch self as? ResponseError {
        case let .with(code, _, _):
            return code ?? AppError.unknownError.code
        case .none:
            let appError = (self as? AppError) ?? .unknownError
            return appError.code
        }
    }
    
    var title: String? {
        switch self as? ResponseError {
        case .with:
            return nil
        case .none:
            let appError = (self as? AppError) ?? .unknownError
            return appError.title
        }
    }
    
    var message: String {
        switch self as? ResponseError {
        case let .with(_, message, _):
            return message ?? AppError.unknownError.message
        case .none:
            let appError = (self as? AppError) ?? .unknownError
            return appError.message
        }
    }
    
    var requestId: String? {
        switch self as? ResponseError {
        case let .with(_, _, requestId):
            return requestId
        case .none:
            return nil
        }
    }
}
