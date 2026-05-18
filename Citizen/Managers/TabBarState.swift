//
//  TabBarState.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUICore

final class TabBarState: ObservableObject {
    @Published var isVisible: Bool = true
    @Published var selectedTab: RootTab = .home
    
    let height: CGFloat = 65
    
    enum RootTab: Int, CaseIterable, Identifiable {
        case home
        case settings

        var id: Int { rawValue }
    }
}
