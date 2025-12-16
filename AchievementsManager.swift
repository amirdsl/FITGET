//
//  AchievementsManager.swift
//  FITGET
//
//  Path: FITGET/Services/AchievementsManager.swift
//

import Foundation
import Supabase
import Combine

@MainActor
final class AchievementsManager: ObservableObject {

    static let shared = AchievementsManager()
    private init() {}

    private let supabase = SupabaseManager.shared

    // MARK: - Published State

    @Published private(set) var allAchievements: [Achievement] = []
    @Published private(set) var unlockedAchievementIds: Set<UUID> = []

    // MARK: - Models

    struct Achievement: Identifiable, Decodable {
        let id: UUID
        let code: String
        let nameEn: String
        let nameAr: String
        let descriptionEn: String?
        let descriptionAr: String?
        let category: String?
        let metric: String?
        let targetValue: Int?
        let xpReward: Int
        let coinsReward: Int

        enum CodingKeys: String, CodingKey {
            case id
            case code
            case nameEn = "name_en"
            case nameAr = "name_ar"
            case descriptionEn = "description_en"
            case descriptionAr = "description_ar"
            case category
            case metric
            case targetValue = "target_value"
            case xpReward = "xp_reward"
            case coinsReward = "coins_reward"
        }
    }

    struct UserAchievementRow: Decodable {
        let achievement_id: UUID
    }

    struct UserAchievementInsert: Encodable {
        let user_id: UUID
        let achievement_id: UUID
    }

    // MARK: - Load

    func loadAchievements(for userId: UUID) async {
        await loadAllAchievements()
        await loadUnlockedAchievements(for: userId)
    }

    private func loadAllAchievements() async {
        do {
            let rows: [Achievement] = try await SupabaseManager.shared
                .from("achievements")
                .select()
                .execute()
                .value

            self.allAchievements = rows
        } catch {
            print("Failed to load achievements:", error)
        }
    }

    private func loadUnlockedAchievements(for userId: UUID) async {
        do {
            let rows: [UserAchievementRow] = try await SupabaseManager.shared
                .from("user_achievements")
                .select("achievement_id")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value

            self.unlockedAchievementIds = Set(rows.map { $0.achievement_id })
        } catch {
            print("Failed to load user achievements:", error)
        }
    }

    // MARK: - Evaluation

    func evaluateAchievements(
        userId: UUID,
        xp: Int,
        level: Int,
        workoutsCompleted: Int,
        challengesCompleted: Int
    ) async {

        for achievement in allAchievements {

            guard !unlockedAchievementIds.contains(achievement.id) else { continue }
            guard let metric = achievement.metric,
                  let target = achievement.targetValue else { continue }

            let unlocked: Bool

            switch metric {
            case "xp":
                unlocked = xp >= target
            case "level":
                unlocked = level >= target
            case "workouts":
                unlocked = workoutsCompleted >= target
            case "challenges":
                unlocked = challengesCompleted >= target
            default:
                unlocked = false
            }

            if unlocked {
                await unlockAchievement(
                    achievement: achievement,
                    userId: userId
                )
            }
        }
    }

    // MARK: - Unlock

    private func unlockAchievement(
        achievement: Achievement,
        userId: UUID
    ) async {

        let payload = UserAchievementInsert(
            user_id: userId,
            achievement_id: achievement.id
        )

        do {
            _ = try await SupabaseManager.shared
                .from("user_achievements")
                .insert(payload)
                .execute()

            unlockedAchievementIds.insert(achievement.id)

            await PlayerProgressManager.shared.addProgress(
                userId: userId,
                xpGained: achievement.xpReward,
                coinsGained: achievement.coinsReward,
                didCompleteToday: false
            )

        } catch {
            print("Failed to unlock achievement:", error)
        }
    }
}
