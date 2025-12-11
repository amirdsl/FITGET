// FILE: PhysioPainHistoryViewModel.swift

import Foundation
import Combine

@MainActor
final class PhysioPainHistoryViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var logs: [PhysioPainLog] = []
    @Published var errorMessage: String?

    private let service = PhysioRemoteService.shared

    func loadLogs(userId: UUID, programId: UUID) {
        Task {
            await fetchLogs(userId: userId, programId: programId)
        }
    }

    private func fetchLogs(userId: UUID, programId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        await service.loadPainLogs(userId: userId, programId: programId)
        logs = service.painLogs
        errorMessage = service.lastError
    }

    func addLog(
        userId: UUID,
        programId: UUID,
        bodyArea: String,
        value: Int
    ) {
        Task {
            let log = PhysioPainLog(
                id: UUID(),
                userId: userId,
                bodyArea: bodyArea,
                value: value,
                programId: programId,
                loggedAt: Date()
            )
            await service.savePainLog(log, userId: userId, programId: programId)
            logs = service.painLogs
            errorMessage = service.lastError
        }
    }
}
