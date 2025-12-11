//
//  MealPlanView.swift
//  FITGET
//
//  Path: Fitget/Views/Nutrition/MealPlanView.swift
//

import SwiftUI

struct MealPlanView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var nutritionManager: NutritionManager
    
    let plan: MealPlan
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    private var totalCalories: Int {
        plan.meals.reduce(0) { $0 + $1.calories }
    }
    
    private var totalProtein: Int {
        plan.meals.reduce(0) { $0 + $1.protein }
    }
    
    private var totalCarbs: Int {
        plan.meals.reduce(0) { $0 + $1.carbs }
    }
    
    private var totalFats: Int {
        plan.meals.reduce(0) { $0 + $1.fats }
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(isArabic ? plan.titleAR : plan.titleEN)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text("\(totalCalories) kcal")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primaryOrange)
                    
                    HStack(spacing: 16) {
                        macroChip(
                            title: "P",
                            value: totalProtein,
                            label: isArabic ? "بروتين" : "Protein"
                        )
                        macroChip(
                            title: "C",
                            value: totalCarbs,
                            label: isArabic ? "كربوهيدرات" : "Carbs"
                        )
                        macroChip(
                            title: "F",
                            value: totalFats,
                            label: isArabic ? "دهون" : "Fat"
                        )
                    }
                    
                    Text(plan.description(isArabic: isArabic))
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                .listRowBackground(themeManager.cardBackground)
            }
            
            // زر لإضافة كل الوجبات لليوم دفعة واحدة
            Section {
                Button {
                    for meal in plan.meals {
                        nutritionManager.logMeal(
                            calories: meal.calories,
                            protein: meal.protein,
                            carbs: meal.carbs,
                            fats: meal.fats
                        )
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(isArabic ? "إضافة كل الوجبات لليوم" : "Log all meals for today")
                            .font(.subheadline.bold())
                        Spacer()
                    }
                }
                .listRowBackground(themeManager.cardBackground)
            }
            
            Section(header: Text(isArabic ? "الوجبات" : "Meals")) {
                ForEach(plan.meals) { meal in
                    NavigationLink {
                        MealDetailsView(meal: NutritionMeal(
                            id: meal.id,
                            name: isArabic ? meal.titleAR : meal.titleEN,
                            calories: meal.calories,
                            protein: meal.protein,
                            carbs: meal.carbs,
                            fat: meal.fats,
                            imageName: nil
                        ))
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.primaryBlue.opacity(0.12))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(AppColors.primaryBlue)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isArabic ? meal.titleAR : meal.titleEN)
                                    .font(.subheadline.bold())
                                    .foregroundColor(themeManager.textPrimary)
                                
                                Text("\(meal.calories) kcal")
                                    .font(.caption)
                                    .foregroundColor(themeManager.textSecondary)
                            }
                        }
                    }
                    .listRowBackground(themeManager.cardBackground)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "الخطة الغذائية" : "Meal plan")
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
        MealPlanView(
            plan: MealPlan.planFor(goal: .improveFitness, calories: 2200)
        )
        .environmentObject(ThemeManager.shared)
        .environmentObject(LanguageManager.shared)
        .environmentObject(NutritionManager.shared)
    }
}
