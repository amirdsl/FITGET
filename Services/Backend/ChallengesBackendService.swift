//  ChallengesBackendService.swift
//  FITGET
//
//  واجهة موحدة للتعامل مع التحديات + XP من الباك إند.
//  لا تعتمد مباشرة على Supabase حتى لا نصطدم باختلاف الـ SDK.
//  يمكنك ربطها بـ SupabaseManager أو أي طبقة شبكة عندك لاحقاً.
//

import Foundation

// MARK: - DTOs قادمة من الباك إند (Supabase)

/// Challenge مع حالة المستخدم (منضم / لا + مستوى التقدم)
struct BackendChallenge: Identifiable, Codable, Equatable {
    let id: UUID
    let titleAr: String?
    let titleEn: String?
    let descriptionAr: String?
    let descriptionEn: String?
    let challengeType: String
    let durationDays: Int
    let startDate: Date?
    let endDate: Date?
    let targetValue: Double?
    let isPublic: Bool
    let createdAt: Date?
    let isJoined: Bool
    let progressValue: Double

    enum CodingKeys: String, CodingKey {
        case id
        case titleAr       = "title_ar"
        case titleEn       = "title_en"
        case descriptionAr = "description_ar"
        case descriptionEn = "description_en"
        case challengeType = "challenge_type"
        case durationDays  = "duration_days"
        case startDate     = "start_date"
        case endDate       = "end_date"
        case targetValue   = "target_value"
        case isPublic      = "is_public"
        case createdAt     = "created_at"
        case isJoined      = "is_joined"
        case progressValue = "progress_value"
    }
}

/// صف العضوية في التحدي (challenge_members)
struct BackendChallengeMember: Identifiable, Codable, Equatable {
    let id: UUID
    let challengeId: UUID
    let userId: UUID
    let joinedAt: Date
    let progressValue: Double

    enum CodingKeys: String, CodingKey {
        case id
        case challengeId   = "challenge_id"
        case userId        = "user_id"
        case joinedAt      = "joined_at"
        case progressValue = "progress_value"
    }
}

// MARK: - خدمة التحديات – مجردة عن الباك إند

/// خطأ عام للخدمة لو لم يتم تهيئتها بعد
enum ChallengesBackendError: Error {
    case notConfigured
}

/// هذه الخدمة تُستخدم من الـ Managers / Views.
/// التنفيذ الفعلي (الاتصال بـ Supabase) يتم حقنه من الخارج عن طريق closures.
final class ChallengesBackendService {

    // Singleton
    static let shared = ChallengesBackendService()

    private init() {}

    // MARK: - Implementations (توصلها بطبقة Supabase عندك)

    /// استرجاع التحديات للمستخدم الحالي
    /// يجب أن تربطها لاحقًا بدالة RPC: fn_list_challenges_for_me
    var fetchChallengesImpl: (() async throws -> [BackendChallenge])?

    /// الانضمام لتحدي (Start challenge)
    /// تربطها لاحقًا بـ fn_join_challenge(p_challenge_id)
    var joinChallengeImpl: ((UUID) async throws -> BackendChallengeMember)?

    /// إضافة Check-in + تحديث التقدم
    /// تربطها لاحقًا بـ fn_add_challenge_checkin(p_challenge_id, p_value)
    var addCheckinImpl: ((UUID, Double) async throws -> BackendChallengeMember)?

    // MARK: - واجهة عامة تُستخدم في باقي المشروع

    func fetchChallengesForCurrentUser() async throws -> [BackendChallenge] {
        guard let impl = fetchChallengesImpl else {
            throw ChallengesBackendError.notConfigured
        }
        return try await impl()
    }

    func joinChallenge(challengeId: UUID) async throws -> BackendChallengeMember {
        guard let impl = joinChallengeImpl else {
            throw ChallengesBackendError.notConfigured
        }
        return try await impl(challengeId)
    }

    func addCheckin(challengeId: UUID, value: Double) async throws -> BackendChallengeMember {
        guard let impl = addCheckinImpl else {
            throw ChallengesBackendError.notConfigured
        }
        return try await impl(challengeId, value)
    }
}
