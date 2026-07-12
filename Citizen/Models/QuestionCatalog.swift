//
//  QuestionCatalog.swift
//  Citizen
//
//  Created by GE-Developer
//

// MARK: - QuestionCatalog
struct QuestionCatalog: Decodable, Hashable {
    var categories: [Category]
    
    var totalTopics: Int {
        categories
            .reduce(0) { $0 + $1.totalTopics }
    }
    
    var completedTopics: Int {
        categories
            .reduce(0) { $0 + $1.completedTopics }
    }
    
    var totalQuestions: Int {
        categories
            .reduce(0) { $0 + $1.totalQuestions }
    }
    
    var correctCount: Int {
        categories
            .reduce(0) { $0 + $1.correctCount }
    }
    
    var wrongCount: Int {
        categories
            .reduce(0) { $0 + $1.wrongCount }
    }
    
    var progress: Double {
        Double(correctCount) / Double(max(totalQuestions, 1))
    }
    
    var mistakePoolQuestions: [Question] {
        categories
            .flatMap(\.topics)
            .flatMap(\.questions)
            .filter(\.isInMistakePool)
    }
    
    var mistakePoolCount: Int {
        mistakePoolQuestions.count
    }
    
    var correctPoolQuestions: [Question] {
        categories
            .flatMap(\.topics)
            .flatMap(\.questions)
            .filter { $0.status == .correct && !$0.isInMistakePool }
    }
    
    var correctPoolCount: Int {
        correctPoolQuestions.count
    }
}

// MARK: - Category
struct Category: Decodable, Hashable, Identifiable {
    let id: String
    let index: Int
    let name: String
    let description: String?
    let imageUrl: String?
    
    var topics: [Topic]
    
    var totalTopics: Int {
        topics.count
    }
    
    var totalQuestions: Int {
        topics
            .reduce(0) { $0 + $1.totalCount }
    }
    
    var correctCount: Int {
        topics
            .reduce(0) { $0 + $1.correctCount }
    }
    
    var wrongCount: Int {
        topics
            .reduce(0) { $0 + $1.wrongCount }
    }
    
    var completedTopics: Int {
        topics
            .lazy
            .filter { $0.phase == .completed }
            .count
    }
    
    var progress: Double {
        Double(correctCount) / Double(max(totalQuestions, 1))
    }
}

// MARK: - Topic
struct Topic: Decodable, Hashable, Identifiable {
    let id: String
    let index: Int
    let name: String
    let description: String?
    let isPremium: Bool
    let imageUrl: String?
    
    var questions: [Question]
    
    var totalCount: Int {
        questions.count
    }
    
    var correctCount: Int {
        questions
            .lazy
            .filter { $0.status == .correct }
            .count
    }
    
    var wrongCount: Int {
        questions
            .lazy
            .filter { $0.status == .wrong }
            .count
    }
    
    var answeredCount: Int {
        correctCount + wrongCount
    }
    
    var progress: Double {
        Double(correctCount) / Double(max(totalCount, 1))
    }
    
    var phase: TopicPhase {
        guard totalCount > 0, answeredCount > 0 else { return .notStarted }
        if answeredCount < totalCount { return .inProgress }
        
        return wrongCount == 0 ? .completed : .workingOnMistakes
    }
}

// MARK: - Question
struct Question: Decodable, Hashable, Identifiable {
    let id: String
    let number: String
    let index: Int
    let question: String
    let audioUrl: String?
    let additionalText: String?
    let additionalAudioUrl: String?
    let explanations: [String]
    let imageUrl: String?
    let answers: [Answer]
    
    var status: AnswerStatus = .unanswered
    var isInMistakePool: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, number, index, question, audioUrl
        case additionalText, additionalAudioUrl, explanations, imageUrl, answers
    }
}

// MARK: - Answer
struct Answer: Decodable, Hashable, Identifiable {
    let label: String
    let text: String
    let audioUrl: String?
    let imageUrl: String?
    let isCorrect: Bool
    
    var id: String {
        text
    }
}
