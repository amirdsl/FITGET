//
//  Challenge.swift
//  Fitget
//
//  Created on 21/11/2025.
//
import Combine
import Foundation

struct Challenge: Identifiable, Codable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let descriptionEn: String?
    let descriptionAr: String?
    let type: String // daily, weekly, monthly, special
    let goalType: String // steps, workouts, calories, exercise_count, water, meals
    let goalValue: Int
    let xpReward: Int
    let coinsReward: Int
    let badgeIcon: String?
    let startDate: Date
    let endDate: Date
    let isActive: Bool
    var currentProgress: Int
    var isCompleted: Bool
    let isPremium: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameEn = "name_en"
        case nameAr = "name_ar"
        case descriptionEn = "description_en"
        case descriptionAr = "description_ar"
        case type
        case goalType = "goal_type"
        case goalValue = "goal_value"
        case xpReward = "xp_reward"
        case coinsReward = "coins_reward"
        case badgeIcon = "badge_icon"
        case startDate = "start_date"
        case endDate = "end_date"
        case isActive = "is_active"
        case currentProgress = "current_progress"
        case isCompleted = "is_completed"
        case isPremium = "is_premium"
        case createdAt = "created_at"
    }
    
    var progressPercentage: Double {
        guard goalValue > 0 else { return 0 }
        return min(Double(currentProgress) / Double(goalValue), 1.0)
    }
    
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }
}

// Sample challenges for testing
extension Challenge {
    static let samples: [Challenge] = [
        Challenge(
            id: UUID(),
            nameEn: "10,000 Steps Daily",
            nameAr: "10,000 خطوة يومياً",
            descriptionEn: "Walk 10,000 steps every day for a week",
            descriptionAr: "امشِ 10,000 خطوة كل يوم لمدة أسبوع",
            type: "weekly",
            goalType: "steps",
            goalValue: 70000,
            xpReward: 50,
            coinsReward: 100,
            badgeIcon: "figure.walk",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            currentProgress: 35000,
            isCompleted: false,
            isPremium: false,
            createdAt: Date()
        ),
        Challenge(
            id: UUID(),
            nameEn: "5 Workouts This Week",
            nameAr: "5 تمارين هذا الأسبوع",
            descriptionEn: "Complete 5 full workout sessions",
            descriptionAr: "أكمل 5 جلسات تدريبية كاملة",
            type: "weekly",
            goalType: "workouts",
            goalValue: 5,
            xpReward: 100,
            coinsReward: 200,
            badgeIcon: "dumbbell.fill",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            currentProgress: 2,
            isCompleted: false,
            isPremium: false,
            createdAt: Date()
        ),
        Challenge(
            id: UUID(),
            nameEn: "Burn 3000 Calories",
            nameAr: "احرق 3000 سعرة حرارية",
            descriptionEn: "Burn a total of 3000 calories through exercise",
            descriptionAr: "احرق إجمالي 3000 سعرة حرارية من خلال التمارين",
            type: "weekly",
            goalType: "calories",
            goalValue: 3000,
            xpReward: 150,
            coinsReward: 300,
            badgeIcon: "flame.fill",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            currentProgress: 1250,
            isCompleted: false,
            isPremium: false,
            createdAt: Date()
        ),
        Challenge(
            id: UUID(),
            nameEn: "30-Day Consistency",
            nameAr: "الانتظام لمدة 30 يوم",
            descriptionEn: "Exercise at least once every day for 30 days",
            descriptionAr: "تمرّن مرة واحدة على الأقل كل يوم لمدة 30 يوماً",
            type: "monthly",
            goalType: "workouts",
            goalValue: 30,
            xpReward: 500,
            coinsReward: 1000,
            badgeIcon: "calendar.badge.checkmark",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            isActive: true,
            currentProgress: 8,
            isCompleted: false,
            isPremium: true,
            createdAt: Date()
        ),
        Challenge(
            id: UUID(),
            nameEn: "Hydration Master",
            nameAr: "سيد الترطيب",
            descriptionEn: "Drink 8 glasses of water daily for 7 days",
            descriptionAr: "اشرب 8 أكواب ماء يومياً لمدة 7 أيام",
            type: "weekly",
            goalType: "water",
            goalValue: 56,
            xpReward: 75,
            coinsReward: 150,
            badgeIcon: "drop.fill",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            currentProgress: 32,
            isCompleted: false,
            isPremium: false,
            createdAt: Date()
        )
    ]
}
