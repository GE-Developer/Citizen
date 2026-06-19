//
//  AppIconManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import UIKit

final class AppIconManager {
    static private var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }
    
    static func currentIcon() -> AppIcon {
        let currentName = UIApplication.shared.alternateIconName
        return AppIcon.allCases.first { $0.appIconid == currentName } ?? .blackCitizen
    }
    
    static func setIcon(_ icon: AppIcon) async throws {
        guard supportsAlternateIcons else { return }
        try await UIApplication.shared.setAlternateIconName(icon.appIconid)
    }
    
    static func reset() async throws {
        try await setIcon(.blackCitizen)
    }
}
