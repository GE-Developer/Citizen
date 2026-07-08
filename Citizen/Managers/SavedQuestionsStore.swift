//
//  SavedQuestionsStore.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class SavedQuestionsStore {
    private var context: NSManagedObjectContext {
        stack.context
    }
    
    static let shared = SavedQuestionsStore()
    
    private let stack = CoreDataStack.shared
    
    private init() {}
    
    func folders() -> [QuestionFolder] {
        let request: NSFetchRequest<QuestionFolderEntity> = QuestionFolderEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        do {
            return try context.fetch(request).compactMap { entity in
                guard let id = entity.id, let name = entity.name else { return nil }
                return QuestionFolder(id: id, name: name, count: count(inFolder: id))
            }
        } catch {
            print("❌ Failed to fetch question folders:", error)
            return []
        }
    }
    
    @discardableResult
    func createFolder(named name: String) -> QuestionFolder {
        let entity = QuestionFolderEntity(context: context)
        let id = UUID().uuidString
        entity.id = id
        entity.name = name
        entity.createdAt = Date()
        stack.saveContext()
        return QuestionFolder(id: id, name: name, count: 0)
    }
    
    func folderIDs(for questionID: String) -> Set<String> {
        let request: NSFetchRequest<SavedQuestionEntity> = SavedQuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %@", questionID)
        let items = (try? context.fetch(request)) ?? []
        return Set(items.compactMap { $0.folderID })
    }
    
    func contains(_ questionID: String) -> Bool {
        let request: NSFetchRequest<SavedQuestionEntity> = SavedQuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %@", questionID)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
    
    func savedQuestionsCount() -> Int {
        let request: NSFetchRequest<SavedQuestionEntity> = SavedQuestionEntity.fetchRequest()
        let items = (try? context.fetch(request)) ?? []
        return Set(items.compactMap { $0.questionID }).count
    }
    
    @discardableResult
    func toggle(questionID: String, folderID: String) -> Bool {
        if isSaved(questionID: questionID, inFolder: folderID) {
            stack.batchDelete(
                entityName: "SavedQuestionEntity",
                predicate: NSPredicate(format: "questionID == %@ AND folderID == %@", questionID, folderID)
            )
            return false
        }
        let entity = SavedQuestionEntity(context: context)
        entity.questionID = questionID
        entity.folderID = folderID
        entity.createdAt = Date()
        stack.saveContext()
        return true
    }
    
    func removeAll() {
        stack.batchDelete(entityName: "SavedQuestionEntity")
        stack.batchDelete(entityName: "QuestionFolderEntity")
    }
    
    private func isSaved(questionID: String, inFolder folderID: String) -> Bool {
        let request: NSFetchRequest<SavedQuestionEntity> = SavedQuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %@ AND folderID == %@", questionID, folderID)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
    
    private func count(inFolder folderID: String) -> Int {
        let request: NSFetchRequest<SavedQuestionEntity> = SavedQuestionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "folderID == %@", folderID)
        return (try? context.count(for: request)) ?? 0
    }
}
