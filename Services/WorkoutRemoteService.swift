//
//  WorkoutRemoteService.swift
//  FITGET
//

import Foundation
import Combine

/// خدمة التمارين / البرامج – وسيط بين Supabase والـ UI
@MainActor
final class WorkoutRemoteService: ObservableObject {

    // MARK: - Singleton

    static let shared = WorkoutRemoteService()
    private init() {}

    // MARK: - Closures يتم حقنها من SupabaseManager+Workout

    /// جلب كل التمارين من Supabase
    var fetchExercisesImpl: (() async throws -> [WorkoutExercise])?

    /// جلب كل البرامج من Supabase
    var fetchProgramsImpl: (() async throws -> [WorkoutProgram])?

    /// جلب تمارين برنامج معيّن من Supabase
    var fetchProgramExercisesImpl: ((UUID) async throws -> [WorkoutProgramExercise])?

    // MARK: - Published state (تستخدم في الواجهات)

    @Published var isLoading: Bool = false
    @Published var lastError: String?

    @Published var exercises: [WorkoutExercise] = []
    @Published var programs: [WorkoutProgram] = []

    /// key = programId
    @Published var programExercises: [UUID: [WorkoutProgramExercise]] = [:]

    // MARK: - Public API

    /// تحميل مكتبة التمارين
    func loadExercises() async {
        isLoading = true
        defer { isLoading = false }

        guard let impl = fetchExercisesImpl else {
            lastError = "Workout backend not configured."
            return
        }

        do {
            let result = try await impl()
            exercises = result
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// تحميل كل برامج التمرين
    func loadPrograms() async {
        isLoading = true
        defer { isLoading = false }

        guard let impl = fetchProgramsImpl else {
            lastError = "Workout backend not configured."
            return
        }

        do {
            let result = try await impl()
            programs = result
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// تحميل تمارين برنامج واحد (وتخزينها في الـ Dictionary)
    func loadProgramExercises(for programId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        guard let impl = fetchProgramExercisesImpl else {
            lastError = "Workout backend not configured."
            return
        }

        do {
            let result = try await impl(programId)
            programExercises[programId] = result
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }
}
