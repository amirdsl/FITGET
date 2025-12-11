//
//  WorkoutModels.swift
//  FITGET
//

import Foundation

// MARK: - Muscle group

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case upperBody  = "upper_body"
    case lowerBody  = "lower_body"
    case fullBody   = "full_body"

    // مجموعات إضافية لو حبيّت تستعملها في الفلترة أو العرض
    case chest      = "chest"
    case back       = "back"
    case shoulders  = "shoulders"
    case arms       = "arms"
    case legs       = "legs"
    case core       = "core"

    var id: String { rawValue }

    func displayName(isArabic: Bool) -> String {
        switch self {
        case .upperBody:
            return isArabic ? "الجزء العلوي" : "Upper body"
        case .lowerBody:
            return isArabic ? "الجزء السفلي" : "Lower body"
        case .fullBody:
            return isArabic ? "جسم كامل" : "Full body"
        case .chest:
            return isArabic ? "الصدر" : "Chest"
        case .back:
            return isArabic ? "الظهر" : "Back"
        case .shoulders:
            return isArabic ? "الكتف" : "Shoulders"
        case .arms:
            return isArabic ? "الذراع" : "Arms"
        case .legs:
            return isArabic ? "الأرجل" : "Legs"
        case .core:
            return isArabic ? "الوسط / الكور" : "Core"
        }
    }

    var systemIcon: String {
        switch self {
        case .upperBody: return "figure.strengthtraining.traditional"
        case .lowerBody: return "figure.walk"
        case .fullBody:  return "figure.highintensity.intervaltraining"
        case .chest:     return "heart.fill"
        case .back:      return "rectangle.portrait"
        case .shoulders: return "square.split.2x2"
        case .arms:      return "hand.raised.fill"
        case .legs:      return "figure.run"
        case .core:      return "circle.dashed"
        }
    }
}

// MARK: - Exercise

struct WorkoutExercise: Identifiable, Codable, Equatable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let primaryMuscle: String
    let muscleGroup: MuscleGroup
    let equipment: String          // bodyweight / dumbbell / ...
    let difficulty: String         // beginner / intermediate / advanced
    let defaultXp: Int
    let videoUrl: String?
    let instructionsEn: String?
    let instructionsAr: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case nameEn         = "name_en"
        case nameAr         = "name_ar"
        case primaryMuscle  = "primary_muscle"
        case muscleGroup    = "muscle_group"
        case equipment
        case difficulty
        case defaultXp      = "default_xp"
        case videoUrl       = "video_url"
        case instructionsEn = "instructions_en"
        case instructionsAr = "instructions_ar"
        case createdAt      = "created_at"
    }

    // اسم موحّد للاستخدام في الشاشات القديمة
    var displayName: String {
        let ar = nameAr.trimmingCharacters(in: .whitespacesAndNewlines)
        let en = nameEn.trimmingCharacters(in: .whitespacesAndNewlines)
        if Locale.current.language.languageCode?.identifier == "ar" {
            return ar.isEmpty ? en : ar
        } else {
            return en.isEmpty ? ar : en
        }
    }

    // ✅ خصائص توافقية مع الكود القديم
    var defaultXP: Int { defaultXp }            // للكود الذي يستخدم defaultXP
    var muscleGroupEnum: MuscleGroup { muscleGroup } // للكود الذي يستخدم muscleGroupEnum

    // تمرين تجريبي للـ previews
    static let demo = WorkoutExercise(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        nameEn: "Push-up",
        nameAr: "تمرين الضغط",
        primaryMuscle: "Chest",
        muscleGroup: .upperBody,
        equipment: "bodyweight",
        difficulty: "beginner",
        defaultXp: 60,
        videoUrl: nil,
        instructionsEn: "Keep your body in a straight line from head to heels, lower your chest toward the floor then push back up.",
        instructionsAr: "حافظ على جسمك في خط مستقيم من الرأس إلى الكعبين، انزل بالصدر باتجاه الأرض ثم ادفع لأعلى.",
        createdAt: nil
    )
}

// MARK: - Program (جلسة تمرين)

struct WorkoutProgram: Identifiable, Codable, Equatable {
    let id: UUID
    let titleEn: String
    let titleAr: String
    let focus: String       // full_body / upper_body / ...
    let level: String       // beginner / intermediate / advanced
    let durationMinutes: Int
    let xpReward: Int
    let calories: Int
    let isFeatured: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case titleEn         = "title_en"
        case titleAr         = "title_ar"
        case focus
        case level
        case durationMinutes = "duration_minutes"
        case xpReward        = "xp_reward"
        case calories
        case isFeatured      = "is_featured"
        case createdAt       = "created_at"
    }
}

// MARK: - Program ↔ Exercises mapping

struct WorkoutProgramExercise: Identifiable, Codable, Equatable {
    let id: UUID
    let programId: UUID
    let exerciseId: UUID
    let orderIndex: Int
    let sets: Int?
    let reps: Int?
    let restSeconds: Int?
    let xpReward: Int?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case programId   = "program_id"
        case exerciseId  = "exercise_id"
        case orderIndex  = "order_index"
        case sets
        case reps
        case restSeconds = "rest_seconds"
        case xpReward    = "xp_reward"
        case createdAt   = "created_at"
    }
}
