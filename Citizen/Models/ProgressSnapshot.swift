//
//  ProgressSnapshot.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

struct ProgressSnapshot: Codable, Sendable, Equatable {
    struct AnsweredQuestion: Codable, Sendable, Equatable {
        let id: String
        let isCorrect: Bool
    }
    
    struct TopicStatsItem: Codable, Sendable, Equatable {
        let topicID: String
        let attempts: Int
        let bestStreak: Int
        let successfulCompletions: Int
        let currentRoundSize: Int
        let visitedInRound: Int
    }
    
    struct SavedWordItem: Codable, Sendable, Equatable {
        let word: String
        let createdAt: Double
    }
    
    struct FolderItem: Codable, Sendable, Equatable {
        let id: String
        let name: String
        let createdAt: Double
    }
    
    struct SavedQuestionItem: Codable, Sendable, Equatable {
        let questionID: String
        let folderID: String
        let createdAt: Double
    }
    
    var isEmpty: Bool {
        answers.isEmpty
        && mistakePool.isEmpty
        && topicStats.isEmpty
        && savedWords.isEmpty
        && folders.isEmpty
        && savedQuestions.isEmpty
    }
    
    let schemaVersion: Int
    
    let answers: [AnsweredQuestion]
    let mistakePool: [String]
    let topicStats: [TopicStatsItem]
    let savedWords: [SavedWordItem]
    let folders: [FolderItem]
    let savedQuestions: [SavedQuestionItem]
    
    static let currentSchemaVersion = 1
}
