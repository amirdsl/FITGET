//
//  MealsDatabase.swift
//  FITGET
//
//  Path: FITGET/Services/Nutrition/MealsDatabase.swift
//

import Foundation

enum MealsDatabase {

    // MARK: - Breakfast

    static let breakfastOptions: [NutritionMeal] = [
        NutritionMeal(
            name: "Oats & Banana",
            calories: 350,
            protein: 15,
            carbs: 55,
            fat: 7,
            imageName: "meal_oats_banana"
        ),
        NutritionMeal(
            name: "Greek Yogurt & Berries",
            calories: 280,
            protein: 20,
            carbs: 30,
            fat: 7,
            imageName: "meal_yogurt_berries"
        ),
        NutritionMeal(
            name: "Eggs & Toast",
            calories: 320,
            protein: 22,
            carbs: 28,
            fat: 12,
            imageName: "meal_eggs_toast"
        ),
        NutritionMeal(
            name: "Peanut Butter Sandwich",
            calories: 400,
            protein: 18,
            carbs: 40,
            fat: 18,
            imageName: "meal_pb_sandwich"
        )
    ]

    // MARK: - Lunch

    static let lunchOptions: [NutritionMeal] = [
        NutritionMeal(
            name: "Chicken & Rice",
            calories: 520,
            protein: 40,
            carbs: 60,
            fat: 10,
            imageName: "meal_chicken_rice"
        ),
        NutritionMeal(
            name: "Beef & Potato",
            calories: 600,
            protein: 35,
            carbs: 55,
            fat: 20,
            imageName: "meal_beef_potato"
        ),
        NutritionMeal(
            name: "Tuna Salad",
            calories: 350,
            protein: 30,
            carbs: 18,
            fat: 15,
            imageName: "meal_tuna_salad"
        )
    ]

    // MARK: - Dinner

    static let dinnerOptions: [NutritionMeal] = [
        NutritionMeal(
            name: "Grilled Salmon & Veggies",
            calories: 500,
            protein: 35,
            carbs: 25,
            fat: 23,
            imageName: "meal_salmon"
        ),
        NutritionMeal(
            name: "Chicken Wrap",
            calories: 430,
            protein: 32,
            carbs: 42,
            fat: 12,
            imageName: "meal_chicken_wrap"
        ),
        NutritionMeal(
            name: "Light Cheese Omelette",
            calories: 300,
            protein: 24,
            carbs: 6,
            fat: 18,
            imageName: "meal_omelette"
        )
    ]

    // MARK: - Snacks

    static let snackOptions: [NutritionMeal] = [
        NutritionMeal(
            name: "Protein Shake",
            calories: 180,
            protein: 25,
            carbs: 8,
            fat: 3,
            imageName: "meal_protein_shake"
        ),
        NutritionMeal(
            name: "Apple & Almonds",
            calories: 210,
            protein: 6,
            carbs: 24,
            fat: 11,
            imageName: "meal_apple_almonds"
        ),
        NutritionMeal(
            name: "Nuts Mix",
            calories: 200,
            protein: 6,
            carbs: 8,
            fat: 16,
            imageName: "meal_nuts_mix"
        )
    ]
}
