//
//  WorkoutTimerManager.swift
//  FITGET
//
import Combine
import Foundation

enum WorkoutPhase {
    case idle
    case work
    case rest
    case finished
}

final class WorkoutTimerManager: ObservableObject {
    static let shared = WorkoutTimerManager()
    
    @Published var phase: WorkoutPhase = .idle
    @Published var remainingSeconds: Int = 0
    @Published var totalSeconds: Int = 0
    @Published var currentSet: Int = 0
    @Published var totalSets: Int = 0
    
    private var workSeconds: Int = 0
    private var restSeconds: Int = 0
    
    private var timer: AnyCancellable?
    
    private init() { }
    
    func start(work: Int, rest: Int, sets: Int) {
        timer?.cancel()
        
        workSeconds = max(work, 5)
        restSeconds = max(rest, 5)
        totalSets = max(sets, 1)
        currentSet = 1
        phase = .work
        remainingSeconds = workSeconds
        totalSeconds = workSeconds
        
        runTimer()
    }
    
    func pause() {
        timer?.cancel()
    }
    
    func resume() {
        guard phase == .work || phase == .rest else { return }
        runTimer()
    }
    
    func stop() {
        timer?.cancel()
        phase = .idle
        remainingSeconds = 0
        totalSeconds = 0
        currentSet = 0
        totalSets = 0
    }
    
    private func runTimer() {
        timer?.cancel()
        timer = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            advancePhase()
            return
        }
        remainingSeconds -= 1
    }
    
    private func advancePhase() {
        switch phase {
        case .work:
            if currentSet >= totalSets {
                phase = .finished
                timer?.cancel()
            } else {
                phase = .rest
                remainingSeconds = restSeconds
                totalSeconds = restSeconds
            }
        case .rest:
            currentSet += 1
            phase = .work
            remainingSeconds = workSeconds
            totalSeconds = workSeconds
        case .idle, .finished:
            timer?.cancel()
        }
    }
    
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }
}
