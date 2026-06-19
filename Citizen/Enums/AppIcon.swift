//
//  AppIcon.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AppIcon: CaseIterable, Identifiable {
    case blackVoid
    case ghostWhite
    case cyberGold
    case titanium
    case neonPinky
    case desertForge
    
    var id: String {
        switch self {
        case .blackVoid:
            return "BlackVoid"
        case .ghostWhite:
            return "GhostWhite"
        case .cyberGold:
            return "CyberGold"
        case .titanium:
            return "Titanium"
        case .neonPinky:
            return "NeonPinky"
        case .desertForge:
            return "DesertForge"
        }
    }
    
    var appIconid: String? {
        switch self {
        case .blackVoid:
            return nil
        case .ghostWhite:
            return "GhostWhite"
        case .cyberGold:
            return "CyberGold"
        case .titanium:
            return "Titanium"
        case .neonPinky:
            return "NeonPinky"
        case .desertForge:
            return "DesertForge"
        }
    }
    
    var title: String {
        switch self {
        case .blackVoid:
            return "Black VOID"
        case .ghostWhite:
            return "Ghost White"
        case .cyberGold:
            return "Cyber Gold"
        case .titanium:
            return "Titanium"
        case .neonPinky:
            return "Neon Pinky"
        case .desertForge:
            return "Desert Forge"
        }
    }
    
    static var premiumIcons: [AppIcon] {
        allCases.filter { $0 != .blackVoid }
    }
}
