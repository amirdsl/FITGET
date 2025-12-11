//
//  PhysioBackendService.swift
//  FITGET
//
//  واجهة مجردة لبرامج العلاج الطبيعي / التأهيل والوقاية.
//

import Foundation

// MARK: - خطأ عام للخدمة

enum PhysioBackendError: Error {
    case notConfigured
}

// MARK: - خدمة مجردة

final class PhysioBackendService {

    static let shared = PhysioBackendService()
    private init() {}

    // يتم حقنها من SupabaseManager أو أي طبقة شبكة
    var fetchProgramsImpl: (() async throws -> [PhysioProgram])?
    var fetchExercisesForProgramImpl: ((UUID) async throws -> ([PhysioProgramExercise], [PhysioExercise]))?
    var logSessionImpl: ((UUID, UUID, Int?, Int?, String?) async throws -> Void)?  // (userId, programId, painBefore, painAfter, notes)

    // Pain logs
    var fetchPainLogsImpl: ((UUID, String?, UUID?) async throws -> [PhysioPainLog])?
    var logPainImpl: ((UUID, String, Int, UUID?) async throws -> Void)? // userId, bodyArea, value, programId?

    // MARK: - واجهة عامة

    func fetchPrograms() async throws -> [PhysioProgram] {
        guard let impl = fetchProgramsImpl else {
            throw PhysioBackendError.notConfigured
        }
        return try await impl()
    }

    func fetchProgramExercises(programId: UUID) async throws -> ([PhysioProgramExercise], [PhysioExercise]) {
        guard let impl = fetchExercisesForProgramImpl else {
            throw PhysioBackendError.notConfigured
        }
        return try await impl(programId)
    }

    func logSession(
        userId: UUID,
        programId: UUID,
        painBefore: Int?,
        painAfter: Int?,
        notes: String?
    ) async throws {
        guard let impl = logSessionImpl else {
            throw PhysioBackendError.notConfigured
        }
        try await impl(userId, programId, painBefore, painAfter, notes)
    }

    // MARK: - Pain logs

    func fetchPainLogs(
        userId: UUID,
        bodyArea: String? = nil,
        programId: UUID? = nil
    ) async throws -> [PhysioPainLog] {
        guard let impl = fetchPainLogsImpl else {
            throw PhysioBackendError.notConfigured
        }
        return try await impl(userId, bodyArea, programId)
    }

    func logPain(
        userId: UUID,
        bodyArea: String,
        value: Int,
        programId: UUID? = nil
    ) async throws {
        guard let impl = logPainImpl else {
            throw PhysioBackendError.notConfigured
        }
        try await impl(userId, bodyArea, value, programId)
    }
}
