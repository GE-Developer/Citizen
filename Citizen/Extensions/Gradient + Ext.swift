//
//  Gradient + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension Gradient {
    static let accent = LinearGradient(
        colors: [.citizen.accentLight, .citizen.accentDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let gray = LinearGradient(
        colors: [.citizen.grayLight, .citizen.grayDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let gold = LinearGradient(
        colors: [.citizen.goldLight, .citizen.goldDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let green = LinearGradient(
        colors: [.citizen.greenLight, .citizen.greenDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let yellow = LinearGradient(
        colors: [.citizen.yellowLight, .citizen.yellowDark],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let red = LinearGradient(
        colors: [.citizen.redLight, .citizen.redDark],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let white = LinearGradient(
        colors: [.white, .white],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let payWallAccent = LinearGradient(
        colors: [.citizen.payWallAccentLight, .citizen.payWallAccentDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static func phase(_ phase: TopicPhase) -> LinearGradient {
        switch phase {
        case .completed:         Gradient.green
        case .notStarted:        Gradient.gray
        case .workingOnMistakes: Gradient.red
        case .inProgress:        Gradient.yellow
        }
    }
}
