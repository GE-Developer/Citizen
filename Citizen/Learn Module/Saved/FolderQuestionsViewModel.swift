//
//  FolderQuestionsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class FolderQuestionsViewModel: ObservableObject {
    @Published var selectedQuestion: Question?
    @Published var selectedFilter: Filter = .all

    @Published private(set) var rows: [OccurrenceRow] = []

    var visibleRows: [OccurrenceRow] {
        rows.filtered(by: selectedFilter)
    }

    var availableFilters: [Filter] {
        rows.categoryFilters
    }

    var questionsCountText: String {
        "\(rows.count)"
    }

    var questionsCountSuffix: String {
        L10n("\(rows.count) Saved.questionCountSuffix")
    }

    let title: String
    let removeActionTitle = L10n("Saved.removeQuestion")
    let practiceTitle = L10n("Saved.Practice.title")
    let practiceSubtitle = L10n("Saved.Practice.folderSubtitle")

    private let folderID: String
    private let savedStore = SavedQuestionsStore.shared
    private let haptics = HapticsManager.shared

    init(folder: QuestionFolder) {
        let savedIDs = SavedQuestionsStore.shared.questionIDs(inFolder: folder.id)
        let questions = QuizRepository.shared.catalog.categories
            .flatMap(\.topics)
            .flatMap(\.questions)
            .filter { savedIDs.contains($0.id) }

        title = folder.name
        folderID = folder.id
        rows = questions.map { QuizRepository.shared.occurrenceRow(for: $0) }
    }

    func select(_ row: OccurrenceRow) {
        haptics.impact()
        selectedQuestion = row.question
    }

    func practicePressed() {
        haptics.impact()
    }

    func remove(_ row: OccurrenceRow) {
        haptics.impact(style: .rigid)
        savedStore.remove(questionID: row.question.id, folderID: folderID)
        rows.removeAll { $0.id == row.id }
        if !availableFilters.contains(selectedFilter) {
            selectedFilter = .all
        }
    }
}
