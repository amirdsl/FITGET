//
//  Profile.swift
//  FITGET
//
//  Created on 21/11/2025.
//  ✅ نسخة متوافقة مع Supabase ومرنة للمستقبل
//

import Foundation

struct Profile: Identifiable, Codable {

    // الحقل الأساسي من Supabase (auth.users.id)
    let id: UUID

    // معلومات أساسية
    var email: String?
    var fullName: String?
    var username: String?
    /// user / trainer / admin (مربوطة بحقل role في الجدول)
    var userType: String?

    var gender: String?
    var age: Int?

    /// الطول بالسنتيمتر (height_cm في Supabase)
    var height: Double?
    /// الوزن بالكيلو (weight_kg في Supabase)
    var weight: Double?

    /// هدف المستخدم (bulk / cut / maintain ...) – اختياري في البداية
    var goal: String?
    /// مستوى اللياقة (beginner / intermediate / advanced) – اختياري
    var fitnessLevel: String?

    /// نقاط الخبرة (xp في Supabase)
    var experiencePoints: Int?
    /// مستوى اللاعب
    var level: Int?
    /// رصيد العملات (coins في Supabase)
    var coins: Int?
    /// عدد أيام الاستمرارية (streak_days في Supabase)
    var streakDays: Int?

    /// تواريخ الإنشاء والتحديث – ليست ضرورية دائمًا
    var createdAt: Date?
    var updatedAt: Date?

    // حقول اختيارية إضافية
    var avatarUrl: String?
    var bio: String?
    var trainingDaysPerWeek: Int?
    /// gym / home / both
    var trainingLocation: String?
    /// full / minimal / bodyweight
    var equipment: String?
    /// normal / keto / vegan / vegetarian ...
    var dietType: String?
    var injuries: String?
    var targetWeight: Double?
    var trainerCode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case gender
        case age
        case goal
        case fitnessLevel = "fitness_level"
        case coins
        case bio
        case injuries
        case targetWeight = "target_weight"
        case trainerCode = "trainer_code"

        case fullName = "full_name"
        case username = "username"
        /// في Supabase الجدول اسمه role → نربطه هنا بـ userType
        case userType = "role"

        /// الأعمدة الخاصة بالطول والوزن في قاعدة البيانات
        case height = "height_cm"
        case weight = "weight_kg"

        /// xp في Supabase
        case experiencePoints = "xp"
        case level

        case streakDays = "streak_days"

        case createdAt = "created_at"
        case updatedAt = "updated_at"

        case avatarUrl = "avatar_url"
        case trainingDaysPerWeek = "training_days_per_week"
        case trainingLocation = "training_location"
        case equipment
        case dietType = "diet_type"
    }
}
