//
//  DictionarySortOrder.swift
//  Citizen
//
//  Created by GE-Developer
//

enum DictionarySortOrder: CaseIterable, Identifiable {
    case recent
    case alphabetical
    
    var id: Self { self }
    
    @MainActor
    var title: String {
        switch self {
        case .recent:
            L10n("DictionarySortOrder.Recent.title")
        case .alphabetical:
            L10n("DictionarySortOrder.Alphabetical.title")
        }
    }
}
