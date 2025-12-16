//
//  PhysioDifficulty+UI.swift
//  FITGET
//

import Foundation

extension String {

    func physioDifficultyTitle(isArabic: Bool) -> String {
        switch self {
        case "beginner":
            return isArabic ? "مبتدئ" : "Beginner"
        case "intermediate":
            return isArabic ? "متوسط" : "Intermediate"
        case "advanced":
            return isArabic ? "متقدم" : "Advanced"
        default:
            return ""
        }
    }
}
