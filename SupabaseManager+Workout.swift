//
//  SupabaseManager+Workout.swift
//  FITGET
//

import Foundation
import Supabase

extension SupabaseManager {

    func configureWorkoutBackend() {

        let service = WorkoutRemoteService.shared

        // MARK: - Fetch Exercises

        service.fetchExercisesImpl = { [weak self] in
            guard let self else { return [] }

            let rows: [WorkoutExercise] = try await self
                .from("workout_exercises")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            return rows
        }

        // MARK: - Not used yet

        service.fetchProgramsImpl = nil
        service.fetchProgramExercisesImpl = nil
    }
}
