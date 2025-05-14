//
//  AppSpecification.swift
//  Packages
//
//  Created by Sakhabaev Egor on 10.11.2024.
//

import Foundation
import ProjectDescription

public struct AppSpecification: Decodable {

    let name: String
    let displayName: String
    let bundleId: String
    let devTeamId: String
    let associatedDomains: [String]
    let fastlaneIssuerId: String
    let version: String

    private enum CodingKeys : String, CodingKey {
        case name
        case displayName        = "display_name"
        case bundleId           = "application_id"
        case devTeamId          = "dev_team_id"
        case associatedDomains  = "associated_domains"
        case fastlaneIssuerId   = "fastlane_issuer_id"
        case version            = "version"
    }

    public init?(from: Any) {
        guard let data = try? JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
        else { return nil }
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(Self.self, from: data) else { return nil }
        self = decoded
    }
}
