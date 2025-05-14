// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
@preconcurrency import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

let packageSettings = PackageSettings(
    productTypes: [:],
    // To revert once we release Tuist 4
    targetSettings: [:]
)

#endif

let package = Package(
    name: "PackageName",
    dependencies:
        [
            .package(
                url: "https://github.com/Alamofire/Alamofire.git",
                .upToNextMajor(from: "4.0.0")
            ),
            .package(
                url: "https://github.com/firebase/firebase-ios-sdk.git",
                exact: "10.22.1"
            ),
            .package(
                url: "https://github.com/SDWebImage/SDWebImage.git",
                exact: "5.15.5" // 5.14.0 uses private API
            ),
//            .package(
//                url: "https://github.com/Banck/ios-sdk",
//                branch: "update"
//            ),
            .package(
                url: "https://github.com/Banck/SwiftEntryKit.git",
                branch: "fix/dismiss_completion"
            ),
            .package(
                url: "https://github.com/Banck/PMSuperButton.git",
                branch: "master"
            ),
            .package(
                url: "https://github.com/ninjaprox/NVActivityIndicatorView.git",
                .upToNextMajor(from: "4.0.0")
            ),
            .package(
                url: "https://github.com/utahiosmac/Marshal.git",
                .upToNextMajor(from: "1.0.0")
            ),
            .package(
                url: "https://github.com/airbnb/lottie-spm.git",
                .upToNextMinor(from: "4.4.3")
            ),
            .package(
                url: "https://github.com/RedMadRobot/input-mask-ios.git",
                .upToNextMajor(from: "6.0.0")
            ),
            .package(
                url: "https://github.com/hackiftekhar/IQKeyboardManager.git",
                .upToNextMajor(from: "6.0.0")
            ),
            .package(
                url: "https://github.com/Banck/PhoneNumberKit.git",
                branch: "update/3.3.3"
            ),
            .package(
                url: "https://github.com/Flight-School/AnyCodable",
                .upToNextMajor(from: "0.6.0")
            ),
            .package(
                url: "https://github.com/CosmicMind/Motion.git",
                branch: "development"
            ),
            .package(
                url: "https://github.com/efremidze/VisualEffectView.git",
                .upToNextMajor(from: "4.1.0")
            ),
            .package(
                url: "https://github.com/ChiliLabs/CHIPageControl.git",
                .upToNextMajor(from: "0.2.1")
            ),
            .package(
                url: "https://github.com/Banck/CollectionKit.git",
                branch: "feature/fix-remaining-height"
            ),
            .package(
                url: "https://github.com/mxcl/PromiseKit.git",
                .upToNextMajor(from: "6.17.0")
            ),
            .package(
                url: "https://github.com/PromiseKit/Foundation.git",
                .upToNextMajor(from: "3.4.0")
            ),
//            .package(
//                url: "https://github.com/PromiseKit/CoreLocation.git",
//                .upToNextMajor(from: "3.1.2")
//            ),
//            .package(
//                url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git",
//                exact: "6.11.0"
//            ),
            // This commit brings SPM support. The next commits works bad with CollectionKit
            .package(
                url: "https://github.com/Juanpe/SkeletonView.git",
                revision: "4b6f55cf66259d9ffd8b017267b89002f6de7964"
            ),
            .package(
                url: "https://github.com/Banck/FloatingPanel.git",
                branch: "develop"
            )
        ]
)
