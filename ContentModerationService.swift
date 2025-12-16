//
//  ContentModerationService.swift
//  FITGET
//
//  Created by ChatGPT on 2025-11-26.
//
import Combine
import Foundation

struct CommunityReport: Identifiable, Codable {
    let id: String
    let postId: String
    let reporterUserId: String
    let reportedUserId: String?
    let reason: String
    let createdAt: Date
    let extraInfo: String?

    init(
        id: String = UUID().uuidString,
        postId: String,
        reporterUserId: String,
        reportedUserId: String? = nil,
        reason: String,
        createdAt: Date = Date(),
        extraInfo: String? = nil
    ) {
        self.id = id
        self.postId = postId
        self.reporterUserId = reporterUserId
        self.reportedUserId = reportedUserId
        self.reason = reason
        self.createdAt = createdAt
        self.extraInfo = extraInfo
    }
}

final class ContentModerationService {

    static let shared = ContentModerationService()

    private init() {}

    // ضع قائمة الكلمات السيئة (عربي + إنجليزي) بنفسك
    // هنا أمثلة عامة بدون كلمات حقيقية، فقط شكل النظام
    private let bannedWords: [String] = [
        "badword1",
        "badword2",
        "كلمةسيئة١",
        "كلمةسيئة٢"
    ]

    // MARK: - Bad words detection

    func detectBadWords(in text: String) -> [String] {
        guard !text.isEmpty else { return [] }

        let normalized = text.lowercased()
        var found: [String] = []

        for word in bannedWords {
            let w = word.lowercased()
            if normalized.contains(w) {
                found.append(word)
            }
        }

        return Array(Set(found))
    }

    func containsBadWords(in text: String) -> Bool {
        return !detectBadWords(in: text).isEmpty
    }

    func cleanText(_ text: String, maskCharacter: Character = "*") -> String {
        var result = text
        let found = detectBadWords(in: text)

        for word in found {
            let mask = String(repeating: maskCharacter, count: word.count)
            result = result.replacingOccurrences(of: word, with: mask, options: .caseInsensitive, range: nil)
        }

        return result
    }

    // MARK: - Reporting

    /// هنا فقط منطق محلي. لاحقاً اربطه مع Supabase / API حقيقي.
    func createReport(
        postId: String,
        reporterUserId: String,
        reportedUserId: String?,
        reason: String,
        extraInfo: String? = nil
    ) -> CommunityReport {
        let report = CommunityReport(
            postId: postId,
            reporterUserId: reporterUserId,
            reportedUserId: reportedUserId,
            reason: reason,
            extraInfo: extraInfo
        )

        // TODO: send to backend (Supabase) لاحقاً
        // مثال:
        // SupabaseCommunityAPI.shared.sendReport(report)

        return report
    }
}
