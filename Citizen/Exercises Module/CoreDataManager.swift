//
//  CoreDataManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import CoreData

final class AnswerStorage {

    static let shared = AnswerStorage()

    // MARK: - Core Data Stack
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentContainer(name: "AnswerContainer")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData error: \(error)") }
        }
    }

    // MARK: - Save Answer
    func saveAnswer(questionID: String, isCorrect: Bool) {
        let request: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", questionID as CVarArg)
        request.fetchLimit = 1

        do {
            if let existing = try context.fetch(request).first {
                // Обновляем существующий ответ
                existing.isCorrect = isCorrect
            } else {
                // Создаём новый
                let answer = QuestionEntity(context: context)
                answer.id = questionID
                answer.isCorrect = isCorrect
            }
            try context.save()
        } catch {
            print("❌ Failed to save answer:", error)
        }
    }

    // MARK: - Fetch Correct IDs
    func fetchCorrectIDs() -> [String] {
        let request = QuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isCorrect == YES")
        do {
            let items = try context.fetch(request)
            return items.map { $0.id ?? "" }
        } catch {
            print("❌ Failed to fetch correct IDs:", error)
            return []
        }
    }

    // MARK: - Fetch Wrong IDs
    func fetchWrongIDs() -> [String] {
        let request = QuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isCorrect == NO")
        do {
            let items = try context.fetch(request)
            return items.map { $0.id ?? "" }
        } catch {
            print("❌ Failed to fetch wrong IDs:", error)
            return []
        }
    }

    // MARK: - Reset (для тестов)
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
}
