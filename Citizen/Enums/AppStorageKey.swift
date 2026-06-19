//
//  AppStorageKey.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AppStorageKey {
    case theme
    case haptics
    case language
    case sound
    case accentColor
    case devTest
    case screenshotProtection
    
    var key: String {
        switch self {
        case .theme: return "isDarkMode"
        case .haptics: return "isHapticsOn"
        case .language: return "AppleLanguages"
        case .sound: return "isSoundOn"
        case .accentColor: return "accentColor"
        case .devTest: return "devTest"
        case .screenshotProtection: return "screenshotProtection"
        }
    }
}
