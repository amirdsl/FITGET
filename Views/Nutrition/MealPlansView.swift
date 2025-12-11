//
//  MealPlansView.swift
//  FITGET
//

import SwiftUI

struct MealPlansView: View {
    
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    // نستخدم النموذج الجديد FGMealPlan لتجنّب أي تعارض مع MealPlan الآخر
    private let plans: [FGMealPlan] = FGMealPlan.samplePlans
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(plans) { plan in
                    NavigationLink {
                        MealPlanDetailView(plan: plan)
                            .environmentObject(languageManager)
                            .environmentObject(themeManager)
                    } label: {
                        MealPlanCard(plan: plan)
                            .environmentObject(languageManager)
                            .environmentObject(themeManager)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(isArabic ? "خطط غذائية" : "Meal Plans")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - بطاقة الخطة

struct MealPlanCard: View {
    
    let plan: FGMealPlan
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? plan.titleAr : plan.titleEn)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            Text("\(plan.calories) kcal")
                .font(.caption)
                .foregroundColor(.orange)
            
            Text(isArabic ? plan.descriptionAr : plan.descriptionEn)
                .font(.subheadline)
                .foregroundColor(themeManager.textSecondary)
                .lineLimit(2)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - تفاصيل الخطة

struct MealPlanDetailView: View {
    
    let plan: FGMealPlan
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                
                Text(isArabic ? plan.titleAr : plan.titleEn)
                    .font(.title2.bold())
                
                Text("\(plan.calories) kcal")
                    .foregroundColor(.orange)
                
                Text(isArabic ? plan.descriptionAr : plan.descriptionEn)
                    .foregroundColor(themeManager.textSecondary)
                    .padding(.top, 4)
                
                if let weekly = plan.weeklyMeals {
                    Divider().padding(.vertical, 8)
                    
                    Text(isArabic ? "الجدول الأسبوعي" : "Weekly schedule")
                        .font(.headline)
                    
                    ForEach(weekly, id: \.self) { line in
                        HStack(alignment: .top, spacing: 6) {
                            Circle()
                                .fill(themeManager.primary)
                                .frame(width: 6, height: 6)
                            
                            Text(line)
                                .font(.subheadline)
                                .foregroundColor(themeManager.textPrimary)
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle(isArabic ? "تفاصيل الخطة" : "Plan Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MealPlansView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
