import UIKit
import Marshal

struct FirebaseModel: Codable, Unmarshaling {

    var appSettings: AppSettings?
    var wvSettings: WVSettings?
    var locationRestrictions: LocationRestrictions?
    var versionSettings: VersionSettings?

    init(object json: MarshaledObject) throws {
        appSettings                     = try? json.value(for: AppSettings.documentDescription)
        wvSettings                      = try? json.value(for: WVSettings.documentDescription)
        locationRestrictions            = try? json.value(for: LocationRestrictions.documentDescription)
        versionSettings                 = try? json.value(for: VersionSettings.documentDescription)
    }
    
    init(
        wvSettings: WVSettings?,
        locationRestrictions: LocationRestrictions?,
        appSettings: AppSettings?,
        versionSettings: VersionSettings?
    ) {
        self.wvSettings = wvSettings
        self.locationRestrictions = locationRestrictions
        self.appSettings = appSettings
        self.versionSettings = versionSettings
    }
}

protocol UnmarshalingDescriptionable: Unmarshaling {
    static var documentDescription: String { get }
}
