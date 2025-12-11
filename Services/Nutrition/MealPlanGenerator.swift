//
//  MealPlanGenerator.swift
//  FITGET
//
//  Path: FITGET/Services/Nutrition/MealPlanGenerator.swift
//

import Foundation

enum MealPlanGenerator {

    enum Goal {
        case loseFat
        case maintain
        case buildMuscle
    }

    /// توليد خطة بسيطة من ٤ وجبات (فطور – غداء – عشاء – سناك)
    static func generatePlan(
        title: String,
        dailyCalories: Int,
        goal: Goal
    ) -> NutritionMealPlan {

        // نسب توزيع السعرات بين الوجبات
        let breakfastRatio = 0.25
        let lunchRatio     = 0.30
        let dinnerRatio    = 0.25
        let snacksRatio    = 0.20

        let breakfast = pickClosestMeal(
            from: MealsDatabase.breakfastOptions,
            targetCalories: Int(Double(dailyCalories) * breakfastRatio)
        )
        let lunch = pickClosestMeal(
            from: MealsDatabase.lunchOptions,
            targetCalories: Int(Double(dailyCalories) * lunchRatio)
        )
        let dinner = pickClosestMeal(
            from: MealsDatabase.dinnerOptions,
            targetCalories: Int(Double(dailyCalories) * dinnerRatio)
        )
        let snack = pickClosestMeal(
            from: MealsDatabase.snackOptions,
            targetCalories: Int(Double(dailyCalories) * snacksRatio)
        )

        let meals = [breakfast, lunch, dinner, snack]

        // نحسب الماكروز الفعلية للخطة
        let totalProtein = meals.reduce(0.0) { $0 + $1.protein }
        let totalCarbs   = meals.reduce(0.0) { $0 + $1.carbs }
        let totalFat     = meals.reduce(0.0) { $0 + $1.fat }

        return NutritionMealPlan(
            title: title,
            totalCalories: dailyCalories,
            targetProtein: totalProtein,
            targetCarbs: totalCarbs,
            targetFat: totalFat,
            meals: meals
        )
    }

    // MARK: - Helpers

    private static func pickClosestMeal(
        from meals: [NutritionMeal],
        targetCalories: Int
    ) -> NutritionMeal {
        guard let first = meals.first else {
            // في حالة فشل غير متوقعة نرجع أي وجبة افتراضية
            return NutritionMeal(
                name: "Meal",
                calories: targetCalories,
                protein: 20,
                carbs: 40,
                fat: 10
            )
        }

        return meals.min(by: { mealA, mealB in
            let diffA = abs(mealA.calories - targetCalories)
            let diffB = abs(mealB.calories - targetCalories)
            return diffA < diffB
        }) ?? first
    }
}
