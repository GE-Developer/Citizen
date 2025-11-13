//
//  Question.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct Question: Identifiable, Hashable, Equatable {
    let id: String
    let number: Int
    let theme: QuestionTheme
    let category: QuestionCategory
    
    let topic: Topic
    let text: String?
    let options: [Option]
    
    init(
        _ number: Int,
        _ theme: QuestionTheme,
        _ category: QuestionCategory,
        _ topic: Topic,
        text: String?,
        options: [Option]
    ) {
        self.id = "\(category.rawValue) - question \(number)"
        self.number = number
        self.theme = theme
        self.category = category
        self.topic = topic
        self.text = text
        self.options = options
    }
}

struct Option: Identifiable, Hashable, Equatable {
    let id: String
    let isCorrect: Bool
    
    init(id: String, _ isCorrect: Bool) {
        self.id = id
        self.isCorrect = isCorrect
    }
}

enum QuestionCategory: String, CaseIterable {
    case grammar
    case law
    case history
    
    var name: String {
        switch self {
        case .grammar: "Grammar"
        case .law: "Law"
        case .history: "History"
        }
    }
}

enum QuestionTheme: CaseIterable {
    case some
    
    var name: String {
        switch self {
        case .some: return "Some Theme"
        }
    }
}

enum Topic {
    case correct
    case uncorrect
    
    var description: String {
        switch self {
        case .correct:
            return "შემოხაზეთ სწორი პასუხი"
        case .uncorrect:
            return "შემოხაზეთ არასწორი პასუხი"
        }
    }
}


extension Question {
    static func getData() -> [Question] {
        [
            // MARK: - Georgian Language
            Question(
                100, .some, .grammar, .correct, text: "Question.100.title", options: [
                    Option(id: "Question.100.v1", false),
                    Option(id: "Question.100.v2", false),
                    Option(id: "Question.100.v3", true),
                    Option(id: "Question.100.v4", false)
                ]
            ),
            Question(
                1, .some, .grammar, .correct, text: nil, options: [
                    Option(id: "Question.1.v1", false),
                    Option(id: "Question.1.v2", false),
                    Option(id: "Question.1.v3", true),
                    Option(id: "Question.1.v4", false)
                ]
            ),
            Question(
                2, .some, .grammar, .correct, text: nil, options: [
                    Option(id: "Question.2.v1", true),
                    Option(id: "Question.2.v2", false),
                    Option(id: "Question.2.v3", false),
                    Option(id: "Question.2.v4", false)
                ]
            ),
            Question(
                3, .some, .grammar, .correct, text: nil, options: [
                    Option(id: "Question.3.v1", false),
                    Option(id: "Question.3.v2", true),
                    Option(id: "Question.3.v3", false),
                    Option(id: "Question.3.v4", false)
                ]
            ),
            Question(
                4, .some, .grammar, .correct, text: nil, options: [
                    Option(id: "Question.4.v1", false),
                    Option(id: "Question.4.v2", false),
                    Option(id: "Question.4.v3", true),
                    Option(id: "Question.4.v4", false)
                ]
            )
        ]
    }
}
