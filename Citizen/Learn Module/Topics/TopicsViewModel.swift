//
//  TopicsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class TopicsViewModel: ObservableObject {
    @Published var chosenTopic: Topic?
    
    private let categoryID: String
    
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    
    var topics: [Topic] {
        category?.topics ?? []
    }

    private var category: Category? {
        repository.catalog.categories.first { $0.id == categoryID }
    }
    
    let title = "Topics"
    let subtitle: String
    
    init(category: Category) {
        self.categoryID = category.id
        self.subtitle = category.name
    }
    
    func numberFor(_ topic: Topic) -> String {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return "" }
        return String(format: "%02d", index + 1)
    }
    
    func pillText(for topic: Topic) -> String? {
        topic.phase.pillText(
            answered: topic.answeredCount,
            total: topic.totalCount,
            wrong: topic.wrongCount
        )
    }
    
    func choose(_ topic: Topic) {
        haptics.impact()
        chosenTopic = topic
    }
}
