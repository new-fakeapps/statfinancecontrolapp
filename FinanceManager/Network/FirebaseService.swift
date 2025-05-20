import Foundation
import PromiseKit
import FirebaseFirestore

class FirebaseService {

    static let shared = FirebaseService()

    var appName: String = appConfig.appSpecification.appName
    func enableAutoSync() {
        disableAutoSync()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sync),
            name: AppNotes.didPassSecond.notification,
            object: nil
        )
    }

    func disableAutoSync() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Actions
extension FirebaseService {

    @objc
    private func sync(_ sender: Any) {

    }
}

// MARK: - Privates
extension FirebaseService {

    func getAppSettings(sourceType: FirestoreSource = .server) -> Promise<FirebaseModel> {

        let apiSettingsPromise = getApiSettings()
        return Promise { resolver in
            let firebaseModelStored = AppSettings.firebaseModelStored
            when(resolved: [apiSettingsPromise.asVoid()])
                .done { firebaseModel in
                    if let firebaseModel = apiSettingsPromise.value {
                        AppSettings.firebaseModelStored = firebaseModel
                        resolver.fulfill(firebaseModel)
                    } else {
                        AppSettings.firebaseModel = firebaseModelStored
                        resolver.reject(apiSettingsPromise.error ?? AppError.unknownError)
                    }
                }
                .catch { error in
                    let firebaseModel = firebaseModelStored
                    AppSettings.firebaseModel = firebaseModel
                    resolver.reject(error)
                }
        }
    }

    private func getApiSettings() -> Promise<FirebaseModel> {
        FirebaseService.shared.getFirestoreAppSettings()
    }

    private func getSettings<T: UnmarshalingDescriptionable>(settingsClass: T.Type, collection: QuerySnapshot) -> T? {
        guard let json = (collection.documents.first { $0.documentID == T.documentDescription })?.data(),
              let model = try? T(object: json) else {
                  return nil
              }
        return model
    }

    private func getSettingsCollection(
        sourceType: FirestoreSource,
        completion: @escaping (
            _ settingsResult: (snapshot: QuerySnapshot?, error: Error?)
        ) -> Void
    ) {
        let db = Firestore.firestore()
        let group = DispatchGroup()

        group.enter()
        var settingsResult: (snapshot: QuerySnapshot?, error: Error?) = (nil, AppError.unknownError)
        db.collection("AppSettings").document("InternalSettings").collection("FinanceApp").getDocuments { (querySnapshot, error) in
            settingsResult = (querySnapshot, error)
            group.leave()
        }

        group.notify(queue: .main) {
            completion(settingsResult)
        }
    }

    private func getFirestoreAppSettings(sourceType: FirestoreSource = .default) -> Promise<FirebaseModel> {
        return Promise { resolver in
            getSettingsCollection(sourceType: sourceType) { (settingsResult) in
                if let error = settingsResult.error {
                    print("❌ Ошибка запроса Firestore: \(error.localizedDescription)")
                    resolver.reject(error)
                    return
                }
                guard let settingsCollection = settingsResult.snapshot, settingsCollection.count > 0 else {
                    print("❌ Коллекция настроек пуста или отсутствует")
                    resolver.reject(AppError.incorrectDataFormat)
                    return
                }

                print("✅ Получена коллекция настроек из Firestore: \(settingsCollection.documents.count) документов")
                // Выводим имена всех документов
                for doc in settingsCollection.documents {
                    print("📄 Документ: \(doc.documentID), данные: \(doc.data())")
                }

                let wvSettings = self.getSettings(settingsClass: FirebaseModel.WVSettings.self, collection: settingsCollection)
                print("🌐 WVSettings: \(String(describing: wvSettings))")
                if let wvSettings = wvSettings {
                    print("🔗 Auth URL: \(String(describing: wvSettings.authUrl))")
                    print("🔗 Redirect URL: \(String(describing: wvSettings))")
                }
                
                let locationRestrictions = self.getSettings(settingsClass: FirebaseModel.LocationRestrictions.self, collection: settingsCollection)
                let appSettings = self.getSettings(settingsClass: FirebaseModel.AppSettings.self, collection: settingsCollection)
                let versionSettings = self.getSettings(settingsClass: FirebaseModel.VersionSettings.self, collection: settingsCollection)
                let firebaseModel = FirebaseModel(
                    wvSettings: wvSettings,
                    locationRestrictions: nil,
                    appSettings: nil,
                    versionSettings: nil
                )

                resolver.fulfill(firebaseModel)
            }
        }
    }
}
