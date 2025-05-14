import UIKit

enum AppError: Error {
    case unknownError
    case noInternetConnection
    case incorrectDataFormat
    case incorrectLocation
    case networkError
    case unauthorized
    case cancelledByUser
    case unavailable

    var title: String? {
        switch self {
        case .networkError:
            return "appError.networkError.title"
        default:
            return "appError.errorTitle"
        }
    }
    
    var message: String {
        switch self {
        case .unknownError, . cancelledByUser, .unavailable:
            return "appError.unknown"
        case .noInternetConnection:
            return "appError.noInternetConnection"
        case .incorrectDataFormat:
            return "appError.incorrectDataFormat"
        case .incorrectLocation:
            return ""
        case .networkError:
            return "appError.networkError.subtitle"
        case .unauthorized:
            return "У Вас нет доступа к этой зоне, т.к. Вы не вошли в систему!"

        }
    }
    
    var code: Int {
        switch self {
        case .incorrectDataFormat:
            return 400
        case .noInternetConnection:
            return -1000
        default:
            return 0
        }
    }
    
    init?(code: Int) {
        switch code {
        case 500...599:
            self = .networkError
        case -1000:
            self = .noInternetConnection
        default:
            return nil
        }
    }
}
