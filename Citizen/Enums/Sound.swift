//
//  Sound.swift
//  Citizen
//
//  Created by GE-Developer
//

enum Sound {
    case someSound
    
    var name: String {
        switch self {
        case .someSound: return "some sound"
        }
    }
}
