import UIKit
import WebKit

struct AppSettings {
    
    // MARK: - Storage Properties

    @Storage(key: "isLoggedIn", defaultValue: false)
    static var isLoggedIn: Bool

    @Storage(key: "isTrust", defaultValue: false)
    static var isTrust: Bool

    @Storage(key: "isAgreement", defaultValue: false)
    static var isAgreement: Bool

    @Storage(key: "isActivated", defaultValue: false)
    static var isActivated

    @Storage(key: "isBonusPromoActivated", defaultValue: false)
    static var isBonusPromoActivated {
        didSet {
            NotificationCenter.default.post(name: .bonusPromoStatusChanged, object: nil)
        }
    }

    @Storage(key: "isQRCreated", defaultValue: false)
    static var isQRCreated
    
    @Storage(key: "activatedTestPromocode", defaultValue: nil)
    static var activatedTestPromocode: String?
    
    @Storage(key: "activatedTestPromocodes", defaultValue: [])
    static var activatedTestPromocodes: [String]

    static var IPv6: String?
    static var pushURL: String?
    
    static var installSource: String? {
        get {
            UserDefaults.standard.string(forKey: "installSource")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "installSource")
        }
    }

    @Storage(key: "firebaseModel", defaultValue: nil)
    private static var _firebaseModelStored: FirebaseModel?

        // MARK: - Other Properties

        static var firebaseModel: FirebaseModel?

        static var firebaseModelStored: FirebaseModel? {
            get {
                _firebaseModelStored
            }
            set {
                _firebaseModelStored = newValue
                firebaseModel = newValue
            }
        }
    
    // MARK: - Other Properties
    
//    static var appearance: Appearance = Appearance()

    static var allowedShowLastVersionUpdateInfo: Bool = true
    
    static var timeShiftOffset: TimeInterval {
        TimeInterval(TimeZone.current.secondsFromGMT() - (360 * 60))
    }
    
    static var timeShift: String {
        "\(Int(timeShiftOffset / 60))"
    }
    
    static let version: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    static let bundle: String = (Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? ""
    
    static let appScheme: String = {
        let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]]
        let supportedURLTypes = urlTypes?.compactMap { $0["CFBundleURLSchemes"] as? [String] }.flatMap { $0 } ?? []
        return supportedURLTypes.first ?? appConfig.appSpecification.appName
    }()
    
    static var wkProcessPool: WKProcessPool {
        get {
            guard #available(iOS 10, *) else {return WKProcessPool()}//There is crash on iOS 9 with NSKeyedUnarchiver and WKProcessPool
            var wkProcessPool: WKProcessPool?
            if let wkProcessPoolData = UserDefaults.standard.object(forKey: "wkProcessPool") as? Data {
                wkProcessPool = NSKeyedUnarchiver.unarchiveObject(with: wkProcessPoolData) as? WKProcessPool
            }
            if wkProcessPool == nil {
                wkProcessPool = WKProcessPool()
                let encoded = NSKeyedArchiver.archivedData(withRootObject: wkProcessPool!)
                UserDefaults.standard.set(encoded, forKey: "wkProcessPool")
            }
            return wkProcessPool!
        }
        set {
            guard #available(iOS 10, *) else {return}
            let encoded = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(encoded, forKey: "wkProcessPool")
        }
    }

    static func showLastVersionUpdateInfoIfNeeded() {
        if AppSettings.allowedShowLastVersionUpdateInfo,
           AppSettings.firebaseModel?.versionSettings?.versionInfo == .recommendedUpdate {
            AppSettings.allowedShowLastVersionUpdateInfo = false
        }
    }
    static func activate() {
        isActivated = true
        NotificationCenter.default.post(name: .isActivatedDidChange, object: nil)
    }
}
extension Notification.Name {
    static let isActivatedDidChange = Notification.Name("isActivatedDidChange")
}

extension Notification.Name {
    static let bonusPromoStatusChanged = Notification.Name("bonusPromoStatusChanged")
}
