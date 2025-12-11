//
//  MealDetailsView.swift
//  FITGET
//
//  Path: Fitget/Views/Nutrition/MealDetailsView.swift
//

import SwiftUI

struct MealDetailsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    let meal: NutritionMeal
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.primaryBlue.opacity(0.12))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(AppColors.primaryBlue)
                    )
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(meal.name)
                        .font(.title2.bold())
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text("\(meal.calories) kcal")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryOrange)
                    
                    HStack(spacing: 16) {
                        macroChip(title: "P", value: Int(meal.protein), label: isArabic ? "بروتين" : "Protein")
                        macroChip(title: "C", value: Int(meal.carbs), label: isArabic ? "كربوهيدرات" : "Carbs")
                        macroChip(title: "F", value: Int(meal.fat), label: isArabic ? "دهون" : "Fat")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 16)
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "تفاصيل الوجبة" : "Meal details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func macroChip(title: String, value: Int, label: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .padding(4)
                .background(AppColors.primaryBlue.opacity(0.15))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value) g")
                    .font(.caption)
                    .foregroundColor(themeManager.textPrimary)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MealDetailsView(
            meal: MealsDatabase.lunchOptions.first!
        )
        .environmentObject(ThemeManager.shared)
        .environmentObject(LanguageManager.shared)
    }
}
