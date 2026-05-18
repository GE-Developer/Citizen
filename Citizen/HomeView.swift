//
//  HomeView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    @StateObject private var tabBarState = TabBarState()
    @StateObject private var store = StoreManager()
    
//    private let accent = AccentColorManager.shared
//    private let screenshotProtector = ScreenshotManager.shared
    
    var body: some View {
        TabView(selection: $tabBarState.selectedTab) {
            NavigationStack {
                LearnView()
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(TabBarState.RootTab.home)

            NavigationStack {
                SettingsView()
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(TabBarState.RootTab.settings)
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBar()
        }
//        .task { setAccentColorIfPremiumExpired() }
//        .task { await setIconIfPremiumExpired() }
//        .task { setCaptureProtectionIfPremiumExpired() }
        .preferredColorScheme(ThemeManager.shared.theme)
//        .screenshotDisabled(screenshotProtector.isScreenshotProtectionOn)
        .environmentObject(tabBarState)
        .environmentObject(store)
    }
    
//    private func setAccentColorIfPremiumExpired() {
//        guard !store.isPremium else { return }
//        if accent.currentColor != .midnightBlue {
//            accent.currentColor = .midnightBlue
//        }
//    }
    
//    private func setIconIfPremiumExpired() async {
//        guard !store.isPremium else { return }
//        if AppIconManager.currentIcon() != .blackVoid {
//            do {
//                try await Task.sleep(for: .milliseconds(600))
//                try await AppIconManager.setIcon(.blackVoid)
//            } catch {
//                return
//            }
//        }
//    }
//    
//    private func setCaptureProtectionIfPremiumExpired() {
//        guard !store.isPremium else { return }
//        if screenshotProtector.isScreenshotProtectionOn {
//            screenshotProtector.isScreenshotProtectionOn = false
//        }
//    }
}
