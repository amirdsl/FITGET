//
//  GamificationManager.swift
//  FITGET
//

import Foundation
import Combine

@MainActor
final class GamificationManager: ObservableObject {

    static let shared = GamificationManager()
    private init() {}

    // MARK: - Published State

    @Published private(set) var xp: Int = 0
    @Published private(set) var level: Int = 1
    @Published var completedPhysioPrograms: Int = 0

    // MARK: - XP Logic

    func addXP(_ amount: Int) {
        guard amount > 0 else { return }

        xp += amount
        recalculateLevel()

        print("⭐ XP +\(amount) → total:", xp)
    }

    // MARK: - Level

    private func recalculateLevel() {
        // كل 1000 XP = لفل
        let newLevel = max(1, xp / 1000 + 1)

        if newLevel != level {
            level = newLevel
            print("🚀 Level up →", level)
        }
    }

    // MARK: - Multiplier

    func levelMultiplier() -> Double {
        // مثال: كل لفل +10%
        return 1.0 + (Double(level - 1) * 0.10)
    }
}
