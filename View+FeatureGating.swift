//
//  View+FeatureGating.swift
//  FITGET
//
//  Path: FITGET/Core/Access/View+FeatureGating.swift
//
import Combine
import SwiftUI

/// Modifier عام يقفل الميزة حسب نوعها (Community / Online Coaching / ...).
/// لو المستخدم ما عنده صلاحية:
/// - يعرض المحتوى "للقراءة فقط" (إن وجد)
/// - يضيف PremiumLockOverlay مع زر فتح البايوالت.
struct FeatureGateModifier: ViewModifier {

    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    let feature: FGAppFeature
    let title: String
    let message: String

    @State private var showPaywall: Bool = false

    func body(content: Content) -> some View {
        let state = subscriptionStore.state
        let allowed = FGAppAccess.canAccess(feature, state: state)

        ZStack {
            content
                .disabled(!allowed) // يمنع التفاعل لو الميزة مقفولة

            if !allowed {
                PremiumLockOverlay(
                    title: title,
                    message: message,
                    onUpgradeTapped: {
                        showPaywall = true
                    }
                )
            }
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        }
    }
}

extension View {

    /// استخدام سريع:
    ///  AnyView()
    ///   .gatedByFeature(.onlineCoaching, title: "..." , message: "...")
    func gatedByFeature(_ feature: FGAppFeature,
                        title: String,
                        message: String) -> some View {
        self.modifier(FeatureGateModifier(feature: feature,
                                          title: title,
                                          message: message))
    }
}
