//
//  WordOccurrencesViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class WordOccurrencesViewModel {
    var selectedQuestion: Question?
    var selectedFilter: Filter = .all
    
    var visibleRows: [OccurrenceRow] {
        switch selectedFilter {
        case .all:
            rows
        case .named(let category):
            rows.filter { $0.categoryName == category }
        }
    }
    
    let title = L10n("WordOccurrences.title")
    let emptyText = L10n("WordOccurrences.emptyRows")
    
    let subtitle: String
    let headerTitle: String
    let headerTransliteration: String
    let headerTranslation: String?
    let availableFilters: [Filter]
    let rows: [OccurrenceRow]
    
    private let hapticsManager = HapticsManager.shared
    
    init(word: SavedWord) {
        var seen = Set<String>()
        let questions = word.keys
            .flatMap { WordOccurrenceIndex.shared.questions(for: $0) }
            .filter { seen.insert($0.id).inserted }
        let rows = questions.map { Self.makeRow(for: $0) }
        
        headerTitle = word.entry.word
        headerTransliteration = "[\(word.entry.transliteration)]"
        headerTranslation = word.entry.translation
        subtitle = L10n("\(questions.count) WordOccurrences.subtitle")
        self.rows = rows
        availableFilters = Self.filters(for: rows)
    }
    
    func select(_ row: OccurrenceRow) {
        hapticsManager.impact()
        selectedQuestion = row.question
    }
    
    private static func filters(for rows: [OccurrenceRow]) -> [Filter] {
        var seen = Set<String>()
        var categories: [String] = []
        
        for row in rows {
            let category = row.categoryName
            
            guard !category.isEmpty else { continue }
            guard seen.insert(category).inserted else { continue }
            
            categories.append(category)
        }
        
        return [.all] + categories.map(Filter.named)
    }
    
    private static func makeRow(for question: Question) -> OccurrenceRow {
        let placement = QuizRepository.shared.placement(ofQuestionID: question.id)
        let sentence = question.additionalText ?? ""
        return OccurrenceRow(
            question: question,
            categoryName: placement?.category.name ?? "",
            topicName: placement?.topic.name ?? "",
            sentenceSegments: sentence.isEmpty ? [] : sentence.asRichSegments,
            isPremium: placement?.topic.isPremium ?? false
        )
    }
}
