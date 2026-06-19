//
//  AccentColor.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

enum AccentColor: String, CaseIterable, Identifiable {
    case georgian
    case midnightBlue
    case solarFlare
    case neonLime
    case victoria
    case caramelRoast
    case arcticCyan
    case cosmicPurple
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .georgian: "Georgian"
        case .midnightBlue: "Midnight Blue"
        case .solarFlare: "Solar Flare"
        case .neonLime: "Neon Lime"
        case .victoria: "Victoria"
        case .caramelRoast: "Caramel Roast"
        case .arcticCyan: "Arctic Cyan"
        case .cosmicPurple: "Cosmic Purple"
        }
    }
    
    var color: Color {
        switch self {
        case .georgian:
            Color("Georgian (Accent)")
        case .midnightBlue:
            Color("Midnight Blue (Accent)")
        case .solarFlare:
            Color("Solar Flare (Accent)")
        case .neonLime:
            Color("Neon Lime (Accent)")
        case .victoria:
            Color("Victoria (Accent)")
        case .caramelRoast:
            Color("Caramel Roast (Accent)")
        case .arcticCyan:
            Color("Arctic Cyan (Accent)")
        case .cosmicPurple:
            Color("Cosmic Purple (Accent)")
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .georgian:
            LinearGradient(
                colors: [
                    Color("Georgian (Accent)"),
                    Color("Georgian (Accent Gradient)")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .midnightBlue:
            LinearGradient(
                colors: [
                    Color("Midnight Blue (Accent Gradient)"),
                    Color("Midnight Blue (Accent)")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .solarFlare:
            LinearGradient(
                colors: [
                    Color("Solar Flare (Accent Gradient)"),
                    Color("Solar Flare (Accent)")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .neonLime:
            LinearGradient(
                colors: [
                    Color("Neon Lime (Accent Gradient)"),
                    Color("Neon Lime (Accent)")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .victoria:
            LinearGradient(
                colors: [
                    Color("Victoria (Accent Gradient)"),
                    Color("Victoria (Accent)")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .caramelRoast:
            LinearGradient(
                colors: [
                    Color("Caramel Roast (Accent Gradient)"),
                    Color("Caramel Roast (Accent)")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .arcticCyan:
            LinearGradient(
                colors: [
                    Color("Arctic Cyan (Accent Gradient)"),
                    Color("Arctic Cyan (Accent)")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .cosmicPurple:
            LinearGradient(
                colors: [
                    Color("Cosmic Purple (Accent Gradient)"),
                    Color("Cosmic Purple (Accent)")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var requiresPremium: Bool {
        switch self {
        case .georgian:
            false
        default:
            true
        }
    }
}
