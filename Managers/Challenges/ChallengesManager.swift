//
//  ChallengesManager.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import Foundation
import Combine
import Supabase

@MainActor
final class ChallengesManager: ObservableObject {
    static let shared = ChallengesManager()
    
    @Published var activeChallenges: [Challenge] = []
    @Published var availableChallenges: [Challenge] = []
    @Published var completedChallenges: [Challenge] = []
    
    private let supabase = SupabaseManager.shared
    
    private init() { }
    
    // MARK: - Model
    
    struct Challenge: Identifiable, Codable, Hashable {
        enum Kind: String, Codable {
            case steps
            case calories
            case workouts
            case habits
        }
        
        enum Difficulty: String, Codable {
            case easy
            case medium
            case hard
        }
        
        let id: UUID
        let title: String
        let description: String
        let kind: Kind
        let difficulty: Difficulty
        let targetValue: Int
        let xpReward: Int
        let durationDays: Int
        var isJoined: Bool
        var isCompleted: Bool
    }
    
    // MARK: - Helpers للـ Dashboard
    
    var activeChallengesCount: Int {
        activeChallenges.count
    }
    
    var highlightedTodayChallenges: [Challenge] {
        Array(activeChallenges.prefix(3))
    }
    
    // MARK: - Public API
    
    func loadChallenges() async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            _ = userId
            
            struct Row: Decodable {
                let id: UUID
                let title: String
                let description: String
                let type: String
                let difficulty: String
                let target_value: Int
                let xp_reward: Int
                let duration_days: Int
            }
            
            let rows: [Row] = try await supabase.database
                .from("challenges_v2")
                .select()
                .execute()
                .value
            
            let mapped: [Challenge] = rows.map { row in
                Challenge(
                    id: row.id,
                    title: row.title,
                    description: row.description,
                    kind: Challenge.Kind(rawValue: row.type) ?? .steps,
                    difficulty: Challenge.Difficulty(rawValue: row.difficulty) ?? .medium,
                    targetValue: row.target_value,
                    xpReward: row.xp_reward,
                    durationDays: row.duration_days,
                    isJoined: false,
                    isCompleted: false
                )
            }
            
            self.availableChallenges = mapped
        } catch {
            print("ChallengesManager loadChallenges error: \(error)")
        }
    }
    
    func join(_ challenge: Challenge) async {
        var updated = challenge
        updated.isJoined = true
        
        if !activeChallenges.contains(updated) {
            activeChallenges.append(updated)
        }
        
        availableChallenges.removeAll { $0.id == challenge.id }
        
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            struct Insert: Encodable {
                let user_id: UUID
                let challenge_id: UUID
                let status: String
            }
            
            let payload = Insert(
                user_id: userId,
                challenge_id: challenge.id,
                status: "active"
            )
            
            _ = try await supabase.database
                .from("user_challenges")
                .upsert(payload, onConflict: "user_id,challenge_id")
                .execute()
        } catch {
            print("ChallengesManager join error: \(error)")
        }
    }
    
    func complete(_ challenge: Challenge) async {
        var updated = challenge
        updated.isCompleted = true
        
        activeChallenges.removeAll { $0.id == challenge.id }
        if !completedChallenges.contains(updated) {
            completedChallenges.append(updated)
        }
        
        // MARK: - Gamification Rewards for challenge
        
        // XP من قيمة xpReward القادمة من Supabase
        let xpReward = challenge.xpReward
        
        // Coins: مبنية على XP + صعوبة التحدي + مدة التحدي
        var coinsReward = max(1, xpReward / 10)
        
        switch challenge.difficulty {
        case .easy:
            coinsReward += 0
        case .medium:
            coinsReward += 5
        case .hard:
            coinsReward += 10
        }
        
        if challenge.durationDays >= 30 {
            coinsReward += 10
        } else if challenge.durationDays >= 14 {
            coinsReward += 5
        }
        
        // تحديث نظام التقدم الرئيسي
        ProgressManager.shared.addRewardXP(xpReward)
        
        // تحديث نظام الـ Gamification (XP + Coins)
        GamificationManager.shared.addXP(xpReward)
        GamificationManager.shared.addCoins(coinsReward)
        
        // حفظ حالة التحدي في Supabase
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            struct Update: Encodable {
                let status: String
            }
            
            let payload = Update(status: "completed")
            
            _ = try await supabase.database
                .from("user_challenges")
                .update(payload)
                .eq("user_id", value: userId.uuidString)
                .eq("challenge_id", value: challenge.id.uuidString)
                .execute()
        } catch {
            print("ChallengesManager complete error: \(error)")
        }
    }
}
