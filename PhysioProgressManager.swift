//
//  PhysioProgressManager.swift
//  FITGET
//

import Foundation
import Supabase

@MainActor
final class PhysioProgressManager {

    static let shared = PhysioProgressManager()
    private init() {}

    // MARK: - Start Program

    func startProgram(
        userId: UUID,
        programId: UUID,
        totalExercises: Int
    ) async {

        let params: [String: String] = [
            "user_id": userId.uuidString,
            "program_id": programId.uuidString,
            "completed_exercises": "0",
            "total_exercises": String(totalExercises)
        ]

        do {
            try await SupabaseManager.shared.client
                .rpc("update_physio_progress", params: params)
                .execute()
        } catch {
            print("❌ startProgram error:", error)
        }
    }

    // MARK: - Complete Exercise

    func completeExercise(
        userId: UUID,
        programId: UUID,
        completedExercises: Int,
        totalExercises: Int
    ) async {

        let params: [String: String] = [
            "user_id": userId.uuidString,
            "program_id": programId.uuidString,
            "completed_exercises": String(completedExercises),
            "total_exercises": String(totalExercises)
        ]

        do {
            try await SupabaseManager.shared.client
                .rpc("update_physio_progress", params: params)
                .execute()

            // ✅ Gamification – تمرين مكتمل
            PhysioGamificationBridge.shared.onExerciseCompleted()

            // ✅ برنامج مكتمل
            if completedExercises >= totalExercises {
                PhysioGamificationBridge.shared.onProgramCompleted()
            }

        } catch {
            print("❌ completeExercise error:", error)
        }
    }

    // MARK: - Reset Program

    func resetProgram(
        userId: UUID,
        programId: UUID
    ) async {

        let params: [String: String] = [
            "user_id": userId.uuidString,
            "program_id": programId.uuidString
        ]

        do {
            try await SupabaseManager.shared.client
                .rpc("reset_physio_progress", params: params)
                .execute()
        } catch {
            print("❌ resetProgram error:", error)
        }
    }
}
