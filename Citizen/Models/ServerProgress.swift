//
//  ServerProgress.swift
//  Citizen
//
//  Created by GE-Developer
//

struct ServerProgress: Sendable {
    enum Payload: Sendable {
        case snapshot(ProgressSnapshot)
        case newerSchema(Int)
        case corrupt
    }
    
    let updatedAt: String
    let payload: Payload
}
