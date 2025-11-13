//
//  HomeView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct HomeView: View {
    @StateObject private var tabBarState = TabBarState()
    @StateObject private var store = StoreManager()
    
    var body: some View {
        Group {
            switch tabBarState.selectedTab {
            case .alphabet:
                NavigationStack {
                    SettingsView()
                }
            case .test:
                NavigationStack {
                    CourcesView()
                }
            case .exam:
                NavigationStack {
                    SettingsView()
                }
            case .settings:
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .safeAreaInset(edge: .bottom) { CustomTabBar() }
        .environmentObject(tabBarState)
        .environmentObject(store)
    }
}
