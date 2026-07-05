//
//  Array + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

// MARK: - RichTextSegment
extension Array where Element == RichTextSegment {
    @MainActor
    func mergingDictionaryPhrases() -> [RichTextSegment] {
        let maxWindow = WordsDictionary.shared.maxPhraseWordCount
        
        guard maxWindow > 1 else { return self }
        
        var result: [RichTextSegment] = []
        var i = 0
        while i < count {
            guard case .word = self[i] else {
                result.append(self[i])
                i += 1
                continue
            }
            
            var window = 1
            
            while window < maxWindow,
                  i + window < count,
                  case .word = self[i + window] {
                window += 1
            }
            
            var merged = false
            var n = window
            
            while n >= 2 {
                let candidate = (0..<n)
                    .map { plainText(of: self[i + $0]) }
                    .joined(separator: " ")
                if WordsDictionary.shared.contains(candidate) {
                    var phrase = AttributedString()
                    for k in 0..<n {
                        if case .word(let attr) = self[i + k] { phrase.append(attr) }
                    }
                    result.append(.word(phrase))
                    i += n
                    merged = true
                    break
                }
                n -= 1
            }
            
            if !merged {
                result.append(self[i])
                i += 1
            }
        }
        return result
    }
    
    private func plainText(of segment: RichTextSegment) -> String {
        guard case .word(let attr) = segment else { return "" }
        return attr.plainToken
    }
}
