//
//  WordEntry.swift
//  Citizen
//
//  Created by GE-Developer
//

// MARK: - WordEntry
struct WordEntry: Decodable, Hashable, Identifiable {
    let partOfSpeech: String
    let form: WordForm?
    let lemma: WordForm
    
    var key: String = ""
    var isSaved: Bool = false
    
    var id: String {
        key
    }
    
    var word: String {
        form?.word ?? lemma.word
    }
    
    var transliteration: String {
        form?.transliteration ?? lemma.transliteration
    }
    
    var translation: String? {
        form?.translation ?? lemma.translation
    }
    
    var searchableText: String {
        [key, lemma.word, lemma.transliteration, lemma.translation,
         form?.word, form?.transliteration, form?.translation]
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    enum CodingKeys: String, CodingKey {
        case partOfSpeech, form, lemma
    }
}

// MARK: - WordForm
struct WordForm: Decodable, Hashable {
    let word: String
    let transliteration: String
    let formDescription: String
    let translation: String?
}
