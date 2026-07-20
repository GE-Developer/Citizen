//
//  AuthManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

@MainActor
@Observable
final class AuthManager {
    var isAuthenticated: Bool {
        session != nil
    }
    
    var userID: UUID? {
        session?.user.id
    }
    
    private(set) var session: Session?
    private(set) var pendingBanNotice = false
    
    private var observationTask: Task<Void, Never>?
    
    static let shared = AuthManager()
    
    private let progressSync = ProgressSync.shared
    private let appDataLoader = AppDataLoader.shared
    private let profileSync = ProfileSync.shared
    private let userDefaults = UserDefaults.standard
    private let client = SupabaseService.client
    private let validationTimeout: TimeInterval = 2
    
    private init() {
        session = client.auth.currentSession
    }
    
    func purgeSessionIfReinstalled() async {
        let markerKey = AppStorageKey.installMarker.key
        
        guard userDefaults.object(forKey: markerKey) == nil else { return }
        userDefaults.set(true, forKey: markerKey)
        
        guard client.auth.currentSession != nil else { return }
        try? await client.auth.signOut(scope: .local)
        session = nil
    }
    
    func startObserving() {
        guard observationTask == nil else { return }
        
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await (event, session) in client.auth.authStateChanges {
                if Task.isCancelled { return }
                handle(event: event, session: session)
            }
        }
    }
    
    func signUp(
        email: String,
        password: String,
        nickname: String?
    ) async throws(AuthFlowError) {
        let response: AuthResponse
        
        do {
            response = try await client.auth.signUp(email: email, password: password)
        } catch {
            throw AuthFlowError.map(error)
        }
        
        if let newSession = response.session {
            session = newSession
            profileSync.registerLocalIdentity(nickname: nickname)
            return
        }
        
        let user = response.user
        let identities = user.identities ?? []
        
        if identities.isEmpty || user.createdAt < Date(timeIntervalSinceNow: -60) {
            throw AuthFlowError.emailAlreadyRegistered
        }
    }
    
    func verifyEmailOTP(
        email: String,
        token: String,
        nickname: String?
    ) async throws(AuthFlowError) {
        let newSession: Session
        
        do {
            let response = try await client
                .auth
                .verifyOTP(email: email, token: token, type: .signup)
            
            guard let session = response.session else { throw AuthFlowError.invalidCode }
            newSession = session
            
        } catch let error as AuthFlowError {
            throw error
        } catch {
            throw AuthFlowError.map(error)
        }
        
        session = newSession
        profileSync.registerLocalIdentity(nickname: nickname)
    }
    
    func resendSignUpCode(email: String) async throws(AuthFlowError) {
        do {
            try await client
                .auth
                .resend(email: email, type: .signup)
        } catch {
            throw AuthFlowError.map(error)
        }
    }
    
    func signIn(email: String, password: String) async throws(AuthFlowError) {
        let newSession: Session
        
        do {
            newSession = try await client
                .auth
                .signIn(email: email, password: password)
        } catch {
            throw AuthFlowError.map(error)
        }
        
        session = newSession
    }
    
    func requestPasswordReset(email: String) async throws(AuthFlowError) {
        do {
            try await client
                .auth
                .resetPasswordForEmail(email)
        } catch {
            throw AuthFlowError.map(error)
        }
    }
    
    func resetPassword(email: String, code: String, newPassword: String) async throws(AuthFlowError) {
        let recovery = SupabaseService.makeEphemeralClient()
        do {
            let response = try await recovery.auth.verifyOTP(email: email, token: code, type: .recovery)
            guard response.session != nil else { throw AuthFlowError.invalidCode }
            
            try await recovery.auth.update(user: UserAttributes(password: newPassword))
            try? await recovery.auth.signOut(scope: .global)
        } catch let error as AuthFlowError {
            throw error
        } catch {
            throw AuthFlowError.map(error)
        }
        
        try await signIn(email: email, password: newPassword)
    }
    
    func changePassword(current: String, new: String) async throws(AuthFlowError) {
        guard let email = session?.user.email else { throw AuthFlowError.unknown }
        
        let verifier = SupabaseService.makeEphemeralClient()
        do {
            _ = try await verifier.auth.signIn(email: email, password: current)
            try await client
                .auth
                .update(user: UserAttributes(password: new))
            try? await client.auth.signOut(scope: .others)
        } catch {
            try? await verifier.auth.signOut(scope: .local)
            throw AuthFlowError.map(error)
        }
    }
    
    func signOut() async {
        do {
            try await client
                .auth
                .signOut(scope: .local)
        } catch {
            print("[AuthManager] server signOut failed: \(error)")
        }
        if session != nil {
            session = nil
            appDataLoader.handleSignedOut()
        }
    }
    
    func deleteAccount() async throws(AuthFlowError) {
        do {
            try await client
                .functions
                .invoke("delete-account")
        } catch {
            throw AuthFlowError.map(error)
        }
        progressSync.wipeForAccountDeletion()
        
        try? await client.auth.signOut(scope: .local)
        if session != nil {
            session = nil
            appDataLoader.handleSignedOut()
        }
    }
    
    func validateSessionOnServer() async {
        guard isAuthenticated else { return }
        
        let client = client
        let timeout = validationTimeout
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { _ = try await client.auth.refreshSession() }
                group.addTask {
                    try await Task.sleep(for: .seconds(timeout))
                    throw URLError(.timedOut)
                }
                try await group.next()
                group.cancelAll()
            }
            print("[AuthManager] session validation passed (refresh OK)")
        } catch let error as AuthError {
            print("[AuthManager] session validation rejected: \(String(describing: error.errorCode)) — \(error.localizedDescription)")
            switch error.errorCode {
            case .userBanned:
                pendingBanNotice = true
                await signOut()
            case .userNotFound, .sessionNotFound, .badJWT, .refreshTokenNotFound:
                await signOut()
            default:
                if error.localizedDescription.lowercased().contains("banned") {
                    pendingBanNotice = true
                    await signOut()
                }
            }
        } catch {
            print("[AuthManager] session validation inconclusive: \(error)")
        }
    }
    
    func consumeBanNotice() -> Bool {
        guard pendingBanNotice else { return false }
        pendingBanNotice = false
        return true
    }
    
    private func handle(event: AuthChangeEvent, session: Session?) {
        switch event {
        case .initialSession, .tokenRefreshed, .userUpdated:
            self.session = session
        case .signedIn:
            self.session = session
            appDataLoader.handleSignedIn()
        case .signedOut, .userDeleted:
            self.session = nil
            appDataLoader.handleSignedOut()
        default:
            break
        }
    }
}
