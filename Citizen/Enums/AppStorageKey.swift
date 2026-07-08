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
    case voiceActing
    case shuffleAnswers
    case accentColor
    case devTest
    case screenshotProtection
    case resourcesVersion
    
    var key: String {
        switch self {
        case .theme: return "isDarkMode"
        case .haptics: return "isHapticsOn"
        case .language: return "AppleLanguages"
        case .sound: return "isSoundOn"
        case .voiceActing: return "isVoiceActingOn"
        case .shuffleAnswers: return "isShuffleAnswersOn"
        case .accentColor: return "accentColor"
        case .devTest: return "devTest"
        case .screenshotProtection: return "screenshotProtection"
        case .resourcesVersion: return "resourcesAppVersion"
        }
    }
}
