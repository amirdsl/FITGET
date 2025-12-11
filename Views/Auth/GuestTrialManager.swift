//
//  GuestTrialManager.swift
//  FITGET
//

import Foundation
import Combine

final class GuestTrialManager: ObservableObject {

    @Published private(set) var isGuestActive: Bool = false
    @Published private(set) var remainingDays: Int = 0

    func update(from state: FGUserSubscriptionState) {
        if state.role == .guest, let start = state.guestTrialStart {
            let limit = state.guestTrialDaysLimit
            let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
            remainingDays = max(0, limit - days)
            isGuestActive = remainingDays > 0
        } else {
            remainingDays = 0
            isGuestActive = false
        }
    }
}
