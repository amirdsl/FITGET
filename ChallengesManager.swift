//
//  ChallengesManager.swift
//  FITGET
//
//  Path: FITGET/Services/ChallengesManager.swift
//

import Foundation
import Supabase
import Combine

@MainActor
final class ChallengesManager: ObservableObject {

    static let shared = ChallengesManager()
    private init() {}

    private let supabase = SupabaseManager.shared

    // MARK: - Published State

    @Published private(set) var activeChallenges: [DBChallenge] = []
    @Published private(set) var joinedChallengeIds: Set<UUID> = []
    @Published private(set) var completedChallenges: [DBChallenge] = []

    var activeChallengesCount: Int {
        joinedChallengeIds.count
    }

    // MARK: - Models

    struct ChallengeMemberRow: Decodable {
        let challenge_id: UUID
        let progress_value: Double
        let is_completed: Bool
    }

    struct JoinChallengeInsert: Encodable {
        let challenge_id: UUID
        let user_id: UUID
        let progress_value: Double
        let is_completed: Bool
    }

    struct ChallengeProgressUpdate: Encodable {
        let progress_value: Double
        let is_completed: Bool
    }

    // MARK: - Load Challenges

    func loadChallenges(for userId: UUID) async {
        do {
            let challenges: [DBChallenge] = try await SupabaseManager.shared
                .from("challenges")
                .select()
                .eq("is_public", value: true)
                .execute()
                .value

            self.activeChallenges = challenges
            await loadUserChallengeStates(for: userId)

        } catch {
            print("Failed to load challenges:", error)
        }
    }

    private func loadUserChallengeStates(for userId: UUID) async {
        do {
            let rows: [ChallengeMemberRow] = try await SupabaseManager.shared
                .from("challenge_members")
                .select("challenge_id, progress_value, is_completed")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value

            let completedIds = rows
                .filter { $0.is_completed }
                .map { $0.challenge_id }

            joinedChallengeIds = Set(rows.map { $0.challenge_id })

            completedChallenges = activeChallenges.filter {
                completedIds.contains($0.id)
            }

        } catch {
            print("Failed to load user challenge states:", error)
        }
    }

    // MARK: - Join Challenge

    func joinChallenge(
        challengeId: UUID,
        userId: UUID
    ) async {

        guard !joinedChallengeIds.contains(challengeId) else { return }

        let payload = JoinChallengeInsert(
            challenge_id: challengeId,
            user_id: userId,
            progress_value: 0,
            is_completed: false
        )

        do {
            _ = try await SupabaseManager.shared
                .from("challenge_members")
                .insert(payload)
                .execute()

            joinedChallengeIds.insert(challengeId)

        } catch {
            print("Failed to join challenge:", error)
        }
    }

    // MARK: - Update Progress

    func updateProgress(
        challenge: DBChallenge,
        userId: UUID,
        progressIncrement: Double
    ) async {

        let currentProgress = await fetchCurrentProgress(
            challengeId: challenge.id,
            userId: userId
        )

        let newProgress = currentProgress + progressIncrement
        let completed = newProgress >= challenge.targetValue

        let payload = ChallengeProgressUpdate(
            progress_value: newProgress,
            is_completed: completed
        )

        do {
            _ = try await SupabaseManager.shared
                .from("challenge_members")
                .update(payload)
                .eq("challenge_id", value: challenge.id.uuidString)
                .eq("user_id", value: userId.uuidString)
                .execute()

            if completed {
                completedChallenges.append(challenge)
                await rewardChallengeCompletion(
                    challenge: challenge,
                    userId: userId
                )
            }

        } catch {
            print("Failed to update challenge progress:", error)
        }
    }

    // MARK: - Rewards

    private func rewardChallengeCompletion(
        challenge: DBChallenge,
        userId: UUID
    ) async {

        let xpReward = Int(challenge.targetValue * 10)
        let coinsReward = max(5, xpReward / 5)

        await PlayerProgressManager.shared.addProgress(
            userId: userId,
            xpGained: xpReward,
            coinsGained: coinsReward,
            didCompleteToday: true
        )
    }

    // MARK: - Helpers

    private func fetchCurrentProgress(
        challengeId: UUID,
        userId: UUID
    ) async -> Double {

        do {
            let rows: [ChallengeMemberRow] = try await SupabaseManager.shared
                .from("challenge_members")
                .select("progress_value, is_completed")
                .eq("challenge_id", value: challengeId.uuidString)
                .eq("user_id", value: userId.uuidString)
                .limit(1)
                .execute()
                .value

            return rows.first?.progress_value ?? 0
        } catch {
            return 0
        }
    }
}
