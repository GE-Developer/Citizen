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
        rows.filtered(by: selectedFilter)
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
        let occurrenceIDs = Set(
            word.keys.flatMap { WordOccurrenceIndex.shared.questions(for: $0).map(\.id) }
        )
        let questions = QuizRepository.shared.catalog.categories
            .flatMap(\.topics)
            .flatMap(\.questions)
            .filter { occurrenceIDs.contains($0.id) }
        let rows = questions.map { QuizRepository.shared.occurrenceRow(for: $0) }
        
        headerTitle = word.entry.word
        headerTransliteration = "[\(word.entry.transliteration)]"
        headerTranslation = word.entry.translation
        subtitle = L10n("\(questions.count) WordOccurrences.subtitle")
        self.rows = rows
        availableFilters = rows.categoryFilters
    }
    
    func select(_ row: OccurrenceRow) {
        hapticsManager.impact()
        selectedQuestion = row.question
    }
}
