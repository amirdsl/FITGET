//
//  AppFeaturesAccess.swift
//  FITGET
//
//  Path: FITGET/Core/Access/AppFeaturesAccess.swift
//

import Foundation

/// المزايا الرئيسية داخل التطبيق التي لها فرق بين Free و Premium
enum FGAppFeature {
    case communityView        // رؤية المجتمع (تايم لاين، منشورات عامة)
    case communityInteract    // تفاعل: لايك، تعليق، مشاركة، رسائل
    case groupChallenges      // التحديات الجماعية / تحدي الأصدقاء
    case paidPrograms         // البرامج المدفوعة / برامج المدربين
    case onlineCoaching       // نظام التدريب الأونلاين (Online Coaching)
    case coinsShop            // متجر العملات / شراء باقات
}

/// منطق الوصول للميزات حسب نوع الدور الحالي
struct FGAppAccess {

    static func canAccess(_ feature: FGAppFeature, state: FGUserSubscriptionState) -> Bool {
        switch feature {

        // رؤية المجتمع متاحة للجميع (Free يشوف بس، Premium يتفاعل)
        case .communityView:
            return true

        // التفاعل في المجتمع (منشورات – تعليقات – رسائل) → بريميوم فقط
        case .communityInteract:
            return state.isPremiumUser

        // التحديات الجماعية (تيمات، أصدقاء) → بريميوم فقط
        case .groupChallenges:
            return state.isPremiumUser

        // البرامج المدفوعة (برامج مدربين، برامج خاصة) → بريميوم فقط
        case .paidPrograms:
            return state.isPremiumUser

        // التدريب الأونلاين → بريميوم فقط
        case .onlineCoaching:
            return state.isPremiumUser

        // متجر العملات – يفضل يكون للمشتركين، لكن يمكن تغييره لاحقاً
        case .coinsShop:
            return state.isPremiumUser
        }
    }
}
