//
//  VerifyEmailView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct VerifyEmailView: View {
    @Binding private var route: AuthRoute

    @State private var vm: VerifyEmailViewModel

    @FocusState private var codeFocused: Bool

    private let origin: AuthMode

    init(email: String, name: String?, origin: AuthMode, route: Binding<AuthRoute>) {
        self._route = route
        self.origin = origin
        self._vm = State(initialValue: VerifyEmailViewModel(email: email, name: name))
    }

    var body: some View {
        verifyEmailView
            .task {
                vm.start()
                codeFocused = true
            }
            .onChange(of: vm.code) {
                if vm.isCodeComplete { // numpad has no Done key — hide it to uncover Verify
                    codeFocused = false
                }
            }
    }
}

// MARK: - Builder
extension VerifyEmailView {
    private var verifyEmailView: some View {
        ScrollView {
            VStack(spacing: 0) {
                emailBadge
                title
                subtitle
                codeBoxes
                resendRow
                AuthErrorText(message: vm.generalError)
                verifyButton
                changeEmailButton

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
    }

    private var emailBadge: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Gradient.accent)
            .frame(width: 72, height: 72)
            .overlay {
                Image.system.envelope
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

    private var codeBoxes: some View {
        ZStack {
            TextField("", text: $vm.code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($codeFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)

            HStack(spacing: 10) {
                ForEach(0..<vm.codeLength, id: \.self) { index in
                    codeBox(index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { codeFocused = true }
        }
        .disabled(vm.isLoading)
    }

    private func codeBox(_ index: Int) -> some View {
        let digits = Array(vm.code)
        let isActive = codeFocused && index == min(vm.code.count, vm.codeLength - 1)
        return RoundedRectangle(cornerRadius: 12)
            .fill(Color.citizen.groupBackground)
            .frame(width: 46, height: 56)
            .overlay {
                Text(index < digits.count ? String(digits[index]) : "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.citizen.accent : .clear, lineWidth: 1.5)
            }
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

    private var verifyButton: some View {
        AuthActionButton(
            title: vm.verifyTitle,
            isLoading: vm.isLoading,
            isDisabled: vm.isVerifyDisabled,
            action: verifyPressed
        )
        .padding(.top, 28)
    }

    private var changeEmailButton: some View {
        AuthFooterButton(
            prompt: vm.wrongEmailTitle,
            highlight: vm.changeEmailTitle,
            isDisabled: vm.isLoading,
            action: changeEmailPressed
        )
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
}

// MARK: - Logic
extension VerifyEmailView {
    private func verifyPressed() {
        Task { await vm.verify() }
    }

    private func resendPressed() {
        Task { await vm.resend() }
    }

    private func changeEmailPressed() {
        var transaction = Transaction()
        transaction.disablesAnimations = true // keyboard-dismiss UIKit animation leaks into the layout change
        withTransaction(transaction) {
            route = origin == .signIn ? .signIn : .signUp
        }
    }
}
