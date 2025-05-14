////
////  LocalizationService.swift
////
////  Created by Egor Sakhabaev on 21.03.2022.
////
//
//import Foundation
//import PromiseKit
//
//public class LocalizationLocalProvider {
//
//    private var localizationBundle: Bundle
//    private var languageBundle: Bundle
//    static let shared = LocalizationLocalProvider()
//
//    public var identifier: String
//    public var availableLanguages: [String] {
//        localizationBundle.localizations
//    }
//
//    /**
//     - parameter localizationBundle: Required. The bundle which contains Localizable.strings file.
//     */
//    private init() {
//        self.identifier = Bundle.module.bundlePath
//        self.localizationBundle = Bundle.module
//        self.languageBundle = Bundle.module
//    }
//
//    public func updateLanguge(_ language: String) {
//        if
//            let path = localizationBundle.path(forResource: language, ofType: "lproj"),
//            let bundle = Bundle(path: path)
//        {
//            languageBundle = bundle
//        } else {
//            languageBundle = localizationBundle
//        }
//    }
//
//    @discardableResult
//    public func prepareData() -> Promise<Void> {
//        .value
//    }
//
//    func isLocalizationExist(forLangaugeCode languageCode: String) -> Bool {
//        availableLanguages.contains(languageCode)
//    }
//}
