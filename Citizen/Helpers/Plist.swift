//
//  Plist.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct Plist {
    enum Key: String {
        case appID = "App ID"
        case annualProduct = "Annual Product"
        case monthlyProduct = "Monthly Product"
        case developerLink = "Developer Link"
        case termsOfUse = "Terms of Use"
        case privacyPolicy = "Privacy Policy"
    }
    
    static private let plistName = "Property List"
    
    static func get(_ key: Key) -> String {
        guard let url = Bundle.main.url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let value = dict[key.rawValue] as? String else { return "" }
        return value
    }
}
