//
//  NutritionRemoteService.swift
//  FITGET
//
//  Path: FITGET/Services/NutritionRemoteService.swift
//

import Foundation
import Combine

@MainActor
final class NutritionRemoteService: ObservableObject {

    static let shared = NutritionRemoteService()
    private init() {}

    // MARK: - Published State

    @Published var mealPlans: [NutritionMealPlan] = []
    @Published var isLoading: Bool = false
    @Published var lastError: String?

    // MARK: - Injection (Backend / Mock)

    /// لاحقًا سيتم ربطها بـ Supabase
    var fetchMealPlansImpl: (() async throws -> [NutritionMealPlan])?

    // MARK: - Load Meal Plans

    func loadMealPlans() async {
        isLoading = true
        defer { isLoading = false }

        guard let impl = fetchMealPlansImpl else {
            lastError = "Nutrition backend not configured."
            return
        }

        do {
            let result = try await impl()
            mealPlans = result
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }
}
