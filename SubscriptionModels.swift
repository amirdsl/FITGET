//
//  SubscriptionModels.swift
//  FITGET
//
//  Path: FITGET/SubscriptionModels.swift
//

import Foundation
import Combine

// MARK: - Types

enum FGUserRole: String, Codable {
    case guest       // (Legacy) لم يعد يُستخدم، الحساب المجاني هو الوضع الافتراضي
    case free        // مستخدم مجاني
    case basic       // باقة أساسية (مدفوعة)
    case pro         // باقة متقدمة (مدفوعة)
    case coach       // مدرب
    case admin       // إدارة
}

enum FGSubscriptionDuration: String, Codable, CaseIterable, Identifiable {
    case monthly
    case threeMonths
    case sixMonths
    case yearly

    var id: String { rawValue }

    var monthsCount: Int {
        switch self {
        case .monthly: return 1
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .yearly: return 12
        }
    }

    var localizedTitle: String {
        switch self {
        case .monthly: return "شهر"
        case .threeMonths: return "٣ شهور"
        case .sixMonths: return "٦ شهور"
        case .yearly: return "سنة"
        }
    }
}

enum FGSubscriptionTier: String, Codable, CaseIterable, Identifiable {
    case free
    case basic
    case pro
    case coach

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .free:  return "مجاني"
        case .basic: return "Basic"
        case .pro:   return "Pro"
        case .coach: return "Coach"
        }
    }

    var marketingDescription: String {
        switch self {
        case .free:
            return "دخول للتمارين الأساسية وحاسبة السعرات وبعض المزايا المحدودة."
        case .basic:
            return "باقات تمارين أكثر، تغذية أساسية، وتحديات محدودة."
        case .pro:
            return "فتح جميع الأقسام، برامج جاهزة ومخصصة، مجتمع كامل، وتحديات متقدمة."
        case .coach:
            return "صلاحيات المدرب لإنشاء البرامج والتحديات وإدارة المتدربين."
        }
    }
}

struct FGSubscriptionPlan: Identifiable, Codable, Equatable {
    let id: String
    let tier: FGSubscriptionTier
    let duration: FGSubscriptionDuration
    let priceInCents: Int
    let isBestValue: Bool

    init(
        id: String = UUID().uuidString,
        tier: FGSubscriptionTier,
        duration: FGSubscriptionDuration,
        priceInCents: Int,
        isBestValue: Bool = false
    ) {
        self.id = id
        self.tier = tier
        self.duration = duration
        self.priceInCents = priceInCents
        self.isBestValue = isBestValue
    }
}

struct FGPurchasedProgram: Identifiable, Codable, Hashable {
    enum ProgramType: String, Codable {
        case ready       // برنامج جاهز
        case custom      // برنامج مخصص
    }

    let id: String
    let type: ProgramType
    let title: String
    let coachId: String?
    let purchaseDate: Date
    let expiresAt: Date?

    init(
        id: String = UUID().uuidString,
        type: ProgramType,
        title: String,
        coachId: String? = nil,
        purchaseDate: Date = Date(),
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.coachId = coachId
        self.purchaseDate = purchaseDate
        self.expiresAt = expiresAt
    }
}

struct FGUserSubscriptionState: Codable {
    var role: FGUserRole
    var activePlan: FGSubscriptionPlan?
    var purchasedPrograms: [FGPurchasedProgram]
    var guestTrialStart: Date?
    var guestTrialDaysLimit: Int

    init(
        role: FGUserRole = .free,
        activePlan: FGSubscriptionPlan? = nil,
        purchasedPrograms: [FGPurchasedProgram] = [],
        guestTrialStart: Date? = nil,
        guestTrialDaysLimit: Int = 0
    ) {
        self.role = role
        self.activePlan = activePlan
        self.purchasedPrograms = purchasedPrograms
        self.guestTrialStart = guestTrialStart
        self.guestTrialDaysLimit = guestTrialDaysLimit
    }

    /// وضع الضيف القديم – حاليًا لن يُستخدم لأننا نعتمد على Free Mode
    var isGuestTrialActive: Bool {
        guard role == .guest, let start = guestTrialStart else { return false }
        let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return days < guestTrialDaysLimit
    }

    /// هل لدى المستخدم أي اشتراك مدفوع فعّال (Basic / Pro / Coach)
    var isSubscriptionActive: Bool {
        guard activePlan != nil else { return false }
        return role == .basic || role == .pro || role == .coach
    }
}

// MARK: - Store

final class FGSubscriptionStore: ObservableObject {

    @Published var state: FGUserSubscriptionState

    init(initialState: FGUserSubscriptionState = FGUserSubscriptionState()) {
        self.state = initialState
    }

    /// بدء تجربة ضيف (قديمة) – الآن نستخدمها فقط لضمان أن الحساب Free
    func startGuestTrial() {
        // لم يعد هناك وضع ضيف منفصل، نضمن فقط أن المستخدم في الخطة المجانية.
        state.role = .free
        state.guestTrialStart = nil
        state.guestTrialDaysLimit = 0
    }

    /// تطبيق باقة اشتراك (تستخدم في SubscriptionPaywallView)
    func applySubscription(plan: FGSubscriptionPlan) {
        switch plan.tier {
        case .free:
            state.role = .free
        case .basic:
            state.role = .basic
        case .pro:
            state.role = .pro
        case .coach:
            state.role = .coach
        }
        state.activePlan = plan
        state.guestTrialStart = nil
    }

    func addPurchasedProgram(_ program: FGPurchasedProgram) {
        if !state.purchasedPrograms.contains(program) {
            state.purchasedPrograms.append(program)
        }
    }

    func hasPurchasedProgram(id: String) -> Bool {
        state.purchasedPrograms.contains(where: { $0.id == id })
    }
}
