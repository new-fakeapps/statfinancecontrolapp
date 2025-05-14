import Foundation

struct AppManager {
    
    /// Возвращает логическое значение, указывающее, содержит ли последовательность указанную версию приложения
    static func contains(version: String, in versions: [String]) -> Bool {
        if versions.isEmpty {
            return false
        }
        
        if versions.contains("*") || versions.contains(version) {
            return true
        }
        
        return versions.contains {
            if $0.hasSuffix("...") { // после версии "version..."
                let preparedVersion = $0.replacingOccurrences(of: "...", with: "")
                return supportedVersion(currentVersion: version,
                                        version: preparedVersion,
                                        comparisonResult: .orderedDescending)
            } else if $0.hasPrefix("...") { // до версии "...version"
                let preparedVersion = $0.replacingOccurrences(of: "...", with: "")
                return supportedVersion(currentVersion: version,
                                        version: preparedVersion,
                                        comparisonResult: .orderedAscending)
            } else if $0.contains("...") { // диапазон "version...version"
                let versionComponents = $0.components(separatedBy: "...")
                guard versionComponents.count == 2 else { return false }
                let leftVersion = supportedVersion(currentVersion: version,
                                                   version: versionComponents[0],
                                                   comparisonResult: .orderedDescending)
                let rightVersion = supportedVersion(currentVersion: version,
                                                    version: versionComponents[1],
                                                    comparisonResult: .orderedAscending)
                return leftVersion && rightVersion
            } else {
                return false
            }
        }
    }
    
    /// Возвращает логическое значение, указывающее, содержит ли последовательность текущую версию приложения
    static func containsCurrentVersion(versions: [String]) -> Bool {
        contains(version: AppSettings.version, in: versions)
    }
    
    static func supportedVersion(
        currentVersion: String,
        version: String,
        comparisonResult: ComparisonResult
    ) -> Bool {
        let versionDelimiter: String = "."
        var currentVerisonComponents = currentVersion.components(separatedBy: versionDelimiter)
        var verisonComponents = version.components(separatedBy: versionDelimiter)
        let spareCount = currentVerisonComponents.count - verisonComponents.count
        
        var result: ComparisonResult = .orderedSame
        
        if spareCount == 0 {
            result = currentVersion.compare(version, options: .numeric)
        } else {
            let spareZeros = repeatElement("0", count: abs(spareCount))
            if spareCount > 0 {
                verisonComponents.append(contentsOf: spareZeros)
            } else {
                currentVerisonComponents.append(contentsOf: spareZeros)
            }
            result = currentVerisonComponents.joined(separator: versionDelimiter)
                .compare(verisonComponents.joined(separator: versionDelimiter), options: .numeric)
        }
        return result == comparisonResult || currentVersion == version
    }
}
