import Foundation
import Marshal

extension FirebaseModel {
    struct LocationRestrictions: Codable, UnmarshalingDescriptionable {
        
        static var documentDescription: String {
            return "LocationRestrictions"
        }
        
        var countryRestrictionsByVersions: [String: [String]]
        
        init(object json: MarshaledObject) throws {
            countryRestrictionsByVersions = (try? json.any(for: kFirebaseCountryRestrictionsKey) as? [String: [String]]) ?? [:]
        }
    }
}

