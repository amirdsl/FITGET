//
//  WorkoutLogManager.swift
//  FITGET
//
//  Path: FITGET/Services/WorkoutLogManager.swift
//

import Foundation
import Supabase
import Combine

@MainActor
final class WorkoutLogManager: ObservableObject {

    static let shared = WorkoutLogManager()
    private init() {}

    private let supabase = SupabaseManager.shared

    // MARK: - Published State (future UI usage)

    @Published private(set) var lastLoggedWorkoutId: UUID?

    // MARK: - Models

    struct WorkoutLogInsert: Encodable {
        let user_id: UUID
        let program_id: UUID?
        let calories: Int?
        let duration_minutes: Int?
        let xp_earned: Int
        let completed_at: String
    }

    // MARK: - Public API

    func completeWorkout(
        userId: UUID,
        programId: UUID?,
        durationMinutes: Int,
        caloriesBurned: Int?,
        baseXP: Int
    ) async {

        let xpEarned = baseXP
        let coinsEarned = max(1, xpEarned / 10)

        await insertWorkoutLog(
            userId: userId,
            programId: programId,
            durationMinutes: durationMinutes,
            caloriesBurned: caloriesBurned,
            xpEarned: xpEarned
        )

        await PlayerProgressManager.shared.addProgress(
            userId: userId,
            xpGained: xpEarned,
            coinsGained: coinsEarned,
            didCompleteToday: true
        )
    }

    // MARK: - Insert Log

    private func insertWorkoutLog(
        userId: UUID,
        programId: UUID?,
        durationMinutes: Int,
        caloriesBurned: Int?,
        xpEarned: Int
    ) async {

        let payload = WorkoutLogInsert(
            user_id: userId,
            program_id: programId,
            calories: caloriesBurned,
            duration_minutes: durationMinutes,
            xp_earned: xpEarned,
            completed_at: ISO8601DateFormatter().string(from: Date())
        )

        do {
            _ = try await SupabaseManager.shared
                .from("workout_logs")
                .insert(payload)
                .execute()

            lastLoggedWorkoutId = programId

        } catch {
            print("Failed to insert workout log:", error)
        }
    }
}
