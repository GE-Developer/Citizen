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
        let entity = fetchEntity(topicID: topicID)
        return TopicStats(
            attempts: Int(entity?.attempts ?? 0),
            bestStreak: Int(entity?.bestStreak ?? 0),
            successfulCompletions: Int(entity?.successfulCompletions ?? 0),
            currentRoundSize: Int(entity?.currentRoundSize ?? 0),
            visitedInRound: Int(entity?.visitedInRound ?? 0)
        )
    }
    
    func setRoundProgress(topicID: String, roundSize: Int, visited: Int) {
        let entity = upsert(topicID: topicID)
        entity.currentRoundSize = Int16(roundSize)
        entity.visitedInRound = Int16(visited)
        stack.saveContext()
    }
    
    @discardableResult
    func incrementAttempts(topicID: String) -> Int {
        let entity = upsert(topicID: topicID)
        entity.attempts += 1
        stack.saveContext()
        return Int(entity.attempts)
    }
    
    func setBestStreak(topicID: String, value: Int) {
        let entity = upsert(topicID: topicID)
        entity.bestStreak = Int16(value)
        stack.saveContext()
    }
    
    @discardableResult
    func incrementSuccessfulCompletions(topicID: String) -> Int {
        let entity = upsert(topicID: topicID)
        entity.successfulCompletions += 1
        stack.saveContext()
        return Int(entity.successfulCompletions)
    }
    
    func resetAttemptStats(topicID: String) {
        let entity = upsert(topicID: topicID)
        entity.attempts = 0
        entity.bestStreak = 0
        entity.currentRoundSize = 0
        entity.visitedInRound = 0
        stack.saveContext()
    }
    
    // MARK: - Private helpers
    private func fetchEntity(topicID: String) -> TopicStatsEntity? {
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
    
    private func upsert(topicID: String) -> TopicStatsEntity {
        if let existing = fetchEntity(topicID: topicID) { return existing }
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
