//
//  OccurrenceRow.swift
//  Citizen
//
//  Created by GE-Developer
//
//  Одна карточка экрана «в каких вопросах встречается это слово»: путь до вопроса
//  (категория → тема → номер), текст вопроса и предложение-пример для превью.
//  Слово ищется по вопросу, предложению и ответам (см. WordOccurrenceIndex), но в
//  карточке показываем только вопрос и предложение — как на экране вопросов.
//

import Foundation

struct OccurrenceRow: Identifiable, Hashable {
    let question: Question
    let number: String
    let categoryName: String
    let topicName: String
    let questionText: String
    let sentenceSegments: [RichTextSegment]

    var id: String { question.id }


    // Есть ли у вопроса предложение-пример (additionalText) для показа под вопросом.
    var hasSentence: Bool {
        !sentenceSegments.isEmpty
    }
}
