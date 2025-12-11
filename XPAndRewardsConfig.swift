//
//  XPAndRewardsConfig.swift
//  FITGET
//
//  Path: FITGET/XPAndRewardsConfig.swift
//

import Foundation
import Combine

struct LevelConfig: Codable {
    let level: Int
    let requiredXP: Int
    let title: String
}

enum PlayerRankTitle {
    static func title(for level: Int) -> String {
        switch level {
        case 1...10: return "مبتدئ"
        case 11...30: return "نشط"
        case 31...60: return "متقدم"
        case 61...90: return "محترف"
        case 91...120: return "نخبة"
        case 121...140: return "أسطورة"
        default: return "رياضي"
        }
    }
}

enum RewardEventType {
    case workoutCompleted(durationMinutes: Int)
    case challengeCompleted(difficulty: Int)
    case stepsMilestone(steps: Int)
    case streakDay(count: Int)
    case habitCompleted
}

final class XPRewardEngine {

    static let shared = XPRewardEngine()

    private init() {}

    func xpFor(event: RewardEventType) -> Int {
        switch event {
        case .workoutCompleted(let minutes):
            // مثال: ٣ XP لكل ٥ دقائق – مع حد أدنى ٥ XP
            return max(5, (minutes / 5) * 3)

        case .challengeCompleted(let difficulty):
            // التحديات: XP أعلى حسب الصعوبة ١ إلى ٥
            let base = 50
            return base * max(1, min(difficulty, 5))

        case .stepsMilestone(let steps):
            // كل ١٠٠٠ خطوة = ١٠ XP (كمثال)
            return (steps / 1000) * 10

        case .streakDay(let count):
            // كل يوم متواصل يعطي XP تصاعدي بسيط
            return 5 + (count * 2)

        case .habitCompleted:
            return 5
        }
    }

    func coinsFor(event: RewardEventType) -> Int {
        switch event {
        case .workoutCompleted(let minutes):
            // ١ عملة لكل ٢٠ دقيقة
            return max(1, minutes / 20)

        case .challengeCompleted(let difficulty):
            // ٥ عملات لكل مستوى صعوبة
            return difficulty * 5

        case .stepsMilestone(let steps):
            // عملة لكل ٥٠٠٠ خطوة
            return (steps / 5000)

        case .streakDay(let count):
            // مكافأة كل ٧ أيام استمرارية
            return (count % 7 == 0) ? 10 : 0

        case .habitCompleted:
            return 1
        }
    }

    func requiredXP(for level: Int) -> Int {
        // تصاعد غير خطي للوصول إلى مستوى ١٤٠
        let base: Double = 100
        let factor: Double = 1.08
        let cappedLevel = max(1, min(level, 140))
        let xp = base * pow(factor, Double(cappedLevel - 1))
        return Int(xp.rounded())
    }
}

final class PlayerProgress: ObservableObject, Codable {

    enum CodingKeys: String, CodingKey {
        case currentXP
        case currentLevel
        case totalCoins
    }

    @Published var currentXP: Int
    @Published var currentLevel: Int
    @Published var totalCoins: Int

    private var cancellables = Set<AnyCancellable>()

    init(currentXP: Int = 0, currentLevel: Int = 1, totalCoins: Int = 0) {
        self.currentXP = currentXP
        self.currentLevel = currentLevel
        self.totalCoins = totalCoins
        setupObservers()
    }

    private func setupObservers() {
        // هنا يمكن ربط الحفظ التلقائي بـ UserDefaults أو Supabase
        $currentXP
            .sink { _ in }
            .store(in: &cancellables)

        $currentLevel
            .sink { _ in }
            .store(in: &cancellables)

        $totalCoins
            .sink { _ in }
            .store(in: &cancellables)
    }

    // MARK: - Apply Rewards

    func apply(event: RewardEventType) {
        let xpGain = XPRewardEngine.shared.xpFor(event: event)
        let coinsGain = XPRewardEngine.shared.coinsFor(event: event)
        addXP(xpGain)
        addCoins(coinsGain)
    }

    func addXP(_ amount: Int) {
        guard amount > 0 else { return }
        currentXP += amount
        checkLevelUp()
    }

    private func checkLevelUp() {
        var didLevelUp = false

        while currentLevel < 140 {
            let required = XPRewardEngine.shared.requiredXP(for: currentLevel + 1)
            if currentXP >= required {
                currentLevel += 1
                didLevelUp = true
            } else {
                break
            }
        }

        if didLevelUp {
            // منطق الشارات / إشعارات المستوى الجديد يتم إضافته هنا لاحقاً
        }
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        totalCoins += amount
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard amount > 0, totalCoins >= amount else { return false }
        totalCoins -= amount
        return true
    }

    // MARK: - Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let xp = try container.decode(Int.self, forKey: .currentXP)
        let level = try container.decode(Int.self, forKey: .currentLevel)
        let coins = try container.decode(Int.self, forKey: .totalCoins)

        self.currentXP = xp
        self.currentLevel = level
        self.totalCoins = coins
        self.cancellables = []
        setupObservers()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentXP, forKey: .currentXP)
        try container.encode(currentLevel, forKey: .currentLevel)
        try container.encode(totalCoins, forKey: .totalCoins)
    }
}
