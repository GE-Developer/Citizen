//
//  HintAnswerRow.swift
//  Citizen
//
//  Created by GE-Developer
//

struct HintAnswerRow: Identifiable, Hashable {
    let label: String
    let text: String
    let segments: [RichTextSegment]
    let translation: String?
    let isCorrect: Bool
    
    var id: String { label }
}
