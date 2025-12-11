//
//  Tip.swift
//  FITGET
//
//  Created on 25/11/2025.
//

import Foundation

enum TipCategory: String, CaseIterable, Identifiable, Codable {
    case general
    case nutrition
    case training
    case hydration
    case sleep
    case recovery
    case mindset
    
    var id: String { rawValue }
    
    var titleAR: String {
        switch self {
        case .general:   return "نصائح عامة"
        case .nutrition: return "التغذية"
        case .training:  return "التمرين"
        case .hydration: return "الترطيب"
        case .sleep:     return "النوم"
        case .recovery:  return "الاستشفاء"
        case .mindset:   return "العقلية"
        }
    }
    
    var titleEN: String {
        switch self {
        case .general:   return "General"
        case .nutrition: return "Nutrition"
        case .training:  return "Training"
        case .hydration: return "Hydration"
        case .sleep:     return "Sleep"
        case .recovery:  return "Recovery"
        case .mindset:   return "Mindset"
        }
    }
}

struct Tip: Identifiable, Codable, Hashable {
    let id: UUID
    let titleAR: String
    let titleEN: String
    let bodyAR: String
    let bodyEN: String
    let category: TipCategory
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        titleAR: String,
        titleEN: String,
        bodyAR: String,
        bodyEN: String,
        category: TipCategory,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.titleAR = titleAR
        self.titleEN = titleEN
        self.bodyAR = bodyAR
        self.bodyEN = bodyEN
        self.category = category
        self.createdAt = createdAt
    }
    
    func title(isArabic: Bool) -> String {
        isArabic ? titleAR : titleEN
    }
    
    func body(isArabic: Bool) -> String {
        isArabic ? bodyAR : bodyEN
    }
}
