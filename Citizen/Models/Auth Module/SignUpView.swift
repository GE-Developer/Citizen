//
//  SignUpView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SignUpView: View {
    @Binding private var route: AuthRoute

    @State private var vm = SignUpViewModel()

    init(route: Binding<AuthRoute>) {
        self._route = route
    }

    var body: some View {
        signUpView
    }
}

// MARK: - Builder
extension SignUpView {
    private var signUpView: some View {
        ScrollView {
            VStack(spacing: 0) {
                title
                subtitle
                fields
                AuthErrorText(message: vm.displayedError)
                submitButton
                orDivider
                appleButton
                switchModeButton

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
    }

    private var title: some View {
        Text(vm.title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
    }

    private var subtitle: some View {
        Text(vm.subtitle)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .padding(.top, 6)
            .padding(.bottom, 28)
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 16) {
            AuthFieldBlock(label: vm.nameLabel) {
                AuthTextField(
                    text: $vm.name,
                    placeholder: vm.nameLabel,
                    icon: .system.person,
                    contentType: .name
                )
            }

            AuthFieldBlock(label: vm.emailLabel) {
                AuthTextField(
                    text: $vm.email,
                    placeholder: vm.emailPlaceholder,
                    icon: .system.envelope,
                    keyboard: .emailAddress,
                    contentType: .username
//                    error: vm.emailError != nil
                )
            }

            AuthFieldBlock(label: vm.passwordLabel) {
                CustomSecureField(
                    password: $vm.password,
                    placeholder: vm.createPasswordPlaceholder,
                    isNewPassword: true
//                    error: vm.passwordError != nil
                )
            }

            AuthFieldBlock(label: vm.repeatPasswordLabel) {
                CustomSecureField(
                    password: $vm.confirmPassword,
                    placeholder: vm.repeatPasswordLabel,
                    isNewPassword: true
//                    error: vm.confirmPasswordError != nil
                )
            }
        }
        .disabled(vm.isLoading)
    }

    private var submitButton: some View {
        AuthActionButton(
            title: vm.submitTitle,
            isLoading: vm.isLoading,
            isDisabled: vm.isSubmitDisabled,
            action: submitPressed
        )
        .padding(.top, 28)
    }

    private var orDivider: some View {
        AuthDivider(text: vm.orTitle)
            .padding(.top, 20)
    }

    private var appleButton: some View {
        AuthAppleButton(
            title: vm.appleButtonTitle,
            isDisabled: vm.isLoading,
            action: vm.signInWithApple
        )
        .padding(.top, 20)
    }

    private var switchModeButton: some View {
        AuthFooterButton(
            prompt: vm.switchPrompt,
            highlight: vm.switchAction,
            isDisabled: vm.isLoading,
            action: switchModePressed
        )
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Logic
extension SignUpView {
    private func submitPressed() {
        Task {
            guard let pending = await vm.submit() else { return }
            setRoute(.verifyEmail(email: pending.email, name: pending.name, origin: .signUp))
        }
    }

    private func switchModePressed() {
        setRoute(.signIn)
    }

    private func setRoute(_ newRoute: AuthRoute) {
        var transaction = Transaction()
        transaction.disablesAnimations = true // keyboard-dismiss UIKit animation leaks into the layout change
        withTransaction(transaction) { route = newRoute }
    }
}
