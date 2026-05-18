//
//  QuestionCategoriesViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

final class QuestionCategoriesViewModel: ObservableObject {
    @Published var chosenTopic: Topic?

    let categoryID: String
    let categoryTitle: String
    let subtitle = "Тесты"

    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared

    var topics: [Topic] {
        repository.catalog.categories.first { $0.id == categoryID }?.topics ?? []
    }

    init(category: Category) {
        self.categoryID = category.id
        self.categoryTitle = category.name
    }

    func statsDescription(for topic: Topic) -> String {
        switch topic.phase {
        case .notStarted:
            "\(topic.totalCount) вопросов"
        case .inProgress, .completed:
            "\(topic.correctCount) из \(topic.totalCount)"
        case .workingOnMistakes:
            "Ошибок: \(topic.wrongCount)"
        }
    }

    func choose(_ topic: Topic) {
        haptics.impact()
        chosenTopic = topic
    }
}
