//
//  DictionaryFilter.swift
//  Citizen
//
//  Created by GE-Developer
//

enum DictionaryFilter: Hashable {
    case all
    case partOfSpeech(String)
    
    @MainActor
    var title: String {
        switch self {
        case .all:
            L10n("DictionaryFilter.All.title")
        case .partOfSpeech(let name):
            name
        }
    }
}
