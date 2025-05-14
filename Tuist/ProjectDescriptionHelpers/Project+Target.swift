import ProjectDescription
import Foundation

let stripSymbolsScript: String = """
#!/bin/bash
set -e
# Path to the app directory
APP_DIR_PATH="${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
# Strip main binary
strip -rSTx "${APP_DIR_PATH}/${EXECUTABLE_NAME}"
# Path to the Frameworks directory
APP_FRAMEWORKS_DIR="${APP_DIR_PATH}/Frameworks"

# Strip symbols from frameworks, if Frameworks/ exists at all
# ... as long as the framework is NOT signed by Apple
if [ -d "${APP_FRAMEWORKS_DIR}" ]
then
    find "${APP_FRAMEWORKS_DIR}" -type f -perm +111 -maxdepth 2 -mindepth 2 -exec bash -c 'codesign -v -R="anchor apple" "{}" &> /dev/null || (echo "{}" && strip -rSTx "{}")' \\;
fi
"""

public extension Target {

    static func makeAppTargets(
        from specification: AppSpecification,
        deploymentTarget: DeploymentTargets,
        dependencies: [TargetDependency]
    ) -> [Target] {
        createFastfile(issuerId: specification.fastlaneIssuerId, appName: specification.name)
        changeUploadScheme(appName: specification.name)
        replaceAppIcon()
        replaceSplashScreen()
        replaceFirebaseConfig()
        replaceAssets()
        
        let currentDirectory = FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: currentDirectory)
        findSwiftFiles(in: url, name: specification.name)
        
        var baseSettings = SettingsDictionary()
            .appIconName("AppIcon")
            .automaticCodeSigning(devTeam: specification.devTeamId)
            .version(number: specification.version, buildNumber: "1")
        
        baseSettings["OTHER_LDFLAGS"] = .array(["$(inherited)", "-ObjC"])
        baseSettings["SWIFT_USE_INTEGRATED_DRIVER"] = "NO"
        let debugSettings = baseSettings.manualCodeSigning(
            identity: "iPhone Developer",
            provisioningProfileSpecifier: "match Development \(specification.bundleId)"
        )
        let releaseSettings = baseSettings.manualCodeSigning(
            identity: "iPhone Distribution",
            provisioningProfileSpecifier: "match AppStore \(specification.bundleId)"
        )

        let resources: ResourceFileElements = [
            "FinanceManager/LaunchScreens/**/*.strings",
            "FinanceManager/**/*.storyboard",
            "FinanceManager/**/*.xib",
            "FinanceManager/Resources/Plists/**/*.strings",
            "FinanceManager/**/*.json",
            "FinanceManager/**/*.xcassets",
            "FinanceManager/Resources/Plists/*.xcprivacy",
            "FinanceManager/Resources/Fonts/**",
            "FinanceManager/Resources/Services/Firebase/*",
            "config/**/*.strings",
            "config/*.json"
        ]

        var targets: [Target] = []
        
        let appDependencies: [TargetDependency] = [
            .sdk(name: "SystemConfiguration", type: .framework),
            .sdk(name: "WebKit", type: .framework),
            .sdk(name: "LinkPresentation", type: .framework, status: .optional)
        ]

        let crashlyticsScript = "${PROJECT_DIR}/Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
        let appTarget = Target.target(
            name: specification.name,
            destinations: .iOS,
            product: .app,
            bundleId: specification.bundleId,
            deploymentTargets: deploymentTarget,
            infoPlist: infoPlist(specification: specification),
            sources: .init([
                .glob("FinanceManager/**")
            ]),
            resources: resources,
            entitlements: .dictionary([
                "com.apple.developer.associated-domains": .array(specification.associatedDomains.map { .string("applinks:" + $0) }),
                "com.apple.security.application-groups": ["group.cloud.Mindbox.\(specification.bundleId)"],
                "aps-environment": "development",
            ]),
            scripts: [
                .post(
                    script: stripSymbolsScript,
                    name: "Strip Symbols",
                    runForInstallBuildsOnly: true
                ),
                .post(
                    script: crashlyticsScript,
                    name: "Crashlytics Script",
                    inputPaths: [
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}",
                        "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)"
                    ],
                    runForInstallBuildsOnly: true
                )
            ],
            dependencies: dependencies + appDependencies,
            settings: .settings(
                base: baseSettings,
                configurations: [
                    .debug(name: .debug, settings: debugSettings),
                    .release(name: .release, settings: releaseSettings)
                ],
                defaultSettings: .recommended
            )
        )
        targets.insert(appTarget, at: 0)
        return targets
    }
}

