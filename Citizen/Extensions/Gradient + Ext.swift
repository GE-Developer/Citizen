//
//  Gradient + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension Gradient {
    static var accent: LinearGradient {
        AccentColorManager.shared.currentColor.gradient
    }
    
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
    
    static let neutral = LinearGradient(
        colors: [.citizen.groupBackground],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static func phase(_ phase: TopicPhase) -> LinearGradient {
        switch phase {
        case .completed:         Gradient.green
        case .notStarted:        Gradient.gray
        case .workingOnMistakes: Gradient.red
        case .inProgress:        Gradient.yellow
        }
    }
    
    static func progress(_ progress: Double) -> LinearGradient {
        if progress == 1   { return Gradient.green }
        if progress > 0.3  { return Gradient.yellow }
        if progress > 0    { return Gradient.red }
        return Gradient.gray
    }
}
