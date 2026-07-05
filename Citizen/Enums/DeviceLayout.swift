//
//  DeviceLayout.swift
//  Citizen
//
//  Created by GE-Developer
//

import UIKit

@MainActor
enum DeviceLayout {
    static var hasHomeIndicator: Bool {
        if cachedHasHomeIndicator {
            return true
        }
        
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            return false
        }
        
        let hasIndicator = window.safeAreaInsets.bottom > 0
        if hasIndicator {
            cachedHasHomeIndicator = true
        }
        return hasIndicator
    }
    
    private static var cachedHasHomeIndicator = false
}
