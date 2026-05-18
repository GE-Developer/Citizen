//
//  LanguageManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@Observable
final class LanguageManager {
    var currentLanguageID: String {
        didSet {
            defaults.set([currentLanguageID], forKey: key)
            defaults.synchronize()
            QuizRepository.shared.reload()
        }
    }
    
    var bundleGE: Bundle? {
        guard let path = Bundle.main.path(forResource: Language.georgian.id, ofType: "lproj") else {
            return .main
        }
        return Bundle(path: path)
    }
    
    var bundle: Bundle? {
        guard let path = Bundle.main.path(forResource: currentLanguageID, ofType: "lproj") else {
            return .main
        }
        return Bundle(path: path)
    }
    
    static let shared = LanguageManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.language.key
    
    private init() {
        let baseAppLanguage = Bundle.main.developmentLocalization ?? Language.english.id
        let baseUserLanguage = Bundle.main.preferredLocalizations.first
        
        currentLanguageID = baseUserLanguage ?? baseAppLanguage
    }
}
