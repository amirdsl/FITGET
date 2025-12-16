//
//  SupabaseManager+PhysioSmart.swift
//  FITGET
//

import Foundation
import Supabase

extension SupabaseManager {

    // MARK: - Smart Program Suggestion

    func fetchSmartPhysioProgram(
        bodyArea: String,
        difficulty: String?
    ) async throws -> PhysioProgram {

        if let difficulty {
            let rows: [PhysioProgram] = try await client
                .rpc(
                    "get_physio_program",
                    params: [
                        "p_body_area": bodyArea,
                        "p_difficulty": difficulty
                    ]
                )
                .execute()
                .value

            if let program = rows.first {
                return program
            }
        }

        // fallback
        let fallback: [PhysioProgram] = try await client
            .rpc(
                "get_best_physio_program",
                params: [
                    "p_body_area": bodyArea
                ]
            )
            .execute()
            .value

        guard let program = fallback.first else {
            throw URLError(.badServerResponse)
        }

        return program
    }
}
