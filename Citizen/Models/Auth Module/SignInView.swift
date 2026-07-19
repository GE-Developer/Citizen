//
//  SignInView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SignInView: View {
    @Binding private var route: AuthRoute

    @State private var vm = SignInViewModel()

    private var minContentHeight: CGFloat {
        screenHeight - safeAreaTop - safeAreaBottom
    }

    init(route: Binding<AuthRoute>) {
        self._route = route
    }

    var body: some View {
        signInView
            .task { await vm.animateTitle() }
            .sheet(isPresented: $vm.isShowingLanguageSheet) { languageSheet }
    }
}

// MARK: - Builder
extension SignInView {
    private var signInView: some View {
        ScrollView {
            VStack(spacing: 25) {
                logo
                welcomeTitle
                fields
//            forgotPasswordButton
                AuthErrorText(message: vm.displayedError)
                Spacer()
                VStack(spacing: 6) {
                    submitButton
                    orDivider
                    appleButton
                    languageButton
                    switchModeButton
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, isFaceIDPhone ? -5 : 16)
            .frame(minHeight: minContentHeight)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
    }

    private var logo: some View {
        Image.other.logo
            .resizable()
            .scaledToFit()
            .frame(height: 56)
    }

    private var welcomeTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                Text(vm.fullTitle) // invisible size anchor — no layout jumps while typing
//                    .hidden()
                    .foregroundStyle(Color.citizen.mainText)
                Text(vm.animatedTitle)
                    .foregroundStyle(Gradient.accent)
            }
            .font(.title)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .lineLimit(1)

            Text(vm.subtitle)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
    }


    
    
    
    
    private var fields: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormHeaderView(vm.emailLabel)
            AuthTextField(
                text: $vm.email,
                placeholder: vm.emailPlaceholder,
                icon: .system.envelope,
                keyboard: .emailAddress,
                contentType: .username
            )
            .padding(.bottom, 4)
            
            FormHeaderView(vm.passwordLabel)
            CustomSecureField(password: $vm.password, placeholder: vm.passwordLabel)
            
            Button(action: forgotPasswordPressed) {
                Text(vm.forgotPasswordTitle)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 4)
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
    }

    private var orDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.citizen.secondaryText.opacity(0.25))
                .frame(height: 1)
            Text(vm.orTitle)
                .font(.footnote)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
            Rectangle()
                .fill(Color.citizen.secondaryText.opacity(0.25))
                .frame(height: 1)
        }
    }

    private var appleButton: some View {
        AuthAppleButton(
            title: vm.appleButtonTitle,
            isDisabled: vm.isLoading,
            action: vm.signInWithApple
        )
    }

    private var switchModeButton: some View {
        AuthFooterButton(
            prompt: vm.switchPrompt,
            highlight: vm.switchAction,
            isDisabled: vm.isLoading,
            action: switchModePressed
        )
    }

    private var languageButton: some View {
        Button(action: languagePressed) {
            HStack(spacing: 6) {
                Image.system.language
                    .font(.footnote)
                Text(vm.currentLanguageName)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
            }
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
        }
        .disabled(vm.isLoading)
    }

    private var languageSheet: some View {
        VStack(spacing: 0) {
            CustomForm(headerText: vm.languageSheetTitle) {
                let languages = Array(Language.allCases.enumerated())

                ForEach(languages, id: \.element.id) {
                    languageRow($0, $1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.citizen.background)
    }

    private func languageRow(_ index: Int, _ language: Language) -> some View {
        VStack(spacing: 0) {
            CustomButtonRow(
                title: language.localizedName,
                subtitle: language.englishName,
                withCheckmark: vm.isCurrentLanguage(language),
                action: { vm.setLanguage(language) }
            )
            if index < Language.allCases.count - 1 {
                Divider()
                    .padding(.leading, 20)
            }
        }
    }
}

// MARK: - Logic
extension SignInView {
    private func submitPressed() {
        Task {
            guard let pendingEmail = await vm.submit() else { return }
            setRoute(.verifyEmail(email: pendingEmail, name: nil, origin: .signIn))
        }
    }

    private func switchModePressed() {
        setRoute(.signUp)
    }

    private func languagePressed() {
        vm.isShowingLanguageSheet = true
    }

    private func forgotPasswordPressed() {
        Task {
            guard let email = await vm.forgotPassword() else { return }
            setRoute(.resetPassword(email: email))
        }
    }

    private func setRoute(_ newRoute: AuthRoute) {
        var transaction = Transaction()
        transaction.disablesAnimations = true // keyboard-dismiss UIKit animation leaks into the layout change
        withTransaction(transaction) { route = newRoute }
    }
}
