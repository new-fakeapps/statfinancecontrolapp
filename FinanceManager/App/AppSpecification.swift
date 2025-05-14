//
//  AppSpecification.swift
//
//  Created by Egor Sakhabaev on 10.11.2024.
//

import CoreGraphics
import UIKit

struct AppSpecification: Decodable {
    
    let appName: String
    let metrics: Metrics

    private enum CodingKeys: String, CodingKey {
        case appName    = "name"
        case metrics
    }
}

// MARK: - Metrics
extension AppSpecification {
    
    struct Metrics: Codable {
        
        struct Appsflyer: Codable {

            let devKey: String
            let appId: String
            
            enum CodingKeys: String, CodingKey {
                case devKey = "dev_key"
                case appId  = "app_id"
            }
        }
        
        struct Mindbox: Codable {
            
            let appId: String
            let domain: String
            let endpoint: String
            
            enum CodingKeys: String, CodingKey {
                case appId = "app_id"
                case domain, endpoint
            }
        }
        
        let appsflyer: Appsflyer?
        let mindbox: Mindbox?
    }
}

