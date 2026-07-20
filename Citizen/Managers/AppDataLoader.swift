//
//  AppDataLoader.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class AppDataLoader {
    private(set) var phase: LoadPhase = .loading
    
    private var loadTask: Task<Void, Never>?
    
    static let shared = AppDataLoader()
    
    private let mediaStore = MediaStore.shared
    private let wordOccurrenceIndex = WordOccurrenceIndex.shared
    private let quizRepository = QuizRepository.shared
    private let wordsDictionary = WordsDictionary.shared
    private let alphabetCatalog = AlphabetCatalog.shared
    private let progressSync = ProgressSync.shared
    private let profileSync = ProfileSync.shared
    private let avatarStore = AvatarStore.shared
    private let authManager = AuthManager.shared
    private let downloader = ResourceDownloader.shared
    private let syncBootstrapTimeout: TimeInterval = 2
    
    private init() {}
    
    func start() async {
        await run(gated: true)
    }
    
    func reload() async {
        await run(gated: false)
    }
    
    func handleSignedIn() {
        guard phase == .needsAuth else { return }
        
        Task { await run(gated: true) }
    }
    
    func handleSignedOut() {
        progressSync.handleSignedOut()
        profileSync.handleSignedOut()
        avatarStore.wipe()
        
        guard phase == .ready else { return }
        phase = .needsAuth
    }
    
    private func run(gated: Bool) async {
        loadTask?.cancel()
        let task = Task { await load(gated: gated) }
        loadTask = task
        
        await task.value
    }
    
    private func load(gated: Bool) async {
        if gated {
            phase = .loading
        }
        
        let start = Date()
        
        func ms() -> String {
            "\(Int(Date().timeIntervalSince(start) * 1000))ms"
        }
        
        async let sessionValidation: Void = authManager.validateSessionOnServer()
        
        guard authManager.isAuthenticated else {
            await sessionValidation
            phase = .needsAuth
            print("[Loading] TOTAL \(ms()) → \(phase)")
            return
        }
        
        do {
            await profileSync.syncOnLoad()
            try Task.checkCancellation()
            
            try await downloader.ensureResources()
            try Task.checkCancellation()
            
            try await quizRepository.load()
            try Task.checkCancellation()
            
            try await wordsDictionary.load()
            try Task.checkCancellation()
            
            try await alphabetCatalog.load()
            try Task.checkCancellation()
            
            wordOccurrenceIndex.reload()
            print("[Loading] content ready: \(ms())")
            
            await sessionValidation
            print("[Loading] + session validated: \(ms())")
            
            guard authManager.isAuthenticated else {
                phase = .needsAuth
                return
            }
            await progressSync.awaitFirstSyncIfLocalEmpty(timeout: syncBootstrapTimeout)
            print("[Loading] + first sync: \(ms())")
            
            phase = .ready
            print("[Loading] TOTAL \(ms()) → \(phase)")
            progressSync.syncNow(.launch)
            Task { await mediaStore.prefetchAlphabetMedia() }
        } catch is CancellationError {
        } catch {
            print("[AppDataLoader] load failed: \(error)")
            phase = .failed(outOfSpace: DiskSpace.isOutOfSpace(error) || DiskSpace.isCriticallyLow)
        }
    }
}
