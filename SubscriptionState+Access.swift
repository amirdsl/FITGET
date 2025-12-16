//
//  SubscriptionState+Access.swift
//  FITGET
//
//  Path: FITGET/Core/Subscriptions/SubscriptionState+Access.swift
//

import Foundation

extension FGUserSubscriptionState {

    /// مستخدم مجاني فقط (بدون باقة مدفوعة)
    var isFreeUser: Bool {
        role == .free || !isSubscriptionActive
    }

    /// مستخدم بريميوم (Basic / Pro / Coach)
    var isPremiumUser: Bool {
        isSubscriptionActive
    }
}
