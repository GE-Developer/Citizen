//
//  AnswerStorage.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class AnswerStorage {
    
    static let shared = AnswerStorage()
    
    private let stack = CoreDataStack.shared
    
    private var context: NSManagedObjectContext {
        stack.context
    }
    
    private init() {}
    
    // MARK: - QuestionEntity
    func saveAnswer(questionID: String, isCorrect: Bool) {
        let request: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", questionID)
        request.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(request).first {
                existing.isCorrect = isCorrect
            } else {
                let answer = QuestionEntity(context: context)
                answer.id = questionID
                answer.isCorrect = isCorrect
            }
            stack.saveContext()
        } catch {
            print("❌ Failed to save answer:", error)
        }
    }
    
    func fetchAllAnswered() -> [String: Bool] {
        let request = QuestionEntity.fetchRequest()
        do {
            return try context.fetch(request).reduce(into: [:]) { dict, entity in
                guard let id = entity.id else { return }
                dict[id] = entity.isCorrect
            }
        } catch {
            print("❌ Failed to fetch all answered:", error)
            return [:]
        }
    }
    
    func removeAnswers(ids: [String]) {
        guard !ids.isEmpty else { return }
        stack.batchDelete(
            entityName: "QuestionEntity",
            predicate: NSPredicate(format: "id IN %@", ids)
        )
    }
    
    // MARK: - GlobalMistakeEntity
    func addToGlobalPool(questionID: String) {
        let request: NSFetchRequest<GlobalMistakeEntity> = GlobalMistakeEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "questionID == %@", questionID)
        request.fetchLimit = 1
        do {
            guard try context.fetch(request).isEmpty else { return }
            let entity = GlobalMistakeEntity(context: context)
            entity.questionID = questionID
            stack.saveContext()
        } catch {
            print("❌ Failed to add to global pool:", error)
        }
    }
    
    func fetchGlobalWrongIDs() -> [String] {
        let request = GlobalMistakeEntity.fetchRequest()
        do {
            return try context.fetch(request).compactMap { $0.questionID }
        } catch {
            print("❌ Failed to fetch global wrong IDs:", error)
            return []
        }
    }
    
    // MARK: - GlobalCorrectEntity
    func addToGlobalCorrectPool(questionID: String) {
        let request: NSFetchRequest<GlobalCorrectEntity> = GlobalCorrectEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "questionID == %@", questionID)
        request.fetchLimit = 1
        do {
            guard try context.fetch(request).isEmpty else { return }
            let entity = GlobalCorrectEntity(context: context)
            entity.questionID = questionID
            stack.saveContext()
        } catch {
            print("❌ Failed to add to global correct pool:", error)
        }
    }
    
    func fetchGlobalCorrectIDs() -> [String] {
        let request = GlobalCorrectEntity.fetchRequest()
        do {
            return try context.fetch(request).compactMap { $0.questionID }
        } catch {
            print("❌ Failed to fetch global correct IDs:", error)
            return []
        }
    }
}
