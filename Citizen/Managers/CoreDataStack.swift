//
//  CoreDataStack.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class CoreDataStack {
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    let container: NSPersistentContainer
    
    static let shared = CoreDataStack()
    
    private init() {
        container = NSPersistentContainer(name: "AnswerContainer")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("❌ Failed to save context:", error)
        }
    }
    
    func batchDelete(entityName: String, predicate: NSPredicate? = nil) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        delete.resultType = .resultTypeObjectIDs
        
        do {
            let result = try context.execute(delete) as? NSBatchDeleteResult
            let ids = result?.result as? [NSManagedObjectID] ?? []
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: ids],
                into: [context]
            )
        } catch {
            print("❌ Failed to batch delete \(entityName):", error)
        }
    }
}
