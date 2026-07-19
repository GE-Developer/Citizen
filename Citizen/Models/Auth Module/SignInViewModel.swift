//
//  SignInViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class SignInViewModel {
    var email = "" {
        didSet { if email != oldValue { emailError = nil; generalError = nil } }
    }
    var password = "" {
        didSet { if password != oldValue { passwordError = nil; generalError = nil } }
    }
    var isShowingLanguageSheet = false

    var isSubmitDisabled: Bool {
        guard !isLoading else { return true }
        let emailValid = AuthValidator.isValidEmail(AuthValidator.normalizeEmail(email))
        let passwordValid = password.count >= AuthValidator.minPasswordLength
        return !(emailValid && passwordValid)
    }

    // Single place errors surface on this screen — fields show no inline messages.
    var displayedError: String? {
        let errors = [emailError, passwordError, generalError].compactMap { $0 }
        return errors.isEmpty ? nil : errors.joined(separator: "\n")
    }

    // Computed (not `let`) so the texts re-resolve live when the user switches language.
    var subtitle: String { L10n("Auth.SignIn.subtitle") }
    var submitTitle: String { L10n("Auth.SignIn.button") }
    var emailLabel: String { L10n("Auth.Email.placeholder") }
    var emailPlaceholder: String { L10n("Auth.Email.example") }
    var passwordLabel: String { L10n("Auth.Password.placeholder") }
    var forgotPasswordTitle: String { L10n("Auth.forgotPassword") }
    var appleButtonTitle: String { L10n("Auth.appleButton") }
    var orTitle: String { L10n("Auth.divider.or") }
    var switchPrompt: String { L10n("Auth.switchToSignUp.prompt") }
    var switchAction: String { L10n("Auth.switchToSignUp.action") }
    var languageSheetTitle: String { L10n("Settings.General.Language.title") }

    var currentLanguageName: String {
        Language(rawValue: languageManager.currentLanguageID)?.localizedName
        ?? Language.english.localizedName
    }

    private(set) var isLoading = false
    private(set) var animatedTitle = ""
    private(set) var emailError: String?
    private(set) var passwordError: String?
    private(set) var generalError: String?

    let fullTitle = "გამარჯობა" // deliberately Georgian in every locale — typed out by animateTitle()

    private let auth = AuthManager.shared
    private let haptics = HapticsManager.shared
    private let languageManager = LanguageManager.shared

    /// Endless typewriter loop: type the word, hold, erase, pause, repeat.
    /// Runs inside the view's `.task` — cancelled automatically when the screen disappears.
    func animateTitle() async {
        while !Task.isCancelled {
            for index in fullTitle.indices {
                animatedTitle = String(fullTitle[...index])
                try? await Task.sleep(for: .milliseconds(150))
                if Task.isCancelled { return }
            }
            try? await Task.sleep(for: .seconds(1.2))
            while !animatedTitle.isEmpty {
                animatedTitle = String(animatedTitle.dropLast())
                try? await Task.sleep(for: .milliseconds(80))
                if Task.isCancelled { return }
            }
            try? await Task.sleep(for: .milliseconds(400))
        }
    }

    /// Returns the email that still needs OTP confirmation, nil otherwise
    /// (signed in successfully or failed with a shown error).
    func submit() async -> String? {
        guard !isLoading else { return nil } // double-tap protection
        guard validate() else {
            haptics.impact()
            return nil
        }
        isLoading = true
        defer { isLoading = false }
        let normalizedEmail = AuthValidator.normalizeEmail(email)
        do {
            try await auth.signIn(email: normalizedEmail, password: password)
            // Success: SIGNED_IN event → AppDataLoader.handleSignedIn() → RootView shows HomeView.
            return nil
        } catch {
            haptics.impact()
            if case .emailNotConfirmed = error {
                // Registered earlier but never confirmed — send a fresh code before the code screen.
                try? await auth.resendSignUpCode(email: normalizedEmail)
                return normalizedEmail
            }
            generalError = error.message
            return nil
        }
    }

    /// Returns the email the reset code was sent to, nil otherwise
    /// (invalid email in the field or sending failed with a shown error).
    func forgotPassword() async -> String? {
        guard !isLoading else { return nil }
        let normalizedEmail = AuthValidator.normalizeEmail(email)
        guard AuthValidator.isValidEmail(normalizedEmail) else {
            haptics.impact()
            let fieldError: AuthFieldError = normalizedEmail.isEmpty ? .emptyEmail : .invalidEmail
            emailError = fieldError.message
            return nil
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.requestPasswordReset(email: normalizedEmail)
            return normalizedEmail
        } catch {
            haptics.impact()
            generalError = error.message
            return nil
        }
    }

    func signInWithApple() {
        // TODO(Auth): Sign in with Apple via signInWithIdToken — Auth-TODO.md §3
    }

    func isCurrentLanguage(_ language: Language) -> Bool {
        language.id == languageManager.currentLanguageID
    }

    func setLanguage(_ language: Language) {
        guard !isCurrentLanguage(language) else { return }
        languageManager.currentLanguageID = language.id
        isShowingLanguageSheet = false
        // Auth resources reload quietly: reload() keeps phase == .needsAuth,
        // so the sign-in screen stays put while data re-fetches for the new language.
        Task { await AppDataLoader.shared.reload() }
    }

    private func validate() -> Bool {
        let result = AuthValidator.validate(email: email, password: password, confirmPassword: nil)
        emailError = result.emailError?.message
        passwordError = result.passwordError?.message
        return result.isValid
    }
}
