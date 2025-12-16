//
//  OnlineCoachingManager.swift
//  FITGET
//
//  Path: FITGET/Managers/Coaching/OnlineCoachingManager.swift
//

import Foundation
import Combine

final class OnlineCoachingManager: ObservableObject {

    static let shared = OnlineCoachingManager()

    @Published private(set) var requests: [OnlineCoachingRequest] = []

    private let storageKey = "fg_online_coaching_requests_v1"
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadFromStorage()
        setupAutoSave()
    }

    // MARK: - Public API

    func createRequest(
        coachName: String,
        coachSpecialty: String,
        goalDescription: String,
        preferredContact: String
    ) {
        let request = OnlineCoachingRequest(
            coachName: coachName,
            coachSpecialty: coachSpecialty,
            goalDescription: goalDescription,
            preferredContact: preferredContact
        )

        requests.insert(request, at: 0)
    }

    func updateStatus(for requestID: UUID, to newStatus: OnlineCoachingRequestStatus) {
        guard let index = requests.firstIndex(where: { $0.id == requestID }) else { return }
        requests[index].status = newStatus
    }

    func deleteRequest(_ requestID: UUID) {
        requests.removeAll { $0.id == requestID }
    }

    func clearAll() {
        requests.removeAll()
    }

    // MARK: - Persistence

    private func setupAutoSave() {
        $requests
            .sink { [weak self] _ in
                self?.saveToStorage()
            }
            .store(in: &cancellables)
    }

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            // أثناء التطوير ممكن تفعيل عينات
            #if DEBUG
            self.requests = []
            #else
            self.requests = []
            #endif
            return
        }

        do {
            let decoded = try JSONDecoder().decode([OnlineCoachingRequest].self, from: data)
            self.requests = decoded
        } catch {
            self.requests = []
        }
    }

    private func saveToStorage() {
        do {
            let data = try JSONEncoder().encode(requests)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // لاحقاً ممكن نرسل الخطأ لـ LoggingService
        }
    }
}
