//
//  ResetPasswordView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ResetPasswordView: View {
    @Binding private var route: AuthRoute

    @State private var vm: ResetPasswordViewModel

    init(email: String, route: Binding<AuthRoute>) {
        self._route = route
        self._vm = State(initialValue: ResetPasswordViewModel(email: email))
    }

    var body: some View {
        resetPasswordView
            .task { vm.start() }
    }
}

// MARK: - Builder
extension ResetPasswordView {
    private var resetPasswordView: some View {
        ScrollView {
            VStack(spacing: 0) {
                badge
                title
                subtitle
                fields
                resendRow
                AuthErrorText(message: vm.displayedError)
                submitButton
                backButton

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
    }

    private var badge: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Gradient.accent)
            .frame(width: 72, height: 72)
            .overlay {
                Image.system.lock
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.citizen.white)
            }
            .shadow(color: Color.citizen.accent.opacity(0.5), radius: 16)
            .padding(.top, 40)
    }

    private var title: some View {
        Text(vm.title)
            .font(.title)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .padding(.top, 28)
    }

    private var subtitle: some View {
        VStack(spacing: 2) {
            Text(vm.subtitle)
                .foregroundStyle(Color.citizen.secondaryText)
            Text(vm.email)
                .fontWeight(.semibold)
                .foregroundStyle(Color.citizen.mainText)
        }
        .font(.subheadline)
        .fontDesign(.rounded)
        .multilineTextAlignment(.center)
        .padding(.top, 8)
        .padding(.bottom, 32)
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 16) {
            AuthFieldBlock(label: vm.codeLabel) {
                AuthTextField(
                    text: $vm.code,
                    placeholder: vm.codeLabel,
                    icon: .system.envelope,
                    keyboard: .numberPad,
                    contentType: .oneTimeCode
                )
            }

            AuthFieldBlock(label: vm.newPasswordLabel) {
                CustomSecureField(
                    password: $vm.newPassword,
                    placeholder: vm.newPasswordLabel,
                    isNewPassword: true
//                    error: vm.passwordError != nil
                )
            }

            AuthFieldBlock(label: vm.confirmPasswordLabel) {
                CustomSecureField(
                    password: $vm.confirmPassword,
                    placeholder: vm.confirmPasswordLabel,
                    isNewPassword: true
//                    error: vm.confirmError != nil
                )
            }
        }
        .disabled(vm.isLoading)
    }

    private var resendRow: some View {
        Group {
            if vm.canResend {
                Button(action: resendPressed) {
                    Text(vm.resendTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.citizen.accent)
                }
            } else {
                Text(vm.resendCountdownText)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
        }
        .font(.footnote)
        .fontDesign(.rounded)
        .padding(.top, 20)
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

    private var backButton: some View {
        Button(action: backPressed) {
            Text(vm.backTitle)
                .font(.footnote)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.accent)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
        }
        .disabled(vm.isLoading)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
}

// MARK: - Logic
extension ResetPasswordView {
    private func submitPressed() {
        Task { await vm.submit() }
    }

    private func resendPressed() {
        Task { await vm.resend() }
    }

    private func backPressed() {
        var transaction = Transaction()
        transaction.disablesAnimations = true // keyboard-dismiss UIKit animation leaks into the layout change
        withTransaction(transaction) { route = .signIn }
    }
}
