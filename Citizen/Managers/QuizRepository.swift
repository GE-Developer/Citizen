//
//  QuizRepository.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class QuizRepository {
    private(set) var catalog: QuestionCatalog = QuestionCatalog(categories: [])
    
    private var translations: [String: Question] = [:]
    private var questionIndex: [String: (Int, Int, Int)] = [:]
    
    static let shared = QuizRepository()
    
    private let storage = AnswerStorage.shared
    
    private init() {}
    
    // MARK: - Public API
    func load() async throws {
        let langCode = LanguageManager.shared.currentLanguageID
        let (merged, loadedTranslations) = try await Task.detached(
            priority: .userInitiated
        ) { () throws -> (QuestionCatalog, [String: Question]?) in
            guard let base = Self.decode(langCode: "ka") else {
                throw ResourceError.loadFailed("questions.ka")
            }
            
            try Self.validate(base)
            
            guard langCode != "ka", let overlay = Self.decode(langCode: langCode) else {
                return (base, nil)
            }
            
            let translations = Dictionary(
                overlay.categories.flatMap(\.topics).flatMap(\.questions).map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
            
            return (Self.applyNameOverlay(base: base, overlay: overlay), translations)
        }.value
        
        catalog = hydrate(merged)
        translations = loadedTranslations ?? [:]
    }
    
    func translation(forID id: String) -> Question? {
        translations[id]
    }
    
    func recordAnswer(questionID: String, isCorrect: Bool) {
        storage.saveAnswer(questionID: questionID, isCorrect: isCorrect)
        
        if !isCorrect {
            storage.addToGlobalPool(questionID: questionID)
        }
        
        applyAnswerState(forQuestionID: questionID, isCorrect: isCorrect)
    }
    
    func restartTopic(_ topicID: String) {
        guard let (ci, ti) = locate(topicID: topicID) else { return }
        
        let ids = catalog.categories[ci].topics[ti].questions.map(\.id)
        storage.removeAnswers(ids: ids)
        
        for qi in catalog.categories[ci].topics[ti].questions.indices {
            catalog.categories[ci].topics[ti].questions[qi].status = .unanswered
        }
    }
    
    func topic(byID id: String) -> Topic? {
        catalog.categories.lazy.flatMap(\.topics).first { $0.id == id }
    }
    
    func placement(ofQuestionID id: String) -> (category: Category, topic: Topic)? {
        guard let (ci, ti, _) = locate(questionID: id) else { return nil }
        
        return (catalog.categories[ci], catalog.categories[ci].topics[ti])
    }
    
    func recordPracticeAnswer(questionID: String, isCorrect: Bool) {
        if isCorrect {
            storage.addToGlobalCorrectPool(questionID: questionID)
        } else {
            storage.addToGlobalPool(questionID: questionID)
            if let (ci, ti, qi) = locate(questionID: questionID) {
                catalog.categories[ci].topics[ti].questions[qi].isInMistakePool = true
            }
        }
    }
    
    func resolveMistake(questionID: String) {
        storage.removeFromGlobalPool(questionID: questionID)
        
        if let (ci, ti, qi) = locate(questionID: questionID) {
            catalog.categories[ci].topics[ti].questions[qi].isInMistakePool = false
        }
    }
    
    func occurrenceRow(for question: Question) -> OccurrenceRow {
        let placement = placement(ofQuestionID: question.id)
        let sentence = question.additionalText ?? ""
        return OccurrenceRow(
            question: question,
            categoryName: placement?.category.name ?? "",
            topicName: placement?.topic.name ?? "",
            sentenceSegments: sentence.isEmpty ? [] : sentence.asRichSegments,
            isPremium: placement?.topic.isPremium ?? false
        )
    }
    
    // MARK: - Private helpers
    private nonisolated static func applyNameOverlay(base: QuestionCatalog, overlay: QuestionCatalog) -> QuestionCatalog {
        let overlayMap = Dictionary(
            overlay.categories.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        
        let merged = base.categories.map { baseCategory -> Category in
            guard let overlayCategory = overlayMap[baseCategory.id] else {
                return baseCategory
            }
            
            let topicOverlayMap = Dictionary(
                overlayCategory.topics.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
            
            let mergedTopics = baseCategory.topics.map { baseTopic -> Topic in
                guard let overlayTopic = topicOverlayMap[baseTopic.id] else {
                    return baseTopic
                }
                
                return Topic(
                    id: baseTopic.id,
                    index: baseTopic.index,
                    name: overlayTopic.name,
                    description: baseTopic.description,
                    isPremium: baseTopic.isPremium,
                    imageUrl: baseTopic.imageUrl,
                    questions: baseTopic.questions
                )
            }
            
            return Category(
                id: baseCategory.id,
                index: baseCategory.index,
                name: overlayCategory.name,
                description: baseCategory.description,
                imageUrl: baseCategory.imageUrl,
                topics: mergedTopics
            )
        }
        
        return QuestionCatalog(categories: merged)
    }
    
    private nonisolated static func validate(_ catalog: QuestionCatalog) throws {
        var questionIDs = Set<String>()
        
        for topic in catalog.categories.flatMap(\.topics) {
            guard !topic.questions.isEmpty else {
                throw ResourceError.invalidData("empty topic \(topic.id)")
            }
            
            for question in topic.questions {
                guard questionIDs.insert(question.id).inserted else {
                    throw ResourceError.invalidData("duplicate question id \(question.id)")
                }
                guard question.answers.count(where: \.isCorrect) == 1 else {
                    throw ResourceError.invalidData("question \(question.id) must have exactly one correct answer")
                }
                guard Set(question.answers.map(\.text)).count == question.answers.count,
                      Set(question.answers.map(\.label)).count == question.answers.count else {
                    throw ResourceError.invalidData("duplicate answer text/label in question \(question.id)")
                }
            }
        }
    }
    
    private nonisolated static func decode(langCode: String) -> QuestionCatalog? {
        let name = "questions.\(langCode)"
        
        guard let data = ResourceProvider.shared.data(forName: name) else { return nil }
        
        do {
            return try JSONDecoder().decode(QuestionCatalog.self, from: data)
        } catch {
            print("[QuizRepository] decode error for \(name).json: \(error)")
            return nil
        }
    }
    
    private func hydrate(_ catalog: QuestionCatalog) -> QuestionCatalog {
        let answered = storage.fetchAllAnswered()
        let pool = Set(storage.fetchGlobalWrongIDs())
        
        var hydrated = catalog
        var index: [String: (Int, Int, Int)] = [:]
        
        for ci in hydrated.categories.indices {
            for ti in hydrated.categories[ci].topics.indices {
                for qi in hydrated.categories[ci].topics[ti].questions.indices {
                    let qid = hydrated.categories[ci].topics[ti].questions[qi].id
                    hydrated.categories[ci].topics[ti].questions[qi].status =
                    answered[qid].map { $0 ? .correct : .wrong } ?? .unanswered
                    hydrated.categories[ci].topics[ti].questions[qi].isInMistakePool = pool.contains(qid)
                    index[qid] = (ci, ti, qi)
                }
            }
        }
        
        questionIndex = index
        return hydrated
    }
    
    private func applyAnswerState(forQuestionID id: String, isCorrect: Bool) {
        guard let (ci, ti, qi) = locate(questionID: id) else { return }
        
        catalog.categories[ci].topics[ti].questions[qi].status = isCorrect ? .correct : .wrong
        
        if !isCorrect {
            catalog.categories[ci].topics[ti].questions[qi].isInMistakePool = true
        }
    }
    
    private func locate(topicID: String) -> (Int, Int)? {
        for ci in catalog.categories.indices {
            for ti in catalog.categories[ci].topics.indices {
                if catalog.categories[ci].topics[ti].id == topicID {
                    return (ci, ti)
                }
            }
        }
        return nil
    }
    
    private func locate(questionID: String) -> (Int, Int, Int)? {
        questionIndex[questionID]
    }
}
