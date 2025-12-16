//
//  SupabaseManager+Physio.swift
//  FITGET
//

import Foundation
import Supabase

extension SupabaseManager {

    func configurePhysioBackend() {
        let service = PhysioRemoteService.shared

        // MARK: - Programs

        service.fetchProgramsImpl = { bodyArea in

            if let bodyArea {
                let rows: [PhysioProgram] = try await self.client
                    .from("physio_programs")
                    .select()
                    .filter("body_area", operator: "eq", value: bodyArea)
                    .order("phase", ascending: true)
                    .order("created_at", ascending: true)
                    .execute()
                    .value

                return rows
            } else {
                let rows: [PhysioProgram] = try await self.client
                    .from("physio_programs")
                    .select()
                    .order("phase", ascending: true)
                    .order("created_at", ascending: true)
                    .execute()
                    .value

                return rows
            }
        }

        // MARK: - Exercises for Program

        service.fetchExercisesForProgramImpl = { programId in

            struct ProgramExerciseRow: Decodable {
                let exercise: PhysioExercise
            }

            let rows: [ProgramExerciseRow] = try await self.client
                .from("physio_program_exercises")
                .select(
                    """
                    exercise:physio_exercises (
                        id,
                        name_en,
                        name_ar,
                        body_area,
                        stage,
                        video_url,
                        instructions_en,
                        instructions_ar,
                        precautions_en,
                        precautions_ar,
                        difficulty
                    )
                    """
                )
                .filter("program_id", operator: "eq", value: programId.uuidString)
                .order("order", ascending: true)
                .execute()
                .value

            return rows.map { $0.exercise }
        }

        // MARK: - Pain Logs

        service.fetchPainLogsImpl = { userId, programId in
            let rows: [PhysioPainLog] = try await self.client
                .from("physio_pain_logs")
                .select()
                .filter("user_id", operator: "eq", value: userId.uuidString)
                .filter("program_id", operator: "eq", value: programId.uuidString)
                .order("logged_at", ascending: false)
                .execute()
                .value

            return rows
        }

        service.savePainLogImpl = { log in
            try await self.client
                .from("physio_pain_logs")
                .insert(log)
                .execute()
        }
    }
}
