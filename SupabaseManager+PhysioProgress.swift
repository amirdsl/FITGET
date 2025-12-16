import Foundation
import Supabase

extension SupabaseManager {

    // تسجيل جلسة تأهيل مكتملة
    func completePhysioSession(
        userId: UUID,
        programId: UUID,
        sessionIndex: Int
    ) async throws {

        struct Payload: Encodable {
            let user_id: UUID
            let program_id: UUID
            let session_index: Int
        }

        let payload = Payload(
            user_id: userId,
            program_id: programId,
            session_index: sessionIndex
        )

        try await client
            .from("physio_sessions")
            .insert(payload)
            .execute()
    }

    // جلب الجلسات المكتملة
    func fetchCompletedPhysioSessions(
        userId: UUID,
        programId: UUID
    ) async throws -> [PhysioSession] {

        let rows: [PhysioSession] = try await client
            .from("physio_sessions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("program_id", value: programId.uuidString)
            .order("session_index", ascending: true)
            .execute()
            .value

        return rows
    }
}
