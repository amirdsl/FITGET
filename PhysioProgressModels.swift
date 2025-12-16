import Foundation

struct PhysioSession: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let programId: UUID
    let sessionIndex: Int
    let completedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case programId = "program_id"
        case sessionIndex = "session_index"
        case completedAt = "completed_at"
    }
}
