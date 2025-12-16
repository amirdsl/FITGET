//
//  AppSectionAccess.swift
//  FITGET
//

import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case home
    case steps
    case habits
    case workouts
    case nutrition
    case progress
    case challenges
    case community
    case readyPrograms
    case customPrograms
    case paidPrograms
    case leaderboard
    case profile
    case settings
    case language

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .home: return "الرئيسية"
        case .steps: return "الخطوات"
        case .habits: return "العادات"
        case .workouts: return "التمارين"
        case .nutrition: return "التغذية"
        case .progress: return "التقدم"
        case .challenges: return "التحديات"
        case .community: return "المجتمع"
        case .readyPrograms: return "البرامج الجاهزة"
        case .customPrograms: return "البرامج المخصصة"
        case .paidPrograms: return "البرامج المدفوعة"
        case .leaderboard: return "لوحة المتصدرين"
        case .profile: return "الملف التعريفي"
        case .settings: return "الإعدادات"
        case .language: return "اللغة"
        }
    }
}

enum SectionAccessLevel {
    case hidden
    case locked
    case readOnly
    case full
}

struct SectionAccessResult {
    let section: AppSection
    let level: SectionAccessLevel
    let reason: String?
}

final class AccessManager {

    static let shared = AccessManager()

    private init() {}

    func accessLevel(
        for section: AppSection,
        state: FGUserSubscriptionState
    ) -> SectionAccessResult {

        if state.role == .coach || state.role == .admin {
            return SectionAccessResult(section: section, level: .full, reason: nil)
        }

        if state.role == .guest {
            return accessForGuest(section: section, state: state)
        }

        if state.role == .free {
            return accessForFreeUser(section: section)
        }

        if state.role == .basic || state.role == .pro {
            return accessForPaidUser(section: section, role: state.role)
        }

        return SectionAccessResult(section: section, level: .locked, reason: "غير متاح.")
    }

    // MARK: - Guest

    private func accessForGuest(
        section: AppSection,
        state: FGUserSubscriptionState
    ) -> SectionAccessResult {

        guard state.isGuestTrialActive else {
            return SectionAccessResult(
                section: section,
                level: .locked,
                reason: "انتهت مدة الدخول كضيف، قم بالاشتراك للوصول إلى هذا القسم."
            )
        }

        switch section {
        case .home:
            return .init(section: section, level: .full, reason: nil)

        case .workouts:
            return .init(
                section: section,
                level: .full,
                reason: "يمكنك تجربة مجموعة محدودة من التمارين خلال فترة الضيف."
            )

        case .nutrition:
            return .init(
                section: section,
                level: .readOnly,
                reason: "عرض مثال لبرنامج تغذية، الاشتراك لفتح المزايا الكاملة."
            )

        case .steps:
            return .init(
                section: section,
                level: .full,
                reason: "متابعة الخطوات الأساسية خلال فترة التجربة."
            )

        case .challenges:
            return .init(
                section: section,
                level: .readOnly,
                reason: "يمكنك استعراض التحديات، الاشتراك للمشاركة فيها."
            )

        case .community:
            return .init(
                section: section,
                level: .readOnly,
                reason: "يمكنك رؤية منشورات المجتمع فقط، الاشتراك للتفاعل."
            )

        case .readyPrograms, .customPrograms, .paidPrograms:
            return .init(
                section: section,
                level: .locked,
                reason: "هذه البرامج متاحة بعد الاشتراك أو الشراء بالعملات."
            )

        case .habits, .progress, .leaderboard:
            return .init(
                section: section,
                level: .locked,
                reason: "هذه الميزة متاحة مع الاشتراك."
            )

        case .profile, .settings, .language:
            return .init(section: section, level: .full, reason: nil)
        }
    }

    // MARK: - Free

    private func accessForFreeUser(
        section: AppSection
    ) -> SectionAccessResult {

        switch section {
        case .home:
            return .init(section: section, level: .full, reason: nil)

        case .workouts:
            return .init(
                section: section,
                level: .full,
                reason: "وصول لتمارين أساسية ومحدودة."
            )

        case .nutrition:
            return .init(
                section: section,
                level: .readOnly,
                reason: "عرض بعض البرامج الغذائية الأساسية فقط."
            )

        case .steps, .habits:
            return .init(section: section, level: .full, reason: nil)

        case .challenges:
            return .init(
                section: section,
                level: .readOnly,
                reason: "يمكنك استعراض بعض التحديات العامة."
            )

        case .community:
            return .init(
                section: section,
                level: .readOnly,
                reason: "يمكنك رؤية المنشورات بدون نشر أو تعليق."
            )

        case .readyPrograms:
            return .init(
                section: section,
                level: .readOnly,
                reason: "استعراض البرامج الجاهزة، مع إمكانية شراء بعضها بالعملات."
            )

        case .customPrograms, .paidPrograms, .leaderboard, .progress:
            return .init(
                section: section,
                level: .locked,
                reason: "هذه الميزة متاحة في الباقات المدفوعة."
            )

        case .profile, .settings, .language:
            return .init(section: section, level: .full, reason: nil)
        }
    }

    // MARK: - Paid

    private func accessForPaidUser(
        section: AppSection,
        role: FGUserRole
    ) -> SectionAccessResult {

        let isPro = (role == .pro)

        switch section {
        case .home, .steps, .habits, .workouts, .nutrition, .progress, .leaderboard,
             .profile, .settings, .language:
            return .init(section: section, level: .full, reason: nil)

        case .community:
            return .init(
                section: section,
                level: .full,
                reason: "يمكنك نشر المنشورات والتعليق والتفاعل مع المجتمع."
            )

        case .challenges:
            return .init(
                section: section,
                level: .full,
                reason: "كل التحديات الفردية والجماعية متاحة."
            )

        case .readyPrograms:
            return .init(
                section: section,
                level: .full,
                reason: "وصول كامل للبرامج الجاهزة."
            )

        case .customPrograms:
            if isPro {
                return .init(
                    section: section,
                    level: .full,
                    reason: "وصول كامل للبرامج المخصصة."
                )
            } else {
                return .init(
                    section: section,
                    level: .locked,
                    reason: "البرامج المخصصة متاحة في باقة Pro فقط."
                )
            }

        case .paidPrograms:
            return .init(
                section: section,
                level: .full,
                reason: "البرامج المدفوعة يمكن شراؤها باستخدام العملات أو الدفع المباشر."
            )
        }
    }
}
