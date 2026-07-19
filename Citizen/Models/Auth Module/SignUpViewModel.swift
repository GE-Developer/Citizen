//
//  SignUpViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class SignUpViewModel {
    var name = ""

    var email = "" {
        didSet { if email != oldValue { emailError = nil; generalError = nil } }
    }
    var password = "" {
        didSet { if password != oldValue { passwordError = nil; generalError = nil } }
    }
    var confirmPassword = "" {
        didSet { if confirmPassword != oldValue { confirmPasswordError = nil; generalError = nil } }
    }

    var isSubmitDisabled: Bool {
        guard !isLoading else { return true }
        let emailValid = AuthValidator.isValidEmail(AuthValidator.normalizeEmail(email))
        let passwordValid = password.count >= AuthValidator.minPasswordLength
        return !(emailValid && passwordValid && confirmPassword == password)
    }

    // Single place errors surface on this screen — fields show no inline messages.
    var displayedError: String? {
        let errors = [emailError, passwordError, confirmPasswordError, generalError].compactMap { $0 }
        return errors.isEmpty ? nil : errors.joined(separator: "\n")
    }

    private(set) var isLoading = false
    private(set) var emailError: String?
    private(set) var passwordError: String?
    private(set) var confirmPasswordError: String?
    private(set) var generalError: String?

    let title = L10n("Auth.SignUp.title")
    let subtitle = L10n("Auth.SignUp.subtitle")
    let submitTitle = L10n("Auth.SignUp.button")
    let nameLabel = L10n("Auth.Name.placeholder")
    let emailLabel = L10n("Auth.Email.placeholder")
    let emailPlaceholder = L10n("Auth.Email.example")
    let passwordLabel = L10n("Auth.Password.placeholder")
    let createPasswordPlaceholder = L10n("Auth.Password.create")
    let repeatPasswordLabel = L10n("Auth.ConfirmPassword.placeholder")
    let appleButtonTitle = L10n("Auth.appleButton")
    let orTitle = L10n("Auth.divider.or")
    let switchPrompt = L10n("Auth.switchToSignIn.prompt")
    let switchAction = L10n("Auth.switchToSignIn.action")

    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared

    /// Returns the email/name pair that needs OTP confirmation, nil otherwise
    /// (signed in directly with Confirm email off, or failed with a shown error).
    func submit() async -> (email: String, name: String?)? {
        guard !isLoading else { return nil } // double-tap protection
        guard validate() else {
            haptics.impact()
            return nil
        }
        isLoading = true
        defer { isLoading = false }
        let normalizedEmail = AuthValidator.normalizeEmail(email)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let userName = trimmedName.isEmpty ? nil : trimmedName
        do {
            try await auth.signUp(email: normalizedEmail, password: password, name: userName)
            // Confirm email ON → no session yet, the emailed OTP code confirms the account.
            return auth.isAuthenticated ? nil : (normalizedEmail, userName)
        } catch {
            haptics.impact()
            generalError = error.message
            return nil
        }
    }

    func signInWithApple() {
        // TODO(Auth): Sign in with Apple via signInWithIdToken — Auth-TODO.md §3
    }

    private func validate() -> Bool {
        let result = AuthValidator.validate(
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        emailError = result.emailError?.message
        passwordError = result.passwordError?.message
        confirmPasswordError = result.confirmError?.message
        return result.isValid
    }
}
