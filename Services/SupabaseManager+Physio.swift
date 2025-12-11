// FILE: SupabaseManager+Physio.swift

import Foundation
import Supabase

extension SupabaseManager {

    /// استدعها مرة واحدة في بداية التطبيق (مثلاً داخل init أو app start)
    func configurePhysioBackend() {
        let service = PhysioRemoteService.shared

        // MARK: - 1) برامج التأهيل

        service.fetchProgramsImpl = { bodyArea in
            var query = self.database
                .from("physio_programs")
                .select()
                .eq("is_active", value: true)

            if let area = bodyArea, !area.isEmpty {
                query = query.eq("body_area", value: area)
            }

            let rows: [PhysioProgram] = try await query
                .order("phase", ascending: true)
                .order("created_at", ascending: true)
                .execute()
                .value

            return rows
        }

        // MARK: - 2) تمارين البرنامج (باستخدام physio_program_exercises + physio_exercises)

        service.fetchExercisesForProgramImpl = { programId in
            let links: [PhysioProgramExercise] = try await self.database
                .from("physio_program_exercises")
                .select()
                .eq("program_id", value: programId.uuidString)
                .order("order", ascending: true)
                .execute()
                .value

            var result: [PhysioExercise] = []

            for link in links {
                let rows: [PhysioExercise] = try await self.database
                    .from("physio_exercises")
                    .select()
                    .eq("id", value: link.exerciseId.uuidString)
                    .limit(1)
                    .execute()
                    .value

                if let ex = rows.first {
                    result.append(ex)
                }
            }

            return result
        }

        // MARK: - 3) سجلات الألم

        service.fetchPainLogsImpl = { userId, programId in
            let rows: [PhysioPainLog] = try await self.database
                .from("physio_pain_logs")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("program_id", value: programId.uuidString)
                .order("logged_at", ascending: false)
                .execute()
                .value

            return rows
        }

        // MARK: - 4) حفظ سجل الألم

        service.savePainLogImpl = { log in
            _ = try await self.database
                .from("physio_pain_logs")
                .upsert(log)
                .execute()
        }
    }
}
