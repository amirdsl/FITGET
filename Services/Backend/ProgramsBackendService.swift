//  ProgramsBackendService.swift
//  FITGET
//
//  خدمة مجردة لربط شاشة مكتبة البرامج بجدول workout_programs.
//  استخدمنا RemoteWorkoutProgram / ProgramsRemoteService لتفادي أي تعارض مع كود قديم.
//

import Foundation

struct RemoteWorkoutProgram: Identifiable, Codable, Equatable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let subtitleEn: String?
    let subtitleAr: String?
    let durationWeeks: Int?
    let daysPerWeek: Int?
    let difficulty: String
    let goal: String?
    let environment: String?
    let xpPerSession: Int?
    let isPremium: Bool
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case nameEn        = "name_en"
        case nameAr        = "name_ar"
        case subtitleEn    = "subtitle_en"
        case subtitleAr    = "subtitle_ar"
        case durationWeeks = "duration_weeks"
        case daysPerWeek   = "days_per_week"
        case difficulty
        case goal
        case environment
        case xpPerSession  = "xp_per_session"
        case isPremium     = "is_premium"
        case tags
    }
}

enum ProgramsRemoteError: Error {
    case notConfigured
}

final class ProgramsRemoteService {

    static let shared = ProgramsRemoteService()
    private init() {}

    /// closure يتم حقنها من SupabaseManager لاحقاً
    var fetchProgramsImpl: (() async throws -> [RemoteWorkoutProgram])?

    func fetchPrograms() async throws -> [RemoteWorkoutProgram] {
        guard let impl = fetchProgramsImpl else {
            throw ProgramsRemoteError.notConfigured
        }
        return try await impl()
    }
}
