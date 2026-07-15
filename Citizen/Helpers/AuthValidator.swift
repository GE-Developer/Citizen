//
//  AuthValidator.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum AuthValidator {
    struct Result {
        let emailError: AuthFieldError?
        let passwordError: AuthFieldError?
        let confirmError: AuthFieldError?
        
        var isValid: Bool {
            emailError == nil && passwordError == nil && confirmError == nil
        }
    }
    
    static let minPasswordLength = 8
    
    static func normalizeEmail(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        email.wholeMatch(of: /[^@\s]+@[^@\s.]+(\.[^@\s.]+)+/) != nil
    }
    
    static func validate(email rawEmail: String, password: String, confirmPassword: String?) -> Result {
        let email = normalizeEmail(rawEmail)
        let emailError: AuthFieldError? = email.isEmpty ? .emptyEmail : (isValidEmail(email) ? nil : .invalidEmail)
        let passwordError: AuthFieldError? = password.count < minPasswordLength ? .shortPassword : nil
        
        var confirmError: AuthFieldError?
        
        if let confirmPassword, passwordError == nil, confirmPassword != password {
            confirmError = .passwordMismatch
        }
        
        return Result(
            emailError: emailError,
            passwordError: passwordError,
            confirmError: confirmError
        )
    }
}
