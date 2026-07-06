//
//  ResourceManifest.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum ResourceManifest {
    static func files(for language: String) -> [String] {
        var names = ["questions.ka", "words.en", "alphabet"]
        
        if language != Language.georgian.id {
            names.append("questions.\(language)")
        }
        
        if language != Language.english.id {
            names.append("words.\(language)")
        }
        
        return names
    }
}
