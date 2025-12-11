//
//  WorkoutProgram+AllPrograms.swift
//  FITGET
//

import Foundation

extension WorkoutProgram {

    /// برنامج تجريبي للـ previews فقط
    static let demo = WorkoutProgram(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
        titleEn: "Full Body – Beginner",
        titleAr: "برنامج جسم كامل للمبتدئين",
        focus: "full_body",
        level: "beginner",
        durationMinutes: 30,
        xpReward: 120,
        calories: 220,
        isFeatured: true,
        createdAt: nil
    )
}
