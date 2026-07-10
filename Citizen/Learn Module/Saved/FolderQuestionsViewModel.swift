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
    @Published var showPractice = false
    
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
    
    var practiceFilterDetail: String {
        selectedFilter.title
    }
    
    var practiceHeaderTitle: String {
        selectedFilter == .all ? title : "\(title) — \(selectedFilter.title)"
    }
    
    private(set) var practiceQuestions: [Question] = []
    
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
    
    func canPractice(isPremium: Bool) -> Bool {
        visibleRows.contains { isPremium || !$0.isPremium }
    }
    
    func practicePressed(isPremium: Bool) {
        haptics.impact()
        
        let pool = visibleRows
            .filter { isPremium || !$0.isPremium }
            .map(\.question)
        
        guard !pool.isEmpty else { return }
        
        practiceQuestions = pool
        showPractice = true
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
