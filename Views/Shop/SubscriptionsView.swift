//
//  SubscriptionsView.swift
//  Fitget
//
//  Created on 22/11/2025.
//

import SwiftUI

struct SubscriptionsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedPlan = "3months"
    
    var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var plans: [SubscriptionPlan] {
        [
            SubscriptionPlan(id: "1month", duration: isArabic ? "شهر واحد" : "1 Month", price: 9.99, savings: 0),
            SubscriptionPlan(id: "3months", duration: isArabic ? "3 أشهر" : "3 Months", price: 24.99, savings: 17),
            SubscriptionPlan(id: "6months", duration: isArabic ? "6 أشهر" : "6 Months", price: 44.99, savings: 25)
        ]
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    premiumBadge
                    
                    featuresSection
                    
                    plansSection
                    
                    subscribeButton
                    
                    legalText
                }
                .padding()
            }
        }
        .navigationTitle(isArabic ? "الاشتراكات" : "Subscriptions")
    }
    
    var premiumBadge: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(AppColors.goldGradient)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 45))
                    .foregroundColor(.white)
            }
            
            Text(isArabic ? "FITGET Premium" : "FITGET Premium")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(themeManager.textPrimary)
            
            Text(isArabic ? "احصل على جميع الميزات المميزة" : "Get all premium features")
                .font(.subheadline)
                .foregroundColor(themeManager.textSecondary)
        }
        .padding(30)
        .background(themeManager.cardBackground)
        .cornerRadius(20)
    }
    
    var featuresSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(isArabic ? "ماذا ستحصل؟" : "What You'll Get")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            FeatureRow(icon: "checkmark.circle.fill", text: isArabic ? "وصول كامل لجميع التمارين" : "Full access to all exercises")
            FeatureRow(icon: "checkmark.circle.fill", text: isArabic ? "200+ وصفة صحية" : "200+ healthy recipes")
            FeatureRow(icon: "checkmark.circle.fill", text: isArabic ? "برامج تدريبية مخصصة" : "Custom training programs")
            FeatureRow(icon: "checkmark.circle.fill", text: isArabic ? "تتبع تقدمك بالتفصيل" : "Detailed progress tracking")
            FeatureRow(icon: "checkmark.circle.fill", text: isArabic ? "تحديات حصرية" : "Exclusive challenges")
            FeatureRow(icon: "checkmark.circle.fill", text: isArabic ? "بدون إعلانات" : "Ad-free experience")
            FeatureRow(icon: "checkmark.circle.fill", text: isArabic ? "دعم فني أولوية" : "Priority support")
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }
    
    var plansSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(isArabic ? "اختر الخطة المناسبة" : "Choose Your Plan")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            ForEach(plans) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan.id,
                    isArabic: isArabic
                ) {
                    selectedPlan = plan.id
                }
            }
        }
    }
    
    var subscribeButton: some View {
        Button {
            subscribeToPlan()
        } label: {
            Text(isArabic ? "اشترك الآن" : "Subscribe Now")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppColors.primaryGradient)
                .cornerRadius(16)
                .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 10)
        }
    }
    
    var legalText: some View {
        VStack(spacing: 8) {
            Text(isArabic ? "سيتم تجديد اشتراكك تلقائياً" : "Your subscription will renew automatically")
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button {
                    // TODO: Terms
                } label: {
                    Text(isArabic ? "الشروط والأحكام" : "Terms of Service")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryBlue)
                }
                
                Button {
                    // TODO: Privacy
                } label: {
                    Text(isArabic ? "سياسة الخصوصية" : "Privacy Policy")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    func subscribeToPlan() {
        guard let plan = plans.first(where: { $0.id == selectedPlan }) else { return }
        print("Subscribing to: \(plan.duration) for $\(plan.price)")
    }
}

struct SubscriptionPlan: Identifiable {
    let id: String
    let duration: String
    let price: Double
    let savings: Int
}

struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let isArabic: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var pricePerMonth: Double {
        let months: Double = plan.id == "1month" ? 1 : (plan.id == "3months" ? 3 : 6)
        return plan.price / months
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.duration)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text("$\(String(format: "%.2f", pricePerMonth))" + (isArabic ? "/شهر" : "/month"))
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", plan.price))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryBlue)
                    
                    if plan.savings > 0 {
                        Text((isArabic ? "وفّر " : "Save ") + "\(plan.savings)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColors.success)
                            .cornerRadius(4)
                    }
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? AppColors.primaryBlue : themeManager.textSecondary)
                    .font(.title3)
            }
            .padding()
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [AppColors.primaryBlue.opacity(0.1), AppColors.primaryBlue.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            colors: [themeManager.cardBackground, themeManager.cardBackground],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primaryBlue : themeManager.textSecondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.success)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    SubscriptionsView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
}
