//
//  LearnViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

final class MainViewModel: ObservableObject {
    @Published var chosenCategory: Category?
    
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
    
    var allCorrectScore: String {
        "\(catalog)"
    }
    
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    
    let examReadinessTitle = "Exam Readiness"
    let topicsTitle = "Topics"
    let questionsTitle = "Questions"
    let toReviewTitle = "To Review"
    
    let examTitle = "Exam"
    let examSubtitle = "Simulate the real exam"
    let examPreview = "20 min"
    
    let refreshTitle = "Refresh"
    let refreshSubtitle = "Run through completed questions"
    let refreshPreview = "52"
    
    let mistakesTitle = "Mistakes"
    let mistakesSubtitle = "Redo questions you got wrong"
    
    let savedTitle = "Saved"
    let savedSubtitle = "Questions you bookmarked"
    let savedPreview = "15"
    
    func choose(_ category: Category) {
        haptics.impact()
        chosenCategory = category
    }
    
    func numberFor(_ category: Category) -> String {
        "0\(category.index)"
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
    }
}
