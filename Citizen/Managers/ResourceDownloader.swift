//
//  ResourceDownloader.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

protocol ResourceDownloading: Sendable {
    func ensureResources(language: String) async throws
}

final class ResourceDownloader: ResourceDownloading, Sendable {
    static let shared = ResourceDownloader()
    
    private init() {}
    
    func ensureResources(language: String) async throws {
        try invalidateDownloadsIfAppUpdated()
    }
    
    private func invalidateDownloadsIfAppUpdated() throws {
        let defaults = UserDefaults.standard
        let key = AppStorageKey.resourcesVersion.key
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        
        guard defaults.string(forKey: key) != current else { return }
        
        try ResourceProvider.shared.removeAllDownloads()
        
        defaults.set(current, forKey: key)
    }
}
