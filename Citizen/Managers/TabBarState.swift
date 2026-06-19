//
//  TabBarState.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@Observable
final class TabBarState {
    var selectedTab: RootTab = .home
    
    var isVisible: Bool {
        switch selectedTab {
        case .home:     homeDepth == 0
        case .settings: settingsDepth == 0
        }
    }
    
    private(set) var homeDepth: Int = 0
    private(set) var settingsDepth: Int = 0
    
    let height: CGFloat = 65
    
    func enterStack(for tab: RootTab) {
        switch tab {
        case .home:     homeDepth += 1
        case .settings: settingsDepth += 1
        }
    }
    
    func exitStack(for tab: RootTab) {
        switch tab {
        case .home:     homeDepth = max(0, homeDepth - 1)
        case .settings: settingsDepth = max(0, settingsDepth - 1)
        }
    }
    
    enum RootTab: Int, CaseIterable, Identifiable {
        case home
        case settings
        
        var id: Int { rawValue }
    }
}
