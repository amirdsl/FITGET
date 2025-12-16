//
//  PhysioRecommendationEngine.swift
//  FITGET
//

import Foundation

final class PhysioRecommendationEngine {

    static let shared = PhysioRecommendationEngine()
    private init() {}

    func recommendNextProgram(
        from programs: [PhysioProgram],
        completedProgram: PhysioProgram
    ) -> PhysioProgram? {

        programs.first {
            $0.bodyArea == completedProgram.bodyArea &&
            $0.phase > completedProgram.phase
        }
    }
}
