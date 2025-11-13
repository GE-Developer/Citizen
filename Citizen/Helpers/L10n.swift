//
//  L10n.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

public func L10n(_ key: String) -> String {
    String(localized: .init(key), bundle: LanguageManager.shared.bundle)
}

public func L10nGE(_ key: String) -> String {
    String(localized: .init(key), bundle: LanguageManager.shared.bundleGE)
}
