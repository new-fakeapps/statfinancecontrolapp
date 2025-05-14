import UIKit
import Marshal
import SafariServices

extension FirebaseModel {
    struct AppSettings: Codable, UnmarshalingDescriptionable {

        static var documentDescription: String {
            return "AppSettings"
        }

        var promo: [String]
        var testPromos: [String]
        var activationRegions: [String]
        var isAutoActivationEnabled: Bool

        init(object json: MarshaledObject) throws {
            promo = (try? json.value(for: "promo")) ?? []
            testPromos = (try? json.value(for: "testPromos")) ?? []
            activationRegions = (try? json.value(for: "activation_regions")) ?? []
            isAutoActivationEnabled = (try? json.value(for: "is_auto_activation_enabled")) ?? false
        }
    }
}
