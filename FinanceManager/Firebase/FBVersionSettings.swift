import Foundation
import Marshal

extension FirebaseModel {
    
    struct VersionSettings: Codable, UnmarshalingDescriptionable {
        static var documentDescription: String {
            return "VersionSettings"
        }
        
        var versionInfo: VersionInfo {
             VersionInfo.getVersionInfo(
                currentVersion: FirebaseModel.VersionSettings.currentVersion,
                latestAppVersion: latestAppVersion ?? "",
                minimalAppVersion: minimalAppVersion ?? "",
                recommendedAppVersion: recommendedAppVersion ?? ""
            )
        }

        var latestAppVersion: String?
        var minimalAppVersion: String?
        var recommendedAppVersion: String?

        var updateURL: URL?

        init(object json: MarshaledObject) throws {
            latestAppVersion = (try? json.value(for: "latest_app_version"))
            minimalAppVersion = (try? json.value(for: "minimal_app_version"))
            recommendedAppVersion = (try? json.value(for: "recommended_app_version"))
            let updateURLString: String = (try? json.value(for: "update_url")) ?? ""
            updateURL = URL(string: updateURLString)
        }
        
        enum VersionInfo: String, Codable {
            case latest // У пользователя последняя версия приложения, ничего не нужно
            case mayUpdate // У пользователя не последняя версия прилы, он может обновиться, рисуем только кнопку "обновить"
            case recommendedUpdate // У пользователя не последняя версия прилы, он может обновиться, рисуем кнопку "обновить" и при старте показываем единоразово диалог с просьбой обновить версию (+ описание из short_description из фб)
            case forceUpdate // У пользователя слишком старая версия прилы, ему после сплэша сразу открывает экран форс апдейта с которого никуда нельзя уйти (кроме как обновиться)
            
            static func getVersionInfo(
                currentVersion: String,
                latestAppVersion: String,
                minimalAppVersion: String,
                recommendedAppVersion: String
            ) -> VersionInfo {
                let isMinimalAppVersion = AppManager.supportedVersion(
                    currentVersion: currentVersion,
                    version: minimalAppVersion,
                    comparisonResult: .orderedDescending
                )
                let isRecommendedAppVersion = AppManager.supportedVersion(
                    currentVersion: currentVersion,
                    version: recommendedAppVersion,
                    comparisonResult: .orderedDescending
                )
                let isLatestAppVersion = AppManager.supportedVersion(
                    currentVersion: currentVersion,
                    version: latestAppVersion,
                    comparisonResult: .orderedDescending
                )
                
                if !isMinimalAppVersion {
                    return .forceUpdate
                } else if !isRecommendedAppVersion {
                    return .recommendedUpdate
                } else if !isLatestAppVersion {
                    return .mayUpdate
                } else {
                    return .latest
                }
            }
        }
    }
}

extension FirebaseModel.VersionSettings {
    
    static var currentVersion: String {
        AppSettings.version
    }
}
