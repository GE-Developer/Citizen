//
//  AuthView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AuthView: View {
    @State private var route: AuthRoute = .signIn

    var body: some View {
        authView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.citizen.background.ignoresSafeArea())
    }
}

// MARK: - Builder
extension AuthView {
    @ViewBuilder
    private var authView: some View {
        switch route {
        case .signIn:
            SignInView(route: $route)
        case .signUp:
            SignUpView(route: $route)
        case .verifyEmail(let email, let name, let origin):
            VerifyEmailView(
                email: email,
                name: name,
                origin: origin,
                route: $route
            )
        case .resetPassword(let email):
            ResetPasswordView(email: email, route: $route)
        }
    }
}
