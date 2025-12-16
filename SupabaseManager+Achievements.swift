//
//  SupabaseManager+Achievements.swift
//  Fitget
//
//  API للإنجازات من Supabase
//

import Foundation
import Supabase

struct Achievement: Identifiable, Decodable, Equatable {
    let id: UUID
    let code: String
    let name_en: String
    let name_ar: String
    let description_en: String?
    let description_ar: String?
    let category: String?
    let metric: String?
    let target_value: Int
    let icon: String?
    let xp_reward: Int
    let coins_reward: Int
    
    var localizedName: String {
        LanguageManager.shared.currentLanguage == "ar" ? name_ar : name_en
    }
    
    var localizedDescription: String {
        let lang = LanguageManager.shared.currentLanguage
        if lang == "ar" {
            return description_ar ?? ""
        } else {
            return description_en ?? ""
        }
    }
}

struct UserAchievementRow: Decodable, Identifiable, Equatable {
    let id: UUID
    let achievement_id: UUID
    let unlocked_at: String
}

extension SupabaseManager {
    
    /// يجلب كل الإنجازات + IDs المفتوحة للمستخدم الحالي
    func fetchAchievementsForCurrentUser() async throws -> ([Achievement], Set<UUID>) {
        let session = try await auth.session
        let userId = session.user.id
        
        let achievements: [Achievement] = try await SupabaseManager.shared
            .from("achievements")
            .select()
            .order("created_at", ascending: true)
            .execute()
            .value
        
        let userRows: [UserAchievementRow] = try await SupabaseManager.shared
            .from("user_achievements")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        
        let unlockedIDs = Set(userRows.map { $0.achievement_id })
        return (achievements, unlockedIDs)
    }
    
    /// فتح إنجاز حسب الـ code (لو موجود)
    func unlockAchievement(code: String) async throws {
        let session = try await auth.session
        let userId = session.user.id
        
        // نجيب الـ id للإنجاز
        struct AchRow: Decodable {
            let id: UUID
            let code: String
        }
        
        let rows: [AchRow] = try await SupabaseManager.shared
            .from("achievements")
            .select("id, code")
            .eq("code", value: code)
            .limit(1)
            .execute()
            .value
        
        guard let achievement = rows.first else {
            print("unlockAchievement: no achievement with code \(code)")
            return
        }
        
        struct NewUserAchievement: Encodable {
            let user_id: UUID
            let achievement_id: UUID
        }
        
        let payload = NewUserAchievement(
            user_id: userId,
            achievement_id: achievement.id
        )
        
        _ = try await SupabaseManager.shared
            .from("user_achievements")
            .upsert(payload, onConflict: "user_id,achievement_id")
            .execute()
    }
}
