//
//  WordsDictionary.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class WordsDictionary {
    var keysSnapshot: Set<String> {
        Set(entries.keys)
    }
    
    private(set) var maxPhraseWordCount: Int = 1
    
    private(set) var partsOfSpeech: [String] = []
    
    private var entries: [String: WordEntry] = [:]
    
    static let shared = WordsDictionary()
    
    private init() {}
    
    func load() async throws {
        let lang = LanguageManager.shared.currentLanguageID
        let loaded = try await Task.detached(priority: .userInitiated) {
            try Self.load(lang: lang)
        }.value
        
        apply(loaded)
    }
    
    func contains(_ token: String) -> Bool {
        entries[Self.normalize(token)] != nil
    }
    
    func entry(for token: String) -> WordEntry? {
        entries[Self.normalize(token)]
    }
    
    nonisolated static func normalize(_ token: String) -> String {
        token.trimmingCharacters(in: CharacterSet.letters.inverted)
    }
    
    private nonisolated static func load(lang: String) throws -> [String: WordEntry] {
        if let dict = decode(lang: lang) {
            return dict
        }
        
        if lang != Language.english.id, let dict = decode(lang: Language.english.id) {
            return dict
        }
        
        throw ResourceError.loadFailed("words.\(lang)")
    }
    
    private nonisolated static func decode(lang: String) -> [String: WordEntry]? {
        guard
            let data = ResourceProvider.shared.data(forName: "words.\(lang)"),
            let dict = try? JSONDecoder().decode([String: WordEntry].self, from: data)
        else { return nil }
        
        return dict.reduce(into: [:]) { result, item in
            var entry = item.value
            entry.key = item.key
            result[item.key] = entry
        }
    }
    
    private func apply(_ loaded: [String: WordEntry]) {
        entries = loaded
        maxPhraseWordCount = loaded.keys.map { $0.split(separator: " ").count }.max() ?? 1
        
        var counts: [String: Int] = [:]
        
        for entry in loaded.values {
            counts[entry.partOfSpeech, default: 0] += 1
        }
        
        partsOfSpeech = counts.sorted { $0.value > $1.value }.map(\.key)
    }
}
