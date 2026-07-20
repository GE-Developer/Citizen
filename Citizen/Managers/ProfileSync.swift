//
//  ProfileSync.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum SaveOutcome {
    case saved
    case offline
    case failed
}

@MainActor
final class ProfileSync {
    static let shared = ProfileSync()
    
    private var pushTask: Task<Void, Never>?
    
    private let service = ProfileService.shared
    private let avatarService = AvatarService.shared
    private let avatarStore = AvatarStore.shared
    private let networkMonitor = NetworkMonitor.shared
    private let authManager = AuthManager.shared
    private let languageManager = LanguageManager.shared
    private let userDefaults = UserDefaults.standard
    private let fetchTimeout: TimeInterval = 2
    private let comparisonTolerance: TimeInterval = 0.5
    
    private init() {}
    
    func registerLocalIdentity(nickname: String?) {
        if let nickname {
            UserDefaults.standard.set(nickname, forKey: AppStorageKey.userNickname.key)
        }
        setLocalEditedAt(Date())
    }
    
    func noteLocalEdit() {
        setLocalEditedAt(Date())
        push()
    }
    
    func commitIdentityEdit() async -> SaveOutcome {
        setLocalEditedAt(Date())
        pushTask?.cancel()
        
        do {
            try await sendIdentity()
            return .saved
        } catch {
            return networkMonitor.isConnected ? .failed : .offline
        }
    }
    
    func handleSignedOut() {
        pushTask?.cancel()
        pushTask = nil
        userDefaults.removeObject(forKey: AppStorageKey.userNickname.key)
        userDefaults.removeObject(forKey: AppStorageKey.userAvatarURL.key)
        userDefaults.removeObject(forKey: AppStorageKey.avatarUploadPending.key)
        userDefaults.removeObject(forKey: AppStorageKey.userDataUpdatedAt.key)
    }
    
    func uploadAvatar(jpeg: Data) async -> SaveOutcome {
        guard let userID = authManager.userID else { return .failed }
        
        do {
            let url = try await avatarService.upload(userID: userID, jpeg: jpeg)
            userDefaults.set(url, forKey: AppStorageKey.userAvatarURL.key)
            userDefaults.removeObject(forKey: AppStorageKey.avatarUploadPending.key)
            
            await avatarService.deleteAll(userID: userID, except: url)
            
            return await commitIdentityEdit()
        } catch {
            userDefaults.set(true, forKey: AppStorageKey.avatarUploadPending.key)
            print("[ProfileSync] avatar upload failed (will retry): \(error)")
            
            return networkMonitor.isConnected ? .failed : .offline
        }
    }
    
    func removeAvatar() async -> SaveOutcome {
        guard let userID = authManager.userID else { return .failed }
        await avatarService.deleteAll(userID: userID, except: nil)
        
        avatarStore.wipe()
        userDefaults.set("", forKey: AppStorageKey.userAvatarURL.key)
        userDefaults.removeObject(forKey: AppStorageKey.avatarUploadPending.key)
        
        return await commitIdentityEdit()
    }
    
    func syncOnLoad() async {
        guard authManager.userID != nil else { return }
        
        await retryPendingAvatarUpload()
        let identity: ProfileIdentity?
        
        do {
            identity = try await fetchIdentityBounded()
        } catch {
            print("[ProfileSync] pass skipped (offline?): \(error)")
            return
        }
        
        let serverDate = identity?
            .userDataUpdatedAt
            .flatMap(PostgresTimestamp.date(from:))
        
        let localDate = localEditedAt()
        
        switch (serverDate, localDate) {
        case (nil, nil):
            setLocalEditedAt(Date())
            push()
        case (nil, .some):
            push()
        case (let server?, nil):
            apply(identity, serverDate: server)
        case (let server?, let local?):
            if server.timeIntervalSince(local) > comparisonTolerance {
                apply(identity, serverDate: server)
            } else if local.timeIntervalSince(server) > comparisonTolerance {
                push()
            } else if identity?.email != authManager.session?.user.email {
                push()
            }
        }
    }
    
    // MARK: - LWW Sides
    private func apply(_ identity: ProfileIdentity?, serverDate: Date) {
        guard let identity else { return }
        if let language = identity.language,
           Language(rawValue: language) != nil,
           language != languageManager.currentLanguageID {
            languageManager.currentLanguageID = language
            print("[ProfileSync] applied server language: \(language)")
        }
        
        if let nickname = identity.nickname {
            UserDefaults.standard.set(nickname, forKey: AppStorageKey.userNickname.key)
        }
        
        applyAvatarURL(identity.avatarURL)
        setLocalEditedAt(serverDate)
    }
    
    private func applyAvatarURL(_ serverURL: String?) {
        let localURL = UserDefaults.standard.string(forKey: AppStorageKey.userAvatarURL.key)
        
        guard let serverURL, !serverURL.isEmpty else {
            if let localURL, !localURL.isEmpty {
                avatarStore.wipe()
                userDefaults.set("", forKey: AppStorageKey.userAvatarURL.key)
            }
            
            return
        }
        
        guard serverURL != localURL else { return }
        
        Task { [avatarService, avatarStore] in
            do {
                let data = try await avatarService.download(from: serverURL)
                avatarStore.store(data)
                userDefaults.set(serverURL, forKey: AppStorageKey.userAvatarURL.key)
            } catch {
                print("[ProfileSync] avatar download failed: \(error)")
            }
        }
    }
    
    private func retryPendingAvatarUpload() async {
        guard userDefaults.bool(forKey: AppStorageKey.avatarUploadPending.key),
              let jpeg = avatarStore.currentJPEGData() else { return }
        _ = await uploadAvatar(jpeg: jpeg)
    }
    
    private func push() {
        pushTask?.cancel()
        
        pushTask = Task { [weak self] in
            try? await self?.sendIdentity()
        }
    }
    
    private func sendIdentity() async throws {
        guard let userID = authManager.userID else { return }
        
        let email = authManager.session?.user.email
        let nickname = userDefaults.string(forKey: AppStorageKey.userNickname.key)
        let avatarURL = userDefaults.string(forKey: AppStorageKey.userAvatarURL.key)
        let language = languageManager.currentLanguageID
        let editedAt = localEditedAt() ?? Date()
        
        try await service.pushIdentity(
            userID: userID,
            email: email,
            nickname: nickname,
            avatarURL: avatarURL,
            language: language,
            editedAt: editedAt
        )
    }
    
    // MARK: - Plumbing
    private func fetchIdentityBounded() async throws -> ProfileIdentity? {
        guard let userID = authManager.userID else { return nil }
        
        let timeout = fetchTimeout
        let service = service
        
        return try await withThrowingTaskGroup(of: ProfileIdentity?.self) { group in
            group.addTask { try await service.fetchIdentity(userID: userID) }
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw URLError(.timedOut)
            }
            
            guard let identity = try await group.next() else { throw URLError(.unknown) }
            
            group.cancelAll()
            return identity
        }
    }
    
    private func localEditedAt() -> Date? {
        let stamp = userDefaults.double(forKey: AppStorageKey.userDataUpdatedAt.key)
        return stamp > 0 ? Date(timeIntervalSince1970: stamp) : nil
    }
    
    private func setLocalEditedAt(_ date: Date) {
        userDefaults.set(
            date.timeIntervalSince1970,
            forKey: AppStorageKey.userDataUpdatedAt.key
        )
    }
}
