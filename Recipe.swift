//
//  Recipe.swift
//  Fitget
//
//  Created on 21/11/2025.
//

import Foundation

struct Recipe: Identifiable, Codable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let descriptionEn: String
    let descriptionAr: String
    let category: String
    let dietType: String
    let difficulty: String
    let prepTime: Int
    let cookTime: Int
    let servings: Int
    let imageUrl: String?
    let ingredientsEn: [String]
    let ingredientsAr: [String]
    let instructionsEn: [String]
    let instructionsAr: [String]
    let calories: Double
    let protein: Double
    let carbs: Double
    let fats: Double
    let fiber: Double?
    let sugar: Double?
    let isPremium: Bool
    let goalType: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameEn = "name_en"
        case nameAr = "name_ar"
        case descriptionEn = "description_en"
        case descriptionAr = "description_ar"
        case category
        case dietType = "diet_type"
        case difficulty
        case prepTime = "prep_time"
        case cookTime = "cook_time"
        case servings
        case imageUrl = "image_url"
        case ingredientsEn = "ingredients_en"
        case ingredientsAr = "ingredients_ar"
        case instructionsEn = "instructions_en"
        case instructionsAr = "instructions_ar"
        case calories, protein, carbs, fats, fiber, sugar
        case isPremium = "is_premium"
        case goalType = "goal_type"
        case createdAt = "created_at"
    }
    
    var totalTime: Int {
        prepTime + cookTime
    }
}

extension Recipe {
    static let samples: [Recipe] = [
        Recipe(
            id: UUID(),
            nameEn: "Grilled Chicken with Quinoa",
            nameAr: "دجاج مشوي مع الكينوا",
            descriptionEn: "High-protein meal perfect for muscle building with balanced macros.",
            descriptionAr: "وجبة عالية البروتين مثالية لبناء العضلات مع توازن غذائي ممتاز.",
            category: "lunch",
            dietType: "high-protein",
            difficulty: "easy",
            prepTime: 10,
            cookTime: 25,
            servings: 2,
            imageUrl: nil,
            ingredientsEn: [
                "2 chicken breasts (200g each)",
                "1 cup quinoa",
                "2 cups chicken broth",
                "1 tbsp olive oil",
                "Mixed vegetables (broccoli, carrots)",
                "Salt, pepper, garlic powder"
            ],
            ingredientsAr: [
                "٢ صدر دجاج (٢٠٠ جرام لكل واحد)",
                "١ كوب كينوا",
                "٢ كوب مرق دجاج",
                "١ ملعقة كبيرة زيت زيتون",
                "خضروات مشكلة (بروكلي، جزر)",
                "ملح، فلفل، بودرة ثوم"
            ],
            instructionsEn: [
                "Season chicken breasts with salt, pepper, and garlic powder",
                "Heat olive oil in pan over medium-high heat",
                "Cook chicken 6-7 minutes per side until golden",
                "Meanwhile, cook quinoa in chicken broth according to package",
                "Steam vegetables until tender",
                "Serve chicken over quinoa with vegetables on side"
            ],
            instructionsAr: [
                "تبّل صدور الدجاج بالملح والفلفل وبودرة الثوم",
                "سخّن زيت الزيتون في مقلاة على نار متوسطة عالية",
                "اطهُ الدجاج 6-7 دقائق لكل جانب حتى يصبح ذهبياً",
                "في نفس الوقت، اطهُ الكينوا في مرق الدجاج حسب التعليمات",
                "اطهُ الخضروات بالبخار حتى تنضج",
                "قدّم الدجاج فوق الكينوا مع الخضروات على الجانب"
            ],
            calories: 450.0,
            protein: 42.0,
            carbs: 38.0,
            fats: 12.0,
            fiber: 5.0,
            sugar: 3.0,
            isPremium: false,
            goalType: "bulk",
            createdAt: Date()
        )
    ]
}
