//
//  AuthRoute.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AuthRoute: Equatable {
    case signIn
    case signUp
    case verifyEmail(email: String, name: String?, origin: AuthMode)
    case resetPassword(email: String)
}
