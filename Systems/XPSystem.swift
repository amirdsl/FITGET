//
//  XPSystem.swift
//  Fitget
//
//  Created on 20/11/2025.
//

import Foundation

struct XPSystem {
    // حساب XP المكتسب حسب نوع النشاط
    static func xpForWorkout(durationMinutes: Int) -> Int {
        return durationMinutes * 5       // مثال: 5 نقاط لكل دقيقة تمرين
    }
    
    static func xpForChallengeCompleted(difficulty: String) -> Int {
        switch difficulty {
        case "easy": return 50
        case "medium": return 100
        case "hard": return 200
        default: return 50
        }
    }
    
    static func xpForMealLogged() -> Int {
        return 10
    }
    
    static func xpForSteps(steps: Int) -> Int {
        return steps / 500               // كل 500 خطوة = 1 XP (مثال)
    }
    
    // XP المطلوب للمستوى التالي (من 0 إلى 150)
    static func xpForNextLevel(currentLevel: Int) -> Int {
        // صيغة تصاعدية بسيطة
        let base = 100
        return base + (currentLevel * 20)
    }
}
