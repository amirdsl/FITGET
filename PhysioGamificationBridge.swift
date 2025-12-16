//
//  PhysioGamificationBridge.swift
//  FITGET
//

import Foundation

final class PhysioGamificationBridge {

    static let shared = PhysioGamificationBridge()
    private init() {}

    // MARK: - Exercise Completion

    func onExerciseCompleted() {
        let gamification = GamificationManager.shared

        let baseXP = 25
        let multiplier = gamification.levelMultiplier()
        let earnedXP = Int(Double(baseXP) * multiplier)

        gamification.addXP(earnedXP)
    }

    // MARK: - Program Completion

    func onProgramCompleted() {
        let gamification = GamificationManager.shared

        gamification.completedPhysioPrograms += 1

        let baseXP = 250
        let multiplier = gamification.levelMultiplier()
        let earnedXP = Int(Double(baseXP) * multiplier)

        gamification.addXP(earnedXP)
    }
}
