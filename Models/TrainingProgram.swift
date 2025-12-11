//
//  TrainingProgram.swift
//  Fitget
//
//  Created on 21/11/2025.
//

import Foundation

struct TrainingProgram: Identifiable, Codable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let descriptionEn: String
    let descriptionAr: String
    let category: String // strength, cardio, hybrid, calisthenics, powerlifting
    let goal: String // bulk, cut, maintain, strength, endurance
    let difficulty: String // beginner, intermediate, advanced
    let durationWeeks: Int
    let daysPerWeek: Int
    let sessionDurationMinutes: Int
    let equipment: String // full_gym, minimal, bodyweight
    let imageUrl: String?
    let createdBy: UUID? // trainer ID
    let isPremium: Bool
    let xpPerSession: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameEn = "name_en"
        case nameAr = "name_ar"
        case descriptionEn = "description_en"
        case descriptionAr = "description_ar"
        case category, goal, difficulty
        case durationWeeks = "duration_weeks"
        case daysPerWeek = "days_per_week"
        case sessionDurationMinutes = "session_duration_minutes"
        case equipment
        case imageUrl = "image_url"
        case createdBy = "created_by"
        case isPremium = "is_premium"
        case xpPerSession = "xp_per_session"
        case createdAt = "created_at"
    }
}

struct ProgramDay: Identifiable, Codable {
    let id: UUID
    let programId: UUID
    let dayNumber: Int
    let titleEn: String
    let titleAr: String
    let focusEn: String // Chest & Triceps, Back & Biceps, etc.
    let focusAr: String
    let exercises: [ProgramExercise]
    
    enum CodingKeys: String, CodingKey {
        case id
        case programId = "program_id"
        case dayNumber = "day_number"
        case titleEn = "title_en"
        case titleAr = "title_ar"
        case focusEn = "focus_en"
        case focusAr = "focus_ar"
        case exercises
    }
}

struct ProgramExercise: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    let orderIndex: Int
    let sets: Int
    let reps: String // "8-12", "15-20", "AMRAP"
    let restSeconds: Int
    let notesEn: String?
    let notesAr: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case exerciseId = "exercise_id"
        case orderIndex = "order_index"
        case sets, reps
        case restSeconds = "rest_seconds"
        case notesEn = "notes_en"
        case notesAr = "notes_ar"
    }
}

// Sample programs for testing
extension TrainingProgram {
    static let samples: [TrainingProgram] = [
        TrainingProgram(
            id: UUID(),
            nameEn: "Beginner Full Body",
            nameAr: "جسم كامل للمبتدئين",
            descriptionEn: "Perfect 3-day program for beginners focusing on compound movements and proper form.",
            descriptionAr: "برنامج مثالي لـ 3 أيام للمبتدئين يركز على التمارين المركبة والأداء الصحيح.",
            category: "strength",
            goal: "bulk",
            difficulty: "beginner",
            durationWeeks: 12,
            daysPerWeek: 3,
            sessionDurationMinutes: 60,
            equipment: "full_gym",
            imageUrl: nil,
            createdBy: nil,
            isPremium: false,
            xpPerSession: 20,
            createdAt: Date()
        ),
        TrainingProgram(
            id: UUID(),
            nameEn: "Push Pull Legs",
            nameAr: "دفع سحب أرجل",
            descriptionEn: "Advanced 6-day split for serious muscle building and strength gains.",
            descriptionAr: "تقسيم متقدم لـ 6 أيام لبناء العضلات الجادة ومكاسب القوة.",
            category: "strength",
            goal: "bulk",
            difficulty: "advanced",
            durationWeeks: 16,
            daysPerWeek: 6,
            sessionDurationMinutes: 90,
            equipment: "full_gym",
            imageUrl: nil,
            createdBy: nil,
            isPremium: true,
            xpPerSession: 35,
            createdAt: Date()
        ),
        TrainingProgram(
            id: UUID(),
            nameEn: "Home Bodyweight Circuit",
            nameAr: "دائرة وزن الجسم المنزلية",
            descriptionEn: "No equipment needed! Perfect for home workouts with minimal space.",
            descriptionAr: "لا حاجة لمعدات! مثالي للتمارين المنزلية بمساحة محدودة.",
            category: "calisthenics",
            goal: "maintain",
            difficulty: "intermediate",
            durationWeeks: 8,
            daysPerWeek: 4,
            sessionDurationMinutes: 45,
            equipment: "bodyweight",
            imageUrl: nil,
            createdBy: nil,
            isPremium: false,
            xpPerSession: 25,
            createdAt: Date()
        )
    ]
}
