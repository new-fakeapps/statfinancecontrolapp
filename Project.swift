import ProjectDescription
import ProjectDescriptionHelpers
import Foundation

let project = Project(
    name: "FinanceManager",
    settings: .settings(
        base: [
            "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "NO",
            "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES": "YES",
            "OTHER_SWIFT_FLAGS": "-Xcc -Wno-error=non-modular-include-in-framework-module"
        ]
    ),
    targets: targets(),
    resourceSynthesizers: [.assets(), .strings(), .fonts()]
)

func targets() -> [Target] {
    guard
        let appSpecificationJson = try? String(contentsOfFile: "config/build_config.json", encoding: .utf8).json,
        let appSpecification = AppSpecification(from: appSpecificationJson)
    else {
        fatalError("Check config/config.json")
    }

    let deploymentTarget: DeploymentTargets = .iOS("15.0")
    var targets: [Target] = []
    
    let dependencies: [TargetDependency] = [
        .external(name: "Alamofire"),
        .external(name: "PMSuperButton"),
        .external(name: "SwiftEntryKit"),
        .external(name: "SDWebImage"),
//        .external(name: "Mindbox"),
        .external(name: "Lottie"),
        .external(name: "NVActivityIndicatorView"),
        .external(name: "Marshal"),
        .external(name: "InputMask"),
        .external(name: "IQKeyboardManagerSwift"),
        .external(name: "PhoneNumberKit"),
        .external(name: "AnyCodable"),
        .external(name: "Motion"),
        .external(name: "VisualEffectView"),
        .external(name: "CHIPageControl"),
        .external(name: "FloatingPanel"),
        .external(name: "CollectionKit"),
        .external(name: "PromiseKit"),
//        .external(name: "PMKFoundation"),
//        .external(name: "PMKCoreLocation"),
//        .external(name: "AppsFlyerLib"),
        .external(name: "FirebaseCrashlytics"),
        .external(name: "FirebaseFirestore"),
        .external(name: "FirebaseMessaging"),
        .external(name: "FirebaseDynamicLinks"),
        .external(name: "FirebaseAnalytics"),
        .external(name: "SkeletonView")
    ]

    targets += Target.makeAppTargets(
        from: appSpecification,
        deploymentTarget: deploymentTarget,
        dependencies: dependencies
    )

    return targets
}
