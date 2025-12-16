import Foundation
import PostgREST

extension PhysioRemoteService {

    /// يجب استدعاؤها مرة واحدة عند تشغيل التطبيق
    static func configureWithSupabase() {
        let service = PhysioRemoteService.shared
        let supabase = SupabaseManager.shared

        // MARK: - Programs

        service.fetchProgramsImpl = { bodyArea in
            var query = supabase
                .from("physio_programs")
                .select()
                .eq("is_active", value: true)

            if let bodyArea {
                query = query.eq("body_area", value: bodyArea)
            }

            let response = try await query.execute()
            let data = response.data

            return try JSONDecoder().decode([PhysioProgram].self, from: data)
        }

        // MARK: - Exercises per program

        service.fetchExercisesForProgramImpl = { programId in
            let response = try await supabase
                .from("physio_program_exercises")
                .select("""
                    id,
                    order,
                    sets,
                    reps,
                    physio_exercises (
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
                """)
                .eq("program_id", value: programId.uuidString)
                .order("order", ascending: true)
                .execute()

            struct Row: Codable {
                let physio_exercises: PhysioExercise
            }

            let rows = try JSONDecoder().decode([Row].self, from: response.data)
            return rows.map { $0.physio_exercises }
        }

        // MARK: - Pain logs

        service.fetchPainLogsImpl = { userId, programId in
            let response = try await supabase
                .from("physio_pain_logs")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("program_id", value: programId.uuidString)
                .order("logged_at", ascending: false)
                .execute()

            return try JSONDecoder().decode([PhysioPainLog].self, from: response.data)
        }

        service.savePainLogImpl = { log in
            try await supabase
                .from("physio_pain_logs")
                .insert(log)
                .execute()
        }
    }
}
