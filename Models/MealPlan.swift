//
//  MealPlan.swift
//  FITGET
//
//  Path: FITGET/Models/Nutrition/MealPlan.swift
//

import Foundation
import Combine

/// نموذج داخلي خاص بواجهة الخطط الغذائية لتجنب أي تعارض مع MealPlan الموجود داخل NutritionView.
struct FGMealPlan: Identifiable {
    let id = UUID()
    
    // العنوان
    let titleAr: String
    let titleEn: String
    
    // وصف مختصر
    let descriptionAr: String
    let descriptionEn: String
    
    // السعرات اليومية المستهدفة
    let calories: Int
    
    // جدول أسبوعي بسيط (نصوص فقط لعرضها في التفاصيل)
    let weeklyMeals: [String]?
}

// MARK: - عينات جاهزة

extension FGMealPlan {
    static let samplePlans: [FGMealPlan] = [
        FGMealPlan(
            titleAr: "خطة خسارة الوزن",
            titleEn: "Fat Loss Plan",
            descriptionAr: "نظام غذائي بسيط يعتمد على عجز سعرات خفيف موزع على ٣–٤ وجبات.",
            descriptionEn: "A simple calorie deficit plan split into 3–4 meals.",
            calories: 1800,
            weeklyMeals: [
                "اليوم 1: شوفان + دجاج مشوي + سلطة",
                "اليوم 2: بيض + رز + سمك مشوي",
                "اليوم 3: زبادي + بطاطس + دجاج",
                "اليوم 4: شوفان + ديك رومي + خضار",
                "اليوم 5: بيض + رز + لحم مشوي",
                "اليوم 6: شوفان + تونة + سلطة",
                "اليوم 7: وجبة مفتوحة محسوبة السعرات"
            ]
        ),
        FGMealPlan(
            titleAr: "خطة زيادة العضلات",
            titleEn: "Muscle Gain Plan",
            descriptionAr: "خطة تعتمد على زيادة السعرات لبناء الكتلة العضلية مع بروتين عالي.",
            descriptionEn: "Calorie surplus plan with high protein for muscle gaining.",
            calories: 2600,
            weeklyMeals: [
                "اليوم 1: شوفان + بيض + لحم مفروم",
                "اليوم 2: رز + دجاج + خضار",
                "اليوم 3: بطاطس + سمك + سلطة",
                "اليوم 4: مكرونة + صدور دجاج",
                "اليوم 5: رز + لحم + سلطة",
                "اليوم 6: شوفان + لبنة + تونة",
                "اليوم 7: وجبة مفتوحة محسوبة السعرات"
            ]
        )
    ]
}
