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
    
    static var screenWidth: CGFloat {
        if cachedScreenWidth > 0 {
            return cachedScreenWidth
        }
        
        guard let screen = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.screen })
            .first else {
            return 0
        }
        
        cachedScreenWidth = screen.bounds.width
        return cachedScreenWidth
    }
    
    private static var cachedHasHomeIndicator = false
    private static var cachedScreenWidth: CGFloat = 0
}
