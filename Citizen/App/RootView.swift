//
//  RootView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct RootView: View {
    @State private var loader = AppDataLoader.shared
    
    private let loadDataErrorTitle = "Couldn't load data"
    private let retryTitle = "Retry"
    
    var body: some View {
        content
            .dynamicTypeSize(.large)
            .task { await loader.start() }
    }
}

// MARK: - Builder
extension RootView {
    @ViewBuilder
    private var content: some View {
        switch loader.phase {
        case .loading:
            loading
        case .ready:
            HomeView()
        case .failed:
            failed
        }
    }
    
    private var loading: some View {
        ProgressView()
            .controlSize(.large)
            .tint(Color.citizen.accent)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.citizen.background.ignoresSafeArea())
    }
    
    private var failed: some View {
        VStack(spacing: 16) {
            Text(loadDataErrorTitle)
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
            Button(retryTitle) { retry() }
                .font(.body)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.citizen.background.ignoresSafeArea())
    }
}

// MARK: - Logic
extension RootView {
    private func retry() {
        Task { await loader.start() }
    }
}