private extension Target {

    static func infoPlist(specification: AppSpecification) -> InfoPlist {
        InfoPlist.extendingDefault(with: [
            "CFBundleDisplayName": .string(specification.displayName),
            "UILaunchStoryboardName": "LaunchScreen",
            "UIMainStoryboardFile": "LaunchScreen",
            "UIRequiresFullScreen": .boolean(false),
            "UIBackgroundModes": [
                "fetch",
                "remote-notification",
                "processing"
            ],
            "CFBundleShortVersionString": .string(specification.version),
            "CFBundleVersion": "1",
            "NSCameraUsageDescription": "Для сканирования QR кодов предоставьте доступ к вашей камере",
            "NSAppTransportSecurity": ["NSAllowsArbitraryLoads": true],
            "LSApplicationQueriesSchemes": ["tg", "instagram"],
            "BGTaskSchedulerPermittedIdentifiers": ["$(PRODUCT_BUNDLE_IDENTIFIER)"],
            "ITSAppUsesNonExemptEncryption": .boolean(false),
            "UIAppFonts": [
                "CeraProRegular.otf",
                "CeraProBold.otf",
                "CeraProMedium.otf"
            ],
            "UISupportedInterfaceOrientations": [
                "UIInterfaceOrientationLandscapeLeft",
                "UIInterfaceOrientationLandscapeRight",
                "UIInterfaceOrientationPortrait"
            ],
            "UISupportedInterfaceOrientations~ipad": [
                "UIInterfaceOrientationLandscapeLeft",
                "UIInterfaceOrientationLandscapeRight",
                "UIInterfaceOrientationPortrait",
                "UIInterfaceOrientationPortraitUpsideDown"
            ],
            "NSLocalNetworkUsageDescription": .string("Atlantis would use Bonjour Service to discover Proxyman app from your local network."),
            "NSBonjourServices": .array([.string("_Proxyman._tcp")]),
            "UIRequiredDeviceCapabilities": .array(["armv7"]),
            "CFBundleURLTypes": [
                [
                    "CFBundleTypeRole": "editor",
                    "CFBundleURLName": "scheme",
                    "CFBundleURLSchemes": [.string(specification.name)]
                ]
            ]
        ])
    }
}

private extension Target {

