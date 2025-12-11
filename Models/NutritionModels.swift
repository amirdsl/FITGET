//
//  NutritionModels.swift
//  FITGET
//
//  Path: FITGET/Models/NutritionModels.swift
//

import Foundation

// MARK: - NutritionMeal

struct NutritionMeal: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let imageName: String?

    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        imageName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.imageName = imageName
    }

    /// ملاءمة للأكواد القديمة التي كانت تستخدم Int
    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fat: Int,
        imageName: String? = nil
    ) {
        self.init(
            id: id,
            name: name,
            calories: calories,
            protein: Double(protein),
            carbs: Double(carbs),
            fat: Double(fat),
            imageName: imageName
        )
    }
}

// MARK: - NutritionMealPlan

struct NutritionMealPlan: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String

    /// إجمالي السعرات في اليوم
    let totalCalories: Int

    /// أهداف الماكروز
    let targetProtein: Double
    let targetCarbs: Double
    let targetFat: Double

    /// الوجبات داخل الخطة
    let meals: [NutritionMeal]

    init(
        id: UUID = UUID(),
        title: String,
        totalCalories: Int,
        targetProtein: Double,
        targetCarbs: Double,
        targetFat: Double,
        meals: [NutritionMeal]
    ) {
        self.id = id
        self.title = title
        self.totalCalories = totalCalories
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFat = targetFat
        self.meals = meals
    }

    /// ملاءمة للأكواد القديمة التي كانت تمرر Int
    init(
        id: UUID = UUID(),
        title: String,
        totalCalories: Int,
        targetProtein: Int,
        targetCarbs: Int,
        targetFat: Int,
        meals: [NutritionMeal]
    ) {
        self.init(
            id: id,
            title: title,
            totalCalories: totalCalories,
            targetProtein: Double(targetProtein),
            targetCarbs: Double(targetCarbs),
            targetFat: Double(targetFat),
            meals: meals
        )
    }
}
