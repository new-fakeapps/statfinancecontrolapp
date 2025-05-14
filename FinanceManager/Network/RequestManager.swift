import UIKit
import Alamofire

class RequestManager: SessionManager {
    static var standard = RequestManager(timeout: 12, retrier: Retrier())

    static func manager(for url: URL) -> RequestManager {
        return RequestManager.standard
    }

    init(timeout: TimeInterval?, retrier: Retrier?) {
        let configuration = URLSessionConfiguration.default
        if timeout != nil {
            configuration.timeoutIntervalForRequest = timeout!
        }
        super.init(configuration: configuration)
        self.retrier = retrier
    }

    func handledAuthError(response: DataResponse<Data>, completion: @escaping (_ session: String?) -> Void) -> Bool {
        return true
    }

    func handleNetworkError(_ rawResponse: DataResponse<Data>) -> String? {
        var networkEror: NSError?
        var requestId: String?

        var errorInfo: [String: String] = [:]
        errorInfo["raw_response"] = "\(rawResponse)"
        if let statusCode = rawResponse.response?.statusCode {
            errorInfo["response_status_code"] = statusCode.description
        }
        errorInfo["response_time"] = String(format: "%.3f", rawResponse.timeline.totalDuration) + " secs"

        if let headersData = try? JSONSerialization.data(
            withJSONObject: rawResponse.request?.allHTTPHeaderFields ?? [],
            options: []) {
            let theJSONText = String(data: headersData,
                                     encoding: .utf8)
            errorInfo["request_headers"] = theJSONText
        }

        if
            let requestBody = try? JSONSerialization.jsonObject(
                with: rawResponse.request?.httpBody ?? Data(),
                options: .allowFragments
            ) as? [String: Any],
            let jsonString = requestBody.getJsonString()
        {
            errorInfo["request_body"] = jsonString
        }

        if let httpMethod = rawResponse.request?.httpMethod {
            errorInfo["request_method"] = httpMethod
        }

        if let url = rawResponse.request?.url?.absoluteString {
            errorInfo["request_url"] = url
        }

        if let response = try? JSONSerialization.jsonObject(with: rawResponse.result.value ?? Data(), options: .allowFragments) as? [String: Any] {
            if let responseData = try? JSONSerialization.data(
                withJSONObject: response,
                options: []) {
                let theJSONText = String(data: responseData,
                                         encoding: .utf8)
                errorInfo["response"] = theJSONText
            }
        }  else if let error = rawResponse.result.error as NSError? {
            errorInfo["response"] = error.localizedDescription
            errorInfo["response_real_code"] = "\(error.code)"
            networkEror = NSError(domain: rawResponse.request?.url?.absoluteString ?? "", code: rawResponse.response?.statusCode ?? error.code, userInfo: errorInfo)
        }
        if networkEror == nil && (200...299).contains(rawResponse.response?.statusCode ?? 0) == false {
            networkEror = NSError(
                domain: rawResponse.request?.url?.absoluteString ?? "",
                code: rawResponse.response?.statusCode ?? 0,
                userInfo: errorInfo
            )
        }
        return requestId
    }
}

// MARK: - RequestRetrier
class Retrier: RequestRetrier {
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: RequestRetryCompletion) {
        let maxRetryCount: Int = 1
        let shouldRetry = request.retryCount < maxRetryCount
        completion(shouldRetry, 1.0)
    }
}
