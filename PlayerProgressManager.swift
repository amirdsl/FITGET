//
//  PlayerProgressManager.swift
//  FITGET
//
//  Path: FITGET/Services/PlayerProgressManager.swift
//

import Foundation
import Supabase
import Combine

@MainActor
final class PlayerProgressManager: ObservableObject {

    static let shared = PlayerProgressManager()
    private init() {}

    private let supabase = SupabaseManager.shared

    // MARK: - Published State

    @Published private(set) var xp: Int = 0
    @Published private(set) var level: Int = 1
    @Published private(set) var coins: Int = 0
    @Published private(set) var streakDays: Int = 0

    // MARK: - Models

    struct ProgressRow: Decodable {
        let xp: Int
        let level: Int
        let coins: Int
        let streak_days: Int
    }

    struct ProgressUpdatePayload: Encodable {
        let xp: Int
        let level: Int
        let coins: Int
        let streak_days: Int
    }

    // MARK: - Load

    func loadProgress(for userId: UUID) async {
        do {
            let rows: [ProgressRow] = try await SupabaseManager.shared
                .from("profiles")
                .select("xp, level, coins, streak_days")
                .eq("id", value: userId.uuidString)
                .limit(1)
                .execute()
                .value

            guard let row = rows.first else { return }

            xp = row.xp
            level = row.level
            coins = row.coins
            streakDays = row.streak_days

        } catch {
            print("Failed to load progress:", error)
        }
    }

    // MARK: - Update

    func addProgress(
        userId: UUID,
        xpGained: Int,
        coinsGained: Int,
        didCompleteToday: Bool
    ) async {

        let newXP = xp + xpGained
        let newLevel = Self.calculateLevel(from: newXP)
        let newCoins = coins + coinsGained
        let newStreak = didCompleteToday ? streakDays + 1 : streakDays

        let payload = ProgressUpdatePayload(
            xp: newXP,
            level: newLevel,
            coins: newCoins,
            streak_days: newStreak
        )

        do {
            _ = try await SupabaseManager.shared
                .from("profiles")
                .update(payload)
                .eq("id", value: userId.uuidString)
                .execute()

            xp = newXP
            level = newLevel
            coins = newCoins
            streakDays = newStreak

        } catch {
            print("Failed to update progress:", error)
        }
    }

    // MARK: - Reset

    func resetProgress(for userId: UUID) async {
        let payload = ProgressUpdatePayload(
            xp: 0,
            level: 1,
            coins: 0,
            streak_days: 0
        )

        do {
            _ = try await SupabaseManager.shared
                .from("profiles")
                .update(payload)
                .eq("id", value: userId.uuidString)
                .execute()

            xp = 0
            level = 1
            coins = 0
            streakDays = 0

        } catch {
            print("Failed to reset progress:", error)
        }
    }

    // MARK: - Level Formula

    static func calculateLevel(from xp: Int) -> Int {
        max(1, xp / 1000 + 1)
    }
}
