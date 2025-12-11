//
//  OnboardingManager.swift
//  FITGET
//
//  Created on 25/11/2025.
//
import Combine
import Foundation

@MainActor
final class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    // MARK: - Published State
    
    @Published var preferences = OnboardingPreferences()
    @Published var hasCompletedOnboarding: Bool = false
    
    // MARK: - Keys
    
    private let completedKey = "onboarding_completed"
    private let prefsKey     = "onboarding_preferences"
    
    // MARK: - Init
    
    private init() {
        load()
    }
    
    // MARK: - Persistence
    
    private func load() {
        let defaults = UserDefaults.standard
        
        hasCompletedOnboarding = defaults.bool(forKey: completedKey)
        
        if let data = defaults.data(forKey: prefsKey),
           let decoded = try? JSONDecoder().decode(OnboardingPreferences.self, from: data) {
            preferences = decoded
        }
    }
    
    private func persist() {
        let defaults = UserDefaults.standard
        
        if let data = try? JSONEncoder().encode(preferences) {
            defaults.set(data, forKey: prefsKey)
        }
        
        defaults.set(hasCompletedOnboarding, forKey: completedKey)
    }
    
    // MARK: - Mutations
    
    func setGoal(_ goal: OnboardingGoal) {
        preferences.goal = goal
        persist()
    }
    
    func setLevel(_ level: FitnessLevel) {
        preferences.level = level
        persist()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        persist()
    }
    
    func resetOnboarding() {
        preferences = OnboardingPreferences()
        hasCompletedOnboarding = false
        persist()
    }
}
