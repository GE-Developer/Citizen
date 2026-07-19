//
//  AuthComponents.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AuthFieldBlock<Content: View>: View {
    private let label: String
    private let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .kerning(1.2)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .padding(.leading, 4)

            content
        }
    }
}

struct AuthActionButton: View {
    private let title: String
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void

    init(title: String, isLoading: Bool, isDisabled: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Gradient.accent)
                if isLoading {
                    ProgressView()
                        .tint(Color.citizen.white)
                } else {
                    Text(title)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.white)
                }
            }
            .frame(height: 54)
            .opacity(isDisabled ? 0.6 : 1)
        }
        .disabled(isDisabled)
    }
}

struct AuthAppleButton: View {
    private let title: String
    private let isDisabled: Bool
    private let action: () -> Void

    init(title: String, isDisabled: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image.system.appleLogo
                    .font(.headline)
                Text(title)
                    .font(.headline)
                    .fontDesign(.rounded)
            }
            .foregroundStyle(Color.citizen.background)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.citizen.mainText)
            }
        }
        .disabled(isDisabled)
    }
}

struct AuthDivider: View {
    private let text: String

    init(text: String) {
        self.text = text
    }

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.citizen.secondaryText.opacity(0.25))
                .frame(height: 1)
            Text(text)
                .font(.footnote)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
            Rectangle()
                .fill(Color.citizen.secondaryText.opacity(0.25))
                .frame(height: 1)
        }
    }

    private var line: some View {
        Rectangle()
            .fill(Color.citizen.secondaryText.opacity(0.25))
            .frame(height: 1)
    }
}

struct AuthFooterButton: View {
    private let prompt: String
    private let highlight: String
    private let isDisabled: Bool
    private let action: () -> Void

    init(prompt: String, highlight: String, isDisabled: Bool, action: @escaping () -> Void) {
        self.prompt = prompt
        self.highlight = highlight
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(prompt)
                    .foregroundStyle(Color.citizen.secondaryText)
                Text(highlight)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.accent)
            }
            .font(.footnote)
            .fontDesign(.rounded)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
        }
        .disabled(isDisabled)
    }
}

struct AuthErrorText: View {
    private let message: String?

    init(message: String?) {
        self.message = message
    }

    var body: some View {
        if let message {
            Text(message)
                .font(.footnote)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.redDark)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
        }
    }
}
