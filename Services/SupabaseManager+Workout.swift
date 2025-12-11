//
//  SupabaseManager+Workout.swift
//  FITGET
//
//  Path: FITGET/Services/SupabaseManager+Workout.swift
//

import Foundation
import Supabase

extension SupabaseManager {

    func configureWorkoutBackend() {
        let service = WorkoutRemoteService.shared

        // ✅ جلب جميع التمارين من جدول workout_exercises
        service.fetchExercisesImpl = {
            let rows: [WorkoutExercise] = try await self.database
                .from("workout_exercises")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            return rows
        }

        // حالياً لا نستخدم البرامج، نتركها nil
        service.fetchProgramsImpl = nil
        service.fetchProgramExercisesImpl = nil
    }
}
