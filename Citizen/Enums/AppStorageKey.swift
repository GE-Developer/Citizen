//
//  AppStorageKey.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AppStorageKey {
    // MARK: User Settings
    case theme
    case haptics
    case language
    case sound
    case voiceActing
    case shuffleAnswers
    case shuffleQuestions
    case accentColor
    case devTest
    case screenshotProtection
    
    // MARK: Resource Downloader
    case resourcesVersion
    case contentVersions
    case mediaVersions
    
    // MARK: Account
    case installMarker
    case userNickname
    case userDataUpdatedAt
    case userAvatarURL
    case avatarUploadPending
    
    // MARK: Progress Sync State
    case syncLocalChangeCount
    case syncSyncedChangeCount
    case syncLastLocalChangeAt
    case syncServerUpdatedAt
    case syncLastUserID
    
    var key: String {
        switch self {
        case .theme: return "isDarkMode"
        case .haptics: return "isHapticsOn"
        case .language: return "AppleLanguages"
        case .sound: return "isSoundOn"
        case .voiceActing: return "isVoiceActingOn"
        case .shuffleAnswers: return "isShuffleAnswersOn"
        case .shuffleQuestions: return "isShuffleQuestionsOn"
        case .accentColor: return "accentColor"
        case .devTest: return "devTest"
        case .screenshotProtection: return "screenshotProtection"
        case .resourcesVersion: return "resourcesAppVersion"
        case .contentVersions: return "contentVersions"
        case .mediaVersions: return "mediaVersions"
        case .installMarker: return "installMarker"
        case .userNickname: return "userNickname"
        case .userDataUpdatedAt: return "userDataUpdatedAt"
        case .userAvatarURL: return "userAvatarURL"
        case .avatarUploadPending: return "avatarUploadPending"
        case .syncLocalChangeCount: return "syncLocalChangeCount"
        case .syncSyncedChangeCount: return "syncSyncedChangeCount"
        case .syncLastLocalChangeAt: return "syncLastLocalChangeAt"
        case .syncServerUpdatedAt: return "syncServerUpdatedAt"
        case .syncLastUserID: return "syncLastUserID"
        }
    }
}