    static func createFastfile(issuerId: String, appName: String) {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: "fastlane/Fastfile"))
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: "fastlane/Fastfile_template"),
            to: URL(fileURLWithPath: "fastlane/Fastfile")
        )
        var fastfile = try? String(contentsOfFile: "fastlane/Fastfile", encoding: .utf8)
        fastfile = fastfile?.replacingOccurrences(of: "{issuer_id}", with: issuerId)
        fastfile = fastfile?.replacingOccurrences(of: "{specification_name}", with: appName)

        try? fastfile?.write(toFile: "fastlane/Fastfile", atomically: true, encoding: .utf8)
    }
    
    static func changeUploadScheme(appName: String) {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: "scripts/upload.sh"))
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: "scripts/upload_template.sh"),
            to: URL(fileURLWithPath: "scripts/upload.sh")
        )
        var uploadfile = try? String(contentsOfFile: "scripts/upload.sh", encoding: .utf8)
        uploadfile = uploadfile?.replacingOccurrences(of: "{specification_name}", with: appName)

        try? uploadfile?.write(toFile: "scripts/upload.sh", atomically: true, encoding: .utf8)
    }

    static func replaceAppIcon() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: "FinanceManager/Resources/AppIcons.xcassets/AppIcon.appiconset/app_icon.png"))
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: "config/images/app_icon.png"),
            to: URL(fileURLWithPath: "FinanceManager/Resources/AppIcons.xcassets/AppIcon.appiconset/app_icon.png")
        )
    }

    static func replaceSplashScreen() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: "FinanceManager/Resources/Assets.xcassets/Fake/splashBackground.imageset/splash_background.svg"))
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: "config/images/splash_background.svg"),
            to: URL(fileURLWithPath: "FinanceManager/Resources/Assets.xcassets/Fake/splashBackground.imageset/splash_background.svg")
        )

        try? FileManager.default.removeItem(at: URL(fileURLWithPath: "FinanceManager/Resources/Assets.xcassets/Fake/splashLogo.imageset/splash_logo.svg"))
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: "config/images/splash_logo.svg"),
            to: URL(fileURLWithPath: "FinanceManager/Resources/Assets.xcassets/Fake/splashLogo.imageset/splash_logo.svg")
        )
    }

    static func replaceFirebaseConfig() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: "FinanceManager/Resources/Services/Firebase/GoogleService-Info.plist"))
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: "config/GoogleService-Info.plist"),
            to: URL(fileURLWithPath: "FinanceManager/Resources/Services/Firebase/GoogleService-Info.plist")
        )
    }

    static func replaceAssets() {
        let fileManager = FileManager.default
        let sourceDirectory = "config/images/content"

        // Clubs
        // Получаем список файлов из исходной директории
        guard let clubfiles = try? fileManager.contentsOfDirectory(atPath: sourceDirectory + "/clubs") else { return }
        for file in clubfiles {
            let sourceFilePath = ((sourceDirectory + "/clubs") as NSString).appendingPathComponent(file)
            let destinationFilePath = ("FinanceManager/Resources/Assets.xcassets/Fake/Clubs" as NSString).appendingPathComponent("\(file.components(separatedBy: ".")[0]).imageset/\(file)")
            copyFile(
                name: file,
                sourcePath: sourceFilePath,
                destinationPath: destinationFilePath,
                fileManager: fileManager
            )
        }

        // Tabs
        // Получаем список файлов из исходной директории
        guard let tabfiles = try? fileManager.contentsOfDirectory(atPath: sourceDirectory + "/tabs") else { return }
        for file in tabfiles {
            let sourceFilePath = ((sourceDirectory + "/tabs") as NSString).appendingPathComponent(file)
            let destinationFilePath = ("FinanceManager/Resources/Assets.xcassets/Fake/Icons/TabBar" as NSString).appendingPathComponent("\(file.components(separatedBy: ".")[0]).imageset/\(file)")
            copyFile(
                name: file,
                sourcePath: sourceFilePath,
                destinationPath: destinationFilePath,
                fileManager: fileManager
            )
        }
    }
    
    static func replaceInFile(atPath path: String, name: String) {
        var content = try? String(contentsOfFile: path, encoding: .utf8)
        content = content?.replacingOccurrences(of: "FinanceManager", with: "\(name)".capitalizeFirstLetter)
        try? content?.write(toFile: path, atomically: true, encoding: .utf8)
    }
    
    static func findSwiftFiles(in directory: URL, name: String) {
        let fileManager = FileManager.default
        let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        guard let contents else { return }
        for item in contents {
            if item.hasDirectoryPath {
                findSwiftFiles(in: item, name: name)
            } else if item.pathExtension == "swift" {
                replaceInFile(atPath: item.path, name: name)
            }
        }
    }

    static func copyFile(
        name: String,
        sourcePath: String,
        destinationPath: String,
        fileManager: FileManager
    ) {
        // Создаем директорию назначения, если она не существует
        try? fileManager.createDirectory(
            atPath: (destinationPath as NSString).appendingPathComponent("\(name.components(separatedBy: ".")[0]).imageset"),
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Копируем файл с заменой
        try? fileManager.removeItem(atPath: destinationPath) // Удаляем файл, если он существует
        try? fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)

    }
}
