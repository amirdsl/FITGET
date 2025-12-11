//
//  NutritionManager.swift
//  FITGET
//
//  Manages daily nutrition stats and calorie targets
//

import Foundation
import Combine

@MainActor
final class NutritionManager: ObservableObject {
    static let shared = NutritionManager()
    
    // MARK: - Published daily stats (اليوم فقط)
    // لاحقًا تُستبدل بقيم من الـ backend
    
    @Published var todayCalories: Int = 0
    @Published var todayProtein: Int = 0
    @Published var todayCarbs: Int = 0
    @Published var todayFats: Int = 0
    
    // MARK: - Calorie target (from calculator)
    
    @Published var targetCalories: Int = 2000
    
    // MARK: - Keys
    
    private let targetKey = "nutrition_target_calories"
    
    // MARK: - Init
    
    private init() {
        load()
    }
    
    // MARK: - Persistence
    
    private func load() {
        let defaults = UserDefaults.standard
        
        let savedTarget = defaults.integer(forKey: targetKey)
        if savedTarget > 0 {
            targetCalories = savedTarget
        }
    }
    
    private func persistTarget() {
        let defaults = UserDefaults.standard
        defaults.set(targetCalories, forKey: targetKey)
    }
    
    // MARK: - API
    
    func setTargetCalories(_ value: Int) {
        targetCalories = max(0, value)
        persistTarget()
    }
    
    /// تسجيل وجبة – هنا فقط تحديث محلي، لاحقًا تربطه بـ backend حقيقي
    func logMeal(calories: Int, protein: Int, carbs: Int, fats: Int) {
        todayCalories += max(0, calories)
        todayProtein  += max(0, protein)
        todayCarbs    += max(0, carbs)
        todayFats     += max(0, fats)
        
        // TODO: ربط مع مزامنة حقيقية مع الـ backend
    }
    
    /// إعادة تعيين أرقام اليوم (مثلاً عند تغيير اليوم أو إعادة مزامنة)
    func resetToday() {
        todayCalories = 0
        todayProtein  = 0
        todayCarbs    = 0
        todayFats     = 0
    }
}
