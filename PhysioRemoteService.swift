// FILE: PhysioRemoteService.swift

import Foundation
import Combine

@MainActor
final class PhysioRemoteService: ObservableObject {

    static let shared = PhysioRemoteService()
    private init() {}

    // MARK: - Closures (تُحقن من SupabaseManager+Physio)

    var fetchProgramsImpl: ((String?) async throws -> [PhysioProgram])?
    var fetchExercisesForProgramImpl: ((UUID) async throws -> [PhysioExercise])?
    var fetchPainLogsImpl: ((UUID, UUID) async throws -> [PhysioPainLog])? // (userId, programId)
    var savePainLogImpl: ((PhysioPainLog) async throws -> Void)?

    // MARK: - Published state

    @Published var programs: [PhysioProgram] = []
    /// key = programId
    @Published var exercisesByProgram: [UUID: [PhysioExercise]] = [:]
    /// آخر سجلات ألم محملة (لبرنامج معيّن)
    @Published var painLogs: [PhysioPainLog] = []

    @Published var isLoading: Bool = false
    @Published var lastError: String?

    // MARK: - Programs

    func loadPrograms(bodyArea: String? = nil) async {
        isLoading = true
        defer { isLoading = false }

        guard let impl = fetchProgramsImpl else {
            lastError = "Physio backend not configured."
            return
        }

        do {
            let result = try await impl(bodyArea)
            programs = result
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: - Exercises

    func loadExercises(for programId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        guard let impl = fetchExercisesForProgramImpl else {
            lastError = "Physio backend not configured."
            return
        }

        do {
            let result = try await impl(programId)
            exercisesByProgram[programId] = result
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: - Pain logs

    func loadPainLogs(userId: UUID, programId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        guard let impl = fetchPainLogsImpl else {
            lastError = "Physio pain backend not configured."
            return
        }

        do {
            let result = try await impl(userId, programId)
            painLogs = result
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func savePainLog(_ log: PhysioPainLog, userId: UUID, programId: UUID) async {
        guard let impl = savePainLogImpl else {
            lastError = "Physio pain backend not configured."
            return
        }

        do {
            try await impl(log)
            // إعادة التحميل بعد الحفظ
            await loadPainLogs(userId: userId, programId: programId)
        } catch {
            lastError = error.localizedDescription
        }
    }
}
