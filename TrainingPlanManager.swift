//
//  TrainingPlanManager.swift
//  Fitget
//
//  Path: Fitget/Managers/Training/TrainingPlanManager.swift
//
//  Created on 23/11/2025.
//

import Combine
import Foundation

struct TrainingDay: Identifiable {
    let id = UUID()
    let dayIndex: Int   // 1..N
    let focus: String   // push / pull / legs / full body ...
    let exercises: [TrainingExercise]
}

struct TrainingExercise: Identifiable {
    let id = UUID()
    let nameEn: String
    let nameAr: String
    let sets: Int
    let reps: String
}

struct TrainingPlan {
    let goal: String
    let fitnessLevel: String
    let daysPerWeek: Int
    let days: [TrainingDay]
}

final class TrainingPlanManager {
    static let shared = TrainingPlanManager()
    
    private init() {}
    
    func generatePlan(goal: String, fitnessLevel: String, daysPerWeek: Int) -> TrainingPlan {
        // نستخدم goal + level لتحديد هيكل الخطة
        let normalizedGoal = goal.lowercased()
        let normalizedLevel = fitnessLevel.lowercased()
        
        var days: [TrainingDay] = []
        
        switch normalizedGoal {
        case "bulk":
            days = generateBulkPlan(level: normalizedLevel, daysPerWeek: daysPerWeek)
        case "cut":
            days = generateCutPlan(level: normalizedLevel, daysPerWeek: daysPerWeek)
        case "strength":
            days = generateStrengthPlan(level: normalizedLevel, daysPerWeek: daysPerWeek)
        default:
            days = generateMaintainPlan(level: normalizedLevel, daysPerWeek: daysPerWeek)
        }
        
        return TrainingPlan(goal: normalizedGoal,
                            fitnessLevel: normalizedLevel,
                            daysPerWeek: daysPerWeek,
                            days: days)
    }
    
    // MARK: - Bulk
    
    private func generateBulkPlan(level: String, daysPerWeek: Int) -> [TrainingDay] {
        // مثال: split بسيط Push / Pull / Legs
        var result: [TrainingDay] = []
        
        let pushExercises = [
            TrainingExercise(nameEn: "Bench Press", nameAr: "بنش برس", sets: 4, reps: "6–8"),
            TrainingExercise(nameEn: "Overhead Press", nameAr: "اوفراهيد برس", sets: 3, reps: "8–10"),
            TrainingExercise(nameEn: "Incline Dumbbell Press", nameAr: "بنش مائل دمبل", sets: 3, reps: "8–10")
        ]
        
        let pullExercises = [
            TrainingExercise(nameEn: "Deadlift", nameAr: "ديد لفت", sets: 3, reps: "5"),
            TrainingExercise(nameEn: "Barbell Row", nameAr: "باربل رو", sets: 3, reps: "8–10"),
            TrainingExercise(nameEn: "Lat Pulldown", nameAr: "سحب أعلى", sets: 3, reps: "10–12")
        ]
        
        let legExercises = [
            TrainingExercise(nameEn: "Squat", nameAr: "سكوات", sets: 4, reps: "6–8"),
            TrainingExercise(nameEn: "Leg Press", nameAr: "ليج برس", sets: 3, reps: "10–12"),
            TrainingExercise(nameEn: "Romanian Deadlift", nameAr: "رومانيان ديد لفت", sets: 3, reps: "8–10")
        ]
        
        let focuses = ["push", "pull", "legs"]
        
        for i in 0..<daysPerWeek {
            let focus = focuses[i % focuses.count]
            switch focus {
            case "push":
                result.append(TrainingDay(dayIndex: i + 1, focus: "push", exercises: pushExercises))
            case "pull":
                result.append(TrainingDay(dayIndex: i + 1, focus: "pull", exercises: pullExercises))
            default:
                result.append(TrainingDay(dayIndex: i + 1, focus: "legs", exercises: legExercises))
            }
        }
        
        return result
    }
    
    // MARK: - Cut
    
    private func generateCutPlan(level: String, daysPerWeek: Int) -> [TrainingDay] {
        var result: [TrainingDay] = []
        
        let fullBody = [
            TrainingExercise(nameEn: "Squat", nameAr: "سكوات", sets: 3, reps: "10–12"),
            TrainingExercise(nameEn: "Push-Up", nameAr: "ضغط", sets: 3, reps: "12–15"),
            TrainingExercise(nameEn: "Row Machine", nameAr: "جهاز التجديف", sets: 3, reps: "12–15")
        ]
        
        let hiit = [
            TrainingExercise(nameEn: "Treadmill Sprints", nameAr: "جري متقطع", sets: 10, reps: "30s ON / 30s OFF"),
            TrainingExercise(nameEn: "Battle Ropes", nameAr: "حبال المقاومة", sets: 6, reps: "20s")
        ]
        
        for i in 0..<daysPerWeek {
            if i % 2 == 0 {
                result.append(TrainingDay(dayIndex: i + 1, focus: "full_body", exercises: fullBody))
            } else {
                result.append(TrainingDay(dayIndex: i + 1, focus: "hiit", exercises: hiit))
            }
        }
        
        return result
    }
    
    // MARK: - Strength
    
    private func generateStrengthPlan(level: String, daysPerWeek: Int) -> [TrainingDay] {
        var result: [TrainingDay] = []
        
        let mainLifts = [
            TrainingExercise(nameEn: "Squat", nameAr: "سكوات", sets: 5, reps: "5"),
            TrainingExercise(nameEn: "Bench Press", nameAr: "بنش برس", sets: 5, reps: "5"),
            TrainingExercise(nameEn: "Deadlift", nameAr: "ديد لفت", sets: 5, reps: "5")
        ]
        
        for i in 0..<daysPerWeek {
            result.append(TrainingDay(dayIndex: i + 1, focus: "strength", exercises: mainLifts))
        }
        
        return result
    }
    
    // MARK: - Maintain
    
    private func generateMaintainPlan(level: String, daysPerWeek: Int) -> [TrainingDay] {
        var result: [TrainingDay] = []
        
        let balanced = [
            TrainingExercise(nameEn: "Goblet Squat", nameAr: "سكوات دمبل أمامي", sets: 3, reps: "10–12"),
            TrainingExercise(nameEn: "Dumbbell Bench Press", nameAr: "بنش دمبل", sets: 3, reps: "10–12"),
            TrainingExercise(nameEn: "Lat Pulldown", nameAr: "سحب أعلى", sets: 3, reps: "10–12")
        ]
        
        for i in 0..<daysPerWeek {
            result.append(TrainingDay(dayIndex: i + 1, focus: "balanced", exercises: balanced))
        }
        
        return result
    }
}
