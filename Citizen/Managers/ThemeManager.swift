//
//  ThemeManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUICore

@Observable
final class ThemeManager {
    var isThemeLight: Bool {
        didSet { defaults.set(isThemeLight, forKey: key) }
    }
    
    var theme: ColorScheme {
        isThemeLight ? .light : .dark
    }
    
    static let shared = ThemeManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.theme.key
    
    private init() {
        isThemeLight = defaults.bool(forKey: key)
    }
}
