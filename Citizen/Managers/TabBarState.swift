//
//  TabBarState.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUICore

final class TabBarState: ObservableObject {
    @Published var isVisible: Bool = true
    @Published var selectedTab: RootTab = .test
    
    let height: CGFloat = 65
    
    enum RootTab: Int, CaseIterable, Identifiable {
        case alphabet
        case test
        case exam
        case settings
        
        var id: Int { rawValue }
    }
}
