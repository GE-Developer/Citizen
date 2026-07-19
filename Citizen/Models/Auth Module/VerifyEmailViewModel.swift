//
//  VerifyEmailViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class VerifyEmailViewModel {
    var code = "" {
        didSet {
            let sanitized = String(code.filter(\.isNumber).prefix(codeLength))
            if sanitized != code { code = sanitized }
            if code != oldValue { generalError = nil }
        }
    }

    var isCodeComplete: Bool {
        code.count == codeLength
    }

    var isVerifyDisabled: Bool {
        isLoading || !isCodeComplete
    }

    var canResend: Bool {
        resendRemaining == 0 && !isLoading
    }

    var resendCountdownText: String {
        let time = String(format: "%02d:%02d", resendRemaining / 60, resendRemaining % 60)
        return "\(resendInTitle) \(time)"
    }

    private(set) var isLoading = false
    private(set) var generalError: String?
    private(set) var resendRemaining = 0

    private var hasStarted = false
    private var countdownTask: Task<Void, Never>?

    let email: String
    let title = L10n("Auth.Confirm.title")
    let subtitle = L10n("Auth.Confirm.subtitle")
    let verifyTitle = L10n("Auth.Confirm.button")
    let resendTitle = L10n("Auth.Confirm.resend")
    let wrongEmailTitle = L10n("Auth.Confirm.wrongEmail")
    let changeEmailTitle = L10n("Auth.Confirm.change")
    let codeLength = 6

    private let name: String?
    private let resendCooldown = 60
    private let resendInTitle = L10n("Auth.Confirm.resendIn")

    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared

    init(email: String, name: String?) {
        self.email = email
        self.name = name
    }

    /// The first code is always sent before this screen appears (by signUp or by
    /// the sign-in unconfirmed path), so starting = only running the cooldown.
    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        startResendCooldown()
    }

    func verify() async {
        guard !isLoading, isCodeComplete else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.verifyEmailOTP(email: email, token: code, name: name)
            // Success: SIGNED_IN event → AppDataLoader.handleSignedIn() → RootView shows HomeView.
        } catch {
            haptics.impact()
            generalError = error.message
        }
    }

    func resend() async {
        guard canResend else { return }
        do {
            try await auth.resendSignUpCode(email: email)
            startResendCooldown()
        } catch {
            haptics.impact()
            generalError = error.message
        }
    }

    private func startResendCooldown() {
        countdownTask?.cancel()
        resendRemaining = resendCooldown
        countdownTask = Task { [weak self] in
            while let self, self.resendRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                self.resendRemaining -= 1
            }
        }
    }
}
