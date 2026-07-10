//
//  MainViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class MainViewModel: ObservableObject {
    @Published var chosenCategory: Category?
    @Published var showSaved = false
    
    var catalog: QuestionCatalog { repository.catalog }
    
    var allTopicScore: String {
        "\(catalog.completedTopics)/\(catalog.totalTopics)"
    }
    var allQuestionScore: String {
        "\(catalog.correctCount)/\(catalog.totalQuestions)"
    }
    var allMistakeScore: String {
        "\(catalog.mistakePoolCount)"
    }
    
    var examReadinessTitle: String {
        L10n("Main.ExamReadiness.title")
    }
    
    var topicsTitle: String {
        L10n("Main.Topics.title")
    }
    
    var questionsTitle: String {
        L10n("Main.Questions.title")
    }
    
    var toReviewTitle: String {
        L10n("Main.ToReview.title")
    }
    
    var searchTitle: String {
        L10n("Main.Search.title")
    }
    
    var leaderboardTitle: String {
        L10n("Main.Leaderboard.title")
    }
    
    var examTitle: String {
        L10n("Main.Exam.title")
    }
    
    var examSubtitle: String {
        L10n("Main.Exam.subtitle")
    }
    
    var examPreview: String {
        L10n("\(60) Main.Exam.preview")
    }
    
    var refreshTitle: String {
        L10n("Main.Refresh.title")
    }
    
    var refreshSubtitle: String {
        L10n("Main.Refresh.subtitle")
    }
    
    var refreshPreview: String {
        "\(0)"
    }
    
    var mistakesTitle: String {
        L10n("Main.Mistakes.title")
    }
    
    var mistakesSubtitle: String {
        L10n("Main.Mistakes.subtitle")
    }
    
    var savedTitle: String {
        L10n("Main.Saved.title")
    }
    
    var savedSubtitle: String {
        L10n("Main.Saved.subtitle")
    }
    
    var savedPreview: String {
        "\(savedQuestions.foldersCount())"
    }
    
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    private let savedQuestions = SavedQuestionsStore.shared
    
    func choose(_ category: Category) {
        haptics.impact()
        chosenCategory = category
    }
    
    func numberFor(_ category: Category) -> String {
        String(format: "%02d", category.index)
    }
    
    func titleFor(_ category: Category) -> String {
        category.name
    }
    
    func percentProgressFor(_ category: Category) -> String {
        "\(Int(category.progress * 100))%"
    }
    
    func topicScoreFor(_ category: Category) -> String {
        "\(category.completedTopics)/\(category.totalTopics)"
    }
    
    func examButtonPressed() {
        haptics.impact()
    }
    
    func refreshButtonPressed() {
        haptics.impact()
    }
    
    func mistakesButtonPressed() {
        haptics.impact()
    }
    
    func savedButtonPressed() {
        haptics.impact()
        showSaved = true
    }
    
    func searchButtonPressed() {
        haptics.impact()
    }
    
    func leaderboardButtonPressed() {
        haptics.impact()
    }
}
