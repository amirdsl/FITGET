//
//  SupabaseManager+Challenges.swift
//  Fitget
//
//  Created on 24/11/2025.
//

import Foundation
import Supabase

// MARK: - Models

struct ChallengeV2: Identifiable, Codable, Equatable {
    let id: UUID
    let type: String       // weekly / monthly
    let name_en: String
    let name_ar: String
    let description_en: String?
    let description_ar: String?
    let goal_type: String  // steps / calories / workouts / streak / weight
    let goal_value: Int
    let start_date: Date
    let end_date: Date
    let xp_reward: Int
    let coins_reward: Int
    let is_premium: Bool
    
    var isActive: Bool {
        let today = Date()
        return today >= start_date && today <= end_date
    }
}

struct ChallengeParticipant: Identifiable, Codable, Equatable {
    let id: UUID
    let user_id: UUID
    let challenge_id: UUID
    let progress: Int
    let is_completed: Bool
}

// MARK: - DTO for join / update

private struct ChallengeParticipantPayload: Encodable {
    let user_id: UUID
    let challenge_id: UUID
    let progress: Int
    let is_completed: Bool
}

// MARK: - API

extension SupabaseManager {
    
    /// جلب جميع التحديات + حالة اشتراك المستخدم فيها
    func fetchChallengesWithParticipation(for userId: UUID) async throws -> [(ChallengeV2, ChallengeParticipant?)] {
        // 1) جلب كل التحديات
        let challenges: [ChallengeV2] = try await SupabaseManager.shared
            .from("challenges_v2")
            .select()
            .order("start_date", ascending: false)
            .execute()
            .value
        
        // 2) جلب مشاركات المستخدم
        let participants: [ChallengeParticipant] = try await SupabaseManager.shared
            .from("challenge_participants")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        
        // 3) دمج الاثنين
        let map = Dictionary(uniqueKeysWithValues: participants.map { ($0.challenge_id, $0) })
        
        return challenges.map { ch in
            (ch, map[ch.id])
        }
    }
    
    /// انضمام إلى تحدّي
    func joinChallenge(_ challenge: ChallengeV2, userId: UUID) async throws {
        let payload = ChallengeParticipantPayload(
            user_id: userId,
            challenge_id: challenge.id,
            progress: 0,
            is_completed: false
        )
        
        _ = try await SupabaseManager.shared
            .from("challenge_participants")
            .upsert(payload, onConflict: "user_id,challenge_id")
            .execute()
    }
    
    /// تحديث التقدم في تحدّي
    func updateChallengeProgress(
        _ challenge: ChallengeV2,
        userId: UUID,
        progress: Int,
        isCompleted: Bool
    ) async throws {
        let payload = ChallengeParticipantPayload(
            user_id: userId,
            challenge_id: challenge.id,
            progress: progress,
            is_completed: isCompleted
        )
        
        _ = try await SupabaseManager.shared
            .from("challenge_participants")
            .upsert(payload, onConflict: "user_id,challenge_id")
            .execute()
    }
    
    /// الخروج من تحدّي (إلغاء الاشتراك)
    func leaveChallenge(_ challenge: ChallengeV2, userId: UUID) async throws {
        _ = try await SupabaseManager.shared
            .from("challenge_participants")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("challenge_id", value: challenge.id.uuidString)
            .execute()
    }
}
