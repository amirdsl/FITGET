//
//  OnboardingModels.swift
//  FITGET
//
//  Created on 25/11/2025.
//

import Foundation

enum OnboardingGoal: String, CaseIterable, Identifiable, Codable {
    case loseFat
    case buildMuscle
    case improveFitness
    
    var id: String { rawValue }
    
    var titleAR: String {
        switch self {
        case .loseFat: return "فقدان الدهون"
        case .buildMuscle: return "بناء العضلات"
        case .improveFitness: return "تحسين اللياقة"
        }
    }
    
    var titleEN: String {
        switch self {
        case .loseFat: return "Lose Fat"
        case .buildMuscle: return "Build Muscle"
        case .improveFitness: return "Improve Fitness"
        }
    }
    
    var descriptionAR: String {
        switch self {
        case .loseFat:
            return "تركيز أكبر على حرق السعرات وتمارين الكارديو مع الحفاظ على العضلات."
        case .buildMuscle:
            return "خطة لزيادة الكتلة العضلية مع تمارين مقاومة وتدرّج بالأوزان."
        case .improveFitness:
            return "تحسين القدرة القلبية والتنفسية والمرونة والنشاط العام."
        }
    }
    
    var descriptionEN: String {
        switch self {
        case .loseFat:
            return "Focus on burning calories and cardio while preserving muscle."
        case .buildMuscle:
            return "Plan to increase muscle mass with progressive resistance training."
        case .improveFitness:
            return "Improve overall cardio, mobility, and daily activity."
        }
    }
}

enum FitnessLevel: String, CaseIterable, Identifiable, Codable {
    case beginner
    case intermediate
    case advanced
    
    var id: String { rawValue }
    
    var titleAR: String {
        switch self {
        case .beginner: return "مبتدئ"
        case .intermediate: return "متوسط"
        case .advanced: return "متقدم"
        }
    }
    
    var titleEN: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    var descriptionAR: String {
        switch self {
        case .beginner:
            return "جديد على التمرين أو متوقف من فترة طويلة."
        case .intermediate:
            return "تتمرن من ٦–١٢ شهر بشكل متقطع أو منتظم."
        case .advanced:
            return "خبرة طويلة في التمرين وترغب في خطط أكثر صعوبة."
        }
    }
    
    var descriptionEN: String {
        switch self {
        case .beginner:
            return "New to training or coming back after a long break."
        case .intermediate:
            return "Training for 6–12 months with some consistency."
        case .advanced:
            return "Experienced lifter looking for tougher programs."
        }
    }
}

struct OnboardingPreferences: Codable {
    var goal: OnboardingGoal?
    var level: FitnessLevel?
}
