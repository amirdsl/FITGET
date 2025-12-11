//
//  WorkoutLogManager.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import Foundation
import Combine

/// تسجيل جلسات التمرين + ربطها بنظام XP / Coins.
final class WorkoutLogManager: ObservableObject {
    static let shared = WorkoutLogManager()
    
    struct WorkoutEntry: Identifiable, Codable {
        let id: UUID
        let date: Date
        let exerciseName: String
        let sets: Int
        let reps: Int
        let weight: Double
    }
    
    @Published var entries: [WorkoutEntry] = []
    
    private init() { }
    
    /// إضافة جلسة تمرين جديدة + مكافأة XP / Coins.
    func addEntry(
        exerciseName: String,
        sets: Int,
        reps: Int,
        weight: Double
    ) {
        let new = WorkoutEntry(
            id: UUID(),
            date: Date(),
            exerciseName: exerciseName,
            sets: sets,
            reps: reps,
            weight: weight
        )
        entries.insert(new, at: 0)
        
        rewardForWorkout(entry: new)
    }
    
    func removeEntry(_ entry: WorkoutEntry) {
        entries.removeAll { $0.id == entry.id }
    }
    
    // MARK: - Gamification Rewards
    
    /// منطق احتساب XP / Coins من جلسة التمرين.
    /// يمكن تعديل الأرقام لاحقًا لكن المنطق هنا حقيقي مبني على حجم التمرين.
    private func rewardForWorkout(entry: WorkoutEntry) {
        let totalReps = entry.sets * entry.reps
        let volume = Double(totalReps) * entry.weight            // إجمالي "حجم" التمرين
        
        // XP: كل 300 كجم من الحجم ≈ 10 XP، مع حد أدنى 5 XP
        let xpFromVolume = Int(volume / 300.0 * 10.0)
        let xpReward = max(5, xpFromVolume)
        
        // Coins: كل 10 XP تعطي عملة واحدة على الأقل
        let coinsReward = max(1, xpReward / 10)
        
        // ربط مع ProgressManager (نظام التقدم الرئيسي لديك)
        ProgressManager.shared.addRewardXP(xpReward)
        
        // ربط مع GamificationManager للـ Coins (ويمكن الاستفادة من xp داخله لاحقًا)
        GamificationManager.shared.addXP(xpReward)
        GamificationManager.shared.addCoins(coinsReward)
    }
}
