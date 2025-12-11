// FILE: PhysioModels.swift

import Foundation

// MARK: - Physio Program

struct PhysioProgram: Identifiable, Codable, Equatable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let bodyArea: String          // "knee" / "shoulder" / "back" ...
    let phase: Int
    let difficulty: String?
    let isPreventive: Bool
    let descriptionEn: String?
    let descriptionAr: String?
    let durationWeeks: Int
    let sessionsPerWeek: Int
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case nameEn          = "name_en"
        case nameAr          = "name_ar"
        case bodyArea        = "body_area"
        case phase
        case difficulty
        case isPreventive    = "is_preventive"
        case descriptionEn   = "description_en"
        case descriptionAr   = "description_ar"
        case durationWeeks   = "duration_weeks"
        case sessionsPerWeek = "sessions_per_week"
        case isActive        = "is_active"
    }
}

// MARK: - Physio Exercise

struct PhysioExercise: Identifiable, Codable, Equatable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let bodyArea: String          // "knee" / "shoulder" / "back" ...

    // خصائص إضافية اختيارية (لو كانت موجودة في الجدول)
    let stage: String?
    let videoURL: String?
    let instructionsEn: String?
    let instructionsAr: String?
    let precautionsEn: String?
    let precautionsAr: String?
    let difficulty: String?

    enum CodingKeys: String, CodingKey {
        case id
        case nameEn         = "name_en"
        case nameAr         = "name_ar"
        case bodyArea       = "body_area"
        case stage
        case videoURL       = "video_url"
        case instructionsEn = "instructions_en"
        case instructionsAr = "instructions_ar"
        case precautionsEn  = "precautions_en"
        case precautionsAr  = "precautions_ar"
        case difficulty
    }
}

// MARK: - Link table: physio_program_exercises

struct PhysioProgramExercise: Identifiable, Codable, Equatable {
    let id: UUID
    let programId: UUID
    let exerciseId: UUID
    let orderIndex: Int
    let sets: Int?
    let reps: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case programId   = "program_id"
        case exerciseId  = "exercise_id"
        case orderIndex  = "order"
        case sets
        case reps
    }
}

// MARK: - Pain logs (physio_pain_logs)

struct PhysioPainLog: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let bodyArea: String          // "knee" / "shoulder" / "back" ...
    let value: Int                // 0–10
    let programId: UUID?
    let loggedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId    = "user_id"
        case bodyArea  = "body_area"
        case value
        case programId = "program_id"
        case loggedAt  = "logged_at"
    }
}
