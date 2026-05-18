//
//  AnswerStorage.swift
//  Citizen
//
//  Created by GE-Developer
//
//  Хранит две сущности:
//  • QuestionEntity (id, isCorrect) — текущее состояние ответа.
//    Перезаписывается при повторном прохождении вопроса.
//  • GlobalMistakeEntity (questionID) — sticky append-only пул вопросов,
//    в которых пользователь хоть раз ошибся. Питает раздел «Review N mistakes».
//    Очищается только явным сбросом.
//

import Foundation
import CoreData

final class AnswerStorage {

    static let shared = AnswerStorage()

    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentContainer(name: "AnswerContainer")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData error: \(error)") }
        }
    }

    // MARK: - QuestionEntity

    func saveAnswer(questionID: String, isCorrect: Bool) {
        let request: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", questionID as CVarArg)
        request.fetchLimit = 1

        do {
            if let existing = try context.fetch(request).first {
                existing.isCorrect = isCorrect
            } else {
                let answer = QuestionEntity(context: context)
                answer.id = questionID
                answer.isCorrect = isCorrect
            }
            try context.save()
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "QuestionEntity")
        request.predicate = NSPredicate(format: "id IN %@", ids)
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(delete)
            try context.save()
        } catch {
            print("❌ Failed to remove answers:", error)
        }
    }

    func reset() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "QuestionEntity")
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(delete)
            try context.save()
        } catch {
            print("❌ Failed to reset:", error)
        }
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
            try context.save()
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
}
