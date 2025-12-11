//
//  CurrentPlanBannerView.swift
//  FITGET
//
//  Path: FITGET/Views/Subscriptions/CurrentPlanBannerView.swift
//

import SwiftUI

struct CurrentPlanBannerView: View {

    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var showPaywall: Bool = false

    private var state: FGUserSubscriptionState {
        subscriptionStore.state
    }

    private var isPremium: Bool {
        state.isPremiumUser
    }

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var planTitle: String {
        if let plan = state.activePlan {
            switch plan.tier {
            case .free:  return isArabic ? "خطة مجانية" : "Free plan"
            case .basic: return "Basic"
            case .pro:   return "Pro"
            case .coach: return isArabic ? "خطة المدرب" : "Coach plan"
            }
        } else {
            return isArabic ? "خطة مجانية" : "Free plan"
        }
    }

    private var planSubtitle: String {
        if isPremium {
            return isArabic
            ? "اشتراكك مفعل، استمتع بكل مميزات FITGET."
            : "Your subscription is active. Enjoy all FITGET features."
        } else {
            return isArabic
            ? "أنت على الخطة المجانية، بعض المميزات مقفلة حاليًا."
            : "You are on the free plan. Some features are locked."
        }
    }

    private var badgeText: String {
        isPremium ? "Premium" : "Free"
    }

    private var badgeColor: Color {
        isPremium ? .green : .gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: isPremium ? "crown.fill" : "person.crop.circle.badge.questionmark")
                    .font(.title2)
                    .foregroundColor(isPremium ? .yellow : .accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(planTitle)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)

                    Text(planSubtitle)
                        .font(.footnote)
                        .foregroundColor(themeManager.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Text(badgeText)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor.opacity(0.15))
                    .cornerRadius(10)
            }

            if !isPremium {
                Button(action: {
                    showPaywall = true
                }) {
                    Text(isArabic ? "ترقية إلى FITGET بريميوم" : "Upgrade to FITGET Premium")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.footnote)
                        .foregroundColor(.green)
                    Text(isArabic
                         ? "اشتراكك مفعل، استمر في استغلال كل المزايا."
                         : "Your plan is active, keep using all premium features.")
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
                }
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .padding(.horizontal)
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        }
    }
}

#Preview {
    let store = FGSubscriptionStore()
    var state = FGUserSubscriptionState()
    state.role = .free
    store.state = state

    return CurrentPlanBannerView()
        .environmentObject(store)
        .environmentObject(PlayerProgress())
        .environmentObject(ThemeManager.shared)
        .environmentObject(LanguageManager.shared)
}
