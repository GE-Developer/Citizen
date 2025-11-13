//
//  CustomPage.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomPage<Title: View, Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var tabBarState: TabBarState
    
    @ViewBuilder private let titleHStackView: () -> Title
    @ViewBuilder private let content: () -> Content
    
    init(
        @ViewBuilder titleHStackView: @escaping () -> Title,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.titleHStackView = titleHStackView
        self.content = content
    }
    
    var body: some View {
        customPage
            .onAppear { tabBarState.isVisible = false }
    }
}

extension CustomPage {
    private var customPage: some View {
        ZStack(alignment: .top) {
            Color.citizen.background
                .ignoresSafeArea()
            VStack(spacing: 0) {
                navigationBar
                content()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    @ViewBuilder
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image.system.back
                .fontWeight(.semibold)
                .foregroundStyle(Color.citizen.blackAndWhite)
                .padding(.leading, 8)
                .frame(width: 50, height: 50)
        }
    }
    
    private var navigationBar: some View {
        HStack {
            backButton
            titleHStackView()
        }
        .padding(.trailing, 14)
        .frame(height: 50)
    }
}
