//
//  PhysioProgressRow.swift
//  FITGET
//

import Foundation

struct PhysioProgressRow: Decodable, Identifiable {
    let id: UUID
    let userId: UUID
    let programId: UUID
    let completedExercises: Int
    let totalExercises: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case programId = "program_id"
        case completedExercises = "completed_exercises"
        case totalExercises = "total_exercises"
    }
}
