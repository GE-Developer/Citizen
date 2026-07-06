//
//  SavedWordsStore.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class SavedWordsStore {
    private var context: NSManagedObjectContext {
        stack.context
    }
    
    static let shared = SavedWordsStore()
    
    private let stack = CoreDataStack.shared
    
    private init() {}
    
    func contains(_ word: String) -> Bool {
        let request: NSFetchRequest<SavedWordEntity> = SavedWordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "word == %@", word)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
    
    @discardableResult
    func toggle(_ word: String) -> Bool {
        if contains(word) {
            remove(word)
            return false
        }
        insert(word)
        
        return true
    }
    
    func save(_ word: String) {
        guard !contains(word) else { return }
        insert(word)
    }
    
    func remove(_ word: String) {
        stack.batchDelete(
            entityName: "SavedWordEntity",
            predicate: NSPredicate(format: "word == %@", word)
        )
    }
    
    func saveAll(_ words: [String]) {
        let existing = Set(fetchAll())
        let now = Date()
        for word in words where !existing.contains(word) {
            let entity = SavedWordEntity(context: context)
            entity.word = word
            entity.createdAt = now
        }
        stack.saveContext()
    }
    
    func removeAll() {
        stack.batchDelete(entityName: "SavedWordEntity")
    }
    
    func fetchAll() -> [String] {
        let request = SavedWordEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try context.fetch(request).compactMap { $0.word }
        } catch {
            print("❌ Failed to fetch saved words:", error)
            return []
        }
    }
    
    private func insert(_ word: String) {
        let entity = SavedWordEntity(context: context)
        entity.word = word
        entity.createdAt = Date()
        stack.saveContext()
    }
}
