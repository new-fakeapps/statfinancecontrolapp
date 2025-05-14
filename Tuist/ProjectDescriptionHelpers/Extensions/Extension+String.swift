//
//  Extension+String.swift
//  ProjectDescriptionHelpers
//
//  Created by Egor Sakhabaev on 28.01.2022.
//

import Foundation

public extension String {
    
    var capitalizeFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }
    
    var json: [String: AnyObject]? {
       if let data = data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
       }
       return nil
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

}
