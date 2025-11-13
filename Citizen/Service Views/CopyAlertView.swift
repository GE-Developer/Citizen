//
//  CopyAlertView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CopyAlertView: View {
    @State private var isActive = false
    
    var body: some View {
        copyAlertView
    }
}

// MARK: - Builder
extension CopyAlertView {
    private var copyAlertView: some View {
        HStack {
            Image.system.checkmarkInCircle()
                .foregroundStyle(isActive ? Gradient.green : Gradient.gray)
            Text(L10n("Alert.сopied"))
                .foregroundStyle(Color.citizen.secondaryText)
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(background)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onAppear {
            withAnimation(.easeIn(duration: 0.2).delay(0.2)) {
                isActive = true
            }
        }
        .onDisappear {
            isActive = false
        }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(.ultraThinMaterial)
            .shadow(color: .citizen.navBarShadow, radius: 1)
    }
}
