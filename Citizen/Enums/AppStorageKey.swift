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
    case devTest
    
    var key: String {
        switch self {
        case .theme: return "isThemeLight"
        case .haptics: return "isHapticsOff"
        case .language: return "AppleLanguages"
        case .sound: return "isSoundOff"
        case .devTest: return "devTest"
        }
    }
}
