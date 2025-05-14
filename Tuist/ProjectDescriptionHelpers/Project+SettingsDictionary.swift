import ProjectDescription

public extension SettingsDictionary {
    func appIconName(_ value: String) -> SettingsDictionary {
        merging(["ASSETCATALOG_COMPILER_APPICON_NAME": SettingValue(stringLiteral: value)])
    }

    func version(number: String, buildNumber: String) -> SettingsDictionary {
        return appleGenericVersioningSystem().merging([
            "CURRENT_PROJECT_VERSION": SettingValue(stringLiteral: buildNumber),
            "MARKETING_VERSION": SettingValue(stringLiteral: number)
        ])
    }
}
