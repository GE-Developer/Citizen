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
    
    private let downloader: ResourceDownloading = ResourceDownloader.shared
    
    private init() {}
    
    func start() async {
        await run(gated: true)
    }
    
    func reload() async {
        await run(gated: false)
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
        
        do {
            let language = LanguageManager.shared.currentLanguageID
            try await downloader.ensureResources(language: language)
            try Task.checkCancellation()
            
            try await QuizRepository.shared.load()
            try Task.checkCancellation()
            
            try await WordsDictionary.shared.load()
            try Task.checkCancellation()
            
            try await AlphabetCatalog.shared.load()
            try Task.checkCancellation()
            
            WordOccurrenceIndex.shared.reload()
            phase = .ready
        } catch is CancellationError {
        } catch {
            print("[AppDataLoader] load failed: \(error)")
            phase = .failed
        }
    }
}
