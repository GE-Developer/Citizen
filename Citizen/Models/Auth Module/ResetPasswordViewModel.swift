//
//  ResetPasswordViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ResetPasswordViewModel {
    var code = "" {
        didSet {
            let sanitized = String(code.filter(\.isNumber).prefix(codeLength))
            if sanitized != code { code = sanitized }
            if code != oldValue { generalError = nil }
        }
    }
    var newPassword = "" {
        didSet { if newPassword != oldValue { passwordError = nil; generalError = nil } }
    }
    var confirmPassword = "" {
        didSet { if confirmPassword != oldValue { confirmError = nil; generalError = nil } }
    }

    var isSubmitDisabled: Bool {
        guard !isLoading else { return true }
        let codeComplete = code.count == codeLength
        let passwordValid = newPassword.count >= AuthValidator.minPasswordLength
        return !(codeComplete && passwordValid && confirmPassword == newPassword)
    }

    var canResend: Bool {
        resendRemaining == 0 && !isLoading
    }

    var resendCountdownText: String {
        let time = String(format: "%02d:%02d", resendRemaining / 60, resendRemaining % 60)
        return "\(resendInTitle) \(time)"
    }

    // Single place errors surface on this screen — fields show no inline messages.
    var displayedError: String? {
        let errors = [passwordError, confirmError, generalError].compactMap { $0 }
        return errors.isEmpty ? nil : errors.joined(separator: "\n")
    }

    private(set) var isLoading = false
    private(set) var passwordError: String?
    private(set) var confirmError: String?
    private(set) var generalError: String?
    private(set) var resendRemaining = 0

    private var hasStarted = false
    private var countdownTask: Task<Void, Never>?

    let email: String
    let title = L10n("Auth.Confirm.title")
    let subtitle = L10n("Auth.Reset.subtitle")
    let codeLabel = L10n("Auth.Confirm.codePlaceholder")
    let newPasswordLabel = L10n("Auth.Password.create")
    let confirmPasswordLabel = L10n("Auth.ConfirmPassword.placeholder")
    let submitTitle = L10n("Auth.Confirm.button")
    let resendTitle = L10n("Auth.Confirm.resend")
    let backTitle = L10n("Auth.Confirm.back")
    let codeLength = 6

    private let resendCooldown = 60
    private let resendInTitle = L10n("Auth.Confirm.resendIn")

    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared

    init(email: String) {
        self.email = email
    }

    /// The first code is always sent before this screen appears (by forgotPassword
    /// on the sign-in screen), so starting = only running the resend cooldown.
    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        startResendCooldown()
    }

    func submit() async {
        guard !isLoading else { return }
        guard validate() else {
            haptics.impact()
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.resetPassword(email: email, code: code, newPassword: newPassword)
            // Success: regular signIn inside resetPassword → SIGNED_IN event →
            // AppDataLoader.handleSignedIn() → RootView shows HomeView.
        } catch {
            haptics.impact()
            generalError = error.message
        }
    }

    func resend() async {
        guard canResend else { return }
        do {
            try await auth.requestPasswordReset(email: email)
            startResendCooldown()
        } catch {
            haptics.impact()
            generalError = error.message
        }
    }

    private func validate() -> Bool {
        let result = AuthValidator.validate(
            email: email,
            password: newPassword,
            confirmPassword: confirmPassword
        )
        passwordError = result.passwordError?.message
        confirmError = result.confirmError?.message
        return result.passwordError == nil && result.confirmError == nil
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
