//
//  ProgressService.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import Supabase

struct ProgressService: Sendable {
    static let shared = ProgressService()
    
    private let client = SupabaseService.client
    
    private init() {}
    
    func fetchUpdatedAt(userID: UUID) async throws -> String? {
        let response = try await client
            .from("profiles")
            .select("progress_updated_at")
            .eq("id", value: userID)
            .execute()
        
        let rows = try JSONDecoder()
            .decode([TokenRow].self, from: response.data)
        
        return rows.first?.updatedAt ?? nil
    }
    
    func fetchSnapshot(userID: UUID) async throws -> ServerProgress? {
        let response = try await client
            .from("profiles")
            .select("progress_data,progress_updated_at")
            .eq("id", value: userID)
            .execute()
        
        let raw = response.data
        let decoder = JSONDecoder()
        
        let tokenRows = try decoder
            .decode([TokenRow].self, from: raw)
        guard let token = tokenRows.first?.updatedAt ?? nil else { return nil }
        
        if let rows = try? decoder.decode([SnapshotRow].self, from: raw),
           let snapshot = rows.first?.progressData {
            
            guard snapshot.schemaVersion <= ProgressSnapshot.currentSchemaVersion else {
                return ServerProgress(
                    updatedAt: token,
                    payload: .newerSchema(snapshot.schemaVersion)
                )
            }
            
            return ServerProgress(updatedAt: token, payload: .snapshot(snapshot))
        }
        
        if let rows = try? decoder.decode([VersionProbeRow].self, from: raw),
           let version = rows.first?.progressData?.schemaVersion,
           version > ProgressSnapshot.currentSchemaVersion {
            return ServerProgress(updatedAt: token, payload: .newerSchema(version))
        }
        
        let snippet = String(data: raw, encoding: .utf8)?.prefix(400) ?? "<binary>"
        print("[ProgressService] progress_data undecodable — raw row: \(snippet)")
        
        return ServerProgress(updatedAt: token, payload: .corrupt)
    }
    
    func push(userID: UUID, snapshot: ProgressSnapshot, clientUpdatedAt: Date) async throws -> String {
        let dto = ProgressUpsertDTO(
            id: userID,
            progressData: snapshot,
            progressUpdatedAt: clientUpdatedAt
        )
        
        let response = try await client
            .from("profiles")
            .upsert(dto, onConflict: "id")
            .select("progress_updated_at")
            .single()
            .execute()
        
        let row = try JSONDecoder()
            .decode(TokenRow.self, from: response.data)
        
        guard let token = row.updatedAt else {
            throw URLError(.cannotParseResponse)
        }
        
        return token
    }
}

// MARK: - Row DTOs
private struct TokenRow: Decodable {
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case updatedAt = "progress_updated_at"
    }
}

private struct SnapshotRow: Decodable {
    let progressData: ProgressSnapshot
    
    enum CodingKeys: String, CodingKey {
        case progressData = "progress_data"
    }
}

private struct VersionProbeRow: Decodable {
    struct VersionProbe: Decodable {
        let schemaVersion: Int?
    }
    
    let progressData: VersionProbe?
    
    enum CodingKeys: String, CodingKey {
        case progressData = "progress_data"
    }
}

private struct ProgressUpsertDTO: Encodable {
    let id: UUID
    let progressData: ProgressSnapshot
    let progressUpdatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case progressData = "progress_data"
        case progressUpdatedAt = "progress_updated_at"
    }
}
