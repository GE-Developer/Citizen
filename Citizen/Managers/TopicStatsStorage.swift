//
//  TopicStatsStorage.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreData

@MainActor
final class TopicStatsStorage {
    private var context: NSManagedObjectContext { stack.context }
    
    static let shared = TopicStatsStorage()
    
    private let stack = CoreDataStack.shared
    
    private init() {}
    
    // MARK: - Public API
    func fetch(topicID: String) -> TopicStats {
        let entity = Self.fetchEntity(topicID: topicID, in: context)
        return TopicStats(
            attempts: Int(entity?.attempts ?? 0),
            bestStreak: Int(entity?.bestStreak ?? 0),
            successfulCompletions: Int(entity?.successfulCompletions ?? 0),
            currentRoundSize: Int(entity?.currentRoundSize ?? 0),
            visitedInRound: Int(entity?.visitedInRound ?? 0)
        )
    }
    
    func setRoundProgress(topicID: String, roundSize: Int, visited: Int) {
        let entity = Self.upsert(topicID: topicID, in: context)
        entity.currentRoundSize = Int16(roundSize)
        entity.visitedInRound = Int16(visited)
        stack.saveContext()
    }
    
    func setAttempts(topicID: String, value: Int) {
        Self.upsert(topicID: topicID, in: context).attempts = Int16(value)
        stack.saveContext()
    }
    
    func setBestStreak(topicID: String, value: Int) {
        Self.upsert(topicID: topicID, in: context).bestStreak = Int16(value)
        stack.saveContext()
    }
    
    func setSuccessfulCompletions(topicID: String, value: Int) {
        Self.upsert(topicID: topicID, in: context).successfulCompletions = Int16(value)
        stack.saveContext()
    }
    
    func resetAttemptStats(topicID: String) {
        let entity = Self.upsert(topicID: topicID, in: context)
        entity.attempts = 0
        entity.bestStreak = 0
        entity.currentRoundSize = 0
        entity.visitedInRound = 0
        stack.saveContext()
    }
    
    // MARK: - Private helpers
    private nonisolated static func fetchEntity(
        topicID: String,
        in context: NSManagedObjectContext
    ) -> TopicStatsEntity? {
        let request: NSFetchRequest<TopicStatsEntity> = TopicStatsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "topicID == %@", topicID)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to fetch topic stats:", error)
            return nil
        }
    }
    
    private nonisolated static func upsert(
        topicID: String,
        in context: NSManagedObjectContext
    ) -> TopicStatsEntity {
        if let existing = fetchEntity(topicID: topicID, in: context) { return existing }
        let entity = TopicStatsEntity(context: context)
        entity.topicID = topicID
        entity.attempts = 0
        entity.bestStreak = 0
        entity.successfulCompletions = 0
        entity.currentRoundSize = 0
        entity.visitedInRound = 0
        return entity
    }
}
