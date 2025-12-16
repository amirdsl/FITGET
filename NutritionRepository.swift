//
//  NutritionRepository.swift
//  FITGET
//

import Foundation
import Supabase
import PostgREST

// MARK: - Models

struct Supplement: Identifiable, Codable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let descriptionEn: String?
    let descriptionAr: String?
    let benefitsEn: String?
    let benefitsAr: String?

    enum CodingKeys: String, CodingKey {
        case id
        case nameEn        = "name_en"
        case nameAr        = "name_ar"
        case descriptionEn = "description_en"
        case descriptionAr = "description_ar"
        case benefitsEn    = "benefits_en"
        case benefitsAr    = "benefits_ar"
    }
}

final class NutritionRepository {
    static let shared = NutritionRepository()
    private init() {}

    private let supabase = SupabaseManager.shared

    // MARK: - Meals
    
    func fetchMeals() async throws -> [NutritionMeal] {
        try await SupabaseManager.shared
            .from("meals")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchMeals(category: String) async throws -> [NutritionMeal] {
        try await SupabaseManager.shared
            .from("meals")
            .select()
            .eq("category", value: category)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Meal Plans
    
    func fetchMealPlans() async throws -> [NutritionMealPlan] {
        try await SupabaseManager.shared
            .from("meal_plans")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Supplements
    
    func fetchSupplements() async throws -> [Supplement] {
        try await SupabaseManager.shared
            .from("supplements")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
