//
//  ChallengesBackendModels.swift
//  FITGET
//

import Foundation

/// موديل واحد موحد للتحديات لواجهة المستخدم
struct DBChallenge: Identifiable, Codable, Equatable {
    let id: UUID
    let titleAr: String
    let titleEn: String
    let descriptionAr: String?
    let descriptionEn: String?
    let durationDays: Int
    let targetValue: Double
    let isPublic: Bool
}
