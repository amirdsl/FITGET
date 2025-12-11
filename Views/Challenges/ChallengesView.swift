//
//  ChallengesView.swift
//  FITGET
//
//  Path: FITGET/Views/Challenges/ChallengesView.swift
//
//  نظام تحديات مع ربط XP / العملات + شكل حديث
//

import SwiftUI

// MARK: - Local Challenge Models

enum FGChallengeFrequency {
    case daily
    case weekly
    case monthly
    case longTerm

    func title(isArabic: Bool) -> String {
        switch self {
        case .daily:   return isArabic ? "تحديات يومية" : "Daily Challenges"
        case .weekly:  return isArabic ? "تحديات أسبوعية" : "Weekly Challenges"
        case .monthly: return isArabic ? "تحديات شهرية" : "Monthly Challenges"
        case .longTerm:return isArabic ? "تحديات طويلة" : "Long-term"
        }
    }
}

enum FGChallengeType {
    case steps
    case calories
    case workouts
    case habits

    func iconName() -> String {
        switch self {
        case .steps:    return "figure.walk"
        case .calories: return "flame.fill"
        case .workouts: return "dumbbell.fill"
        case .habits:   return "checkmark.circle.fill"
        }
    }
}

struct FGChallenge: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var type: FGChallengeType
    var frequency: FGChallengeFrequency
    var targetValue: Int
    var unit: String
    var xpReward: Int
    var coinsReward: Int
    var isPremiumOnly: Bool

    var isJoined: Bool = false
    var isCompleted: Bool = false
}

struct FGChallengeCatalog {

    static func daily(isArabic: Bool) -> [FGChallenge] {
        [
            FGChallenge(
                id: UUID(),
                title: isArabic ? "١٠٬٠٠٠ خطوة اليوم" : "10,000 steps today",
                description: isArabic ? "أكمل ١٠ آلاف خطوة خلال اليوم." : "Reach 10k steps today.",
                type: .steps,
                frequency: .daily,
                targetValue: 10_000,
                unit: isArabic ? "خطوة" : "steps",
                xpReward: 40,
                coinsReward: 2,
                isPremiumOnly: false
            ),
            FGChallenge(
                id: UUID(),
                title: isArabic ? "جلسة تمرين ٢٠ دقيقة" : "20-min workout",
                description: isArabic ? "أكمل أي تمرين لمدة ٢٠ دقيقة على الأقل." : "Complete any 20-min workout.",
                type: .workouts,
                frequency: .daily,
                targetValue: 20,
                unit: isArabic ? "دقيقة" : "min",
                xpReward: 35,
                coinsReward: 2,
                isPremiumOnly: false
            )
        ]
    }

    static func weekly(isArabic: Bool) -> [FGChallenge] {
        [
            FGChallenge(
                id: UUID(),
                title: isArabic ? "٤ جلسات تمرين هذا الأسبوع" : "4 workouts this week",
                description: isArabic ? "أنجز ٤ تمارين مختلفة خلال الأسبوع." : "Finish 4 workouts this week.",
                type: .workouts,
                frequency: .weekly,
                targetValue: 4,
                unit: isArabic ? "جلسة" : "sessions",
                xpReward: 120,
                coinsReward: 8,
                isPremiumOnly: false   // ✅ جميع التحديات مجانية
            ),
            FGChallenge(
                id: UUID(),
                title: isArabic ? "٧ أيام عادات صحية" : "7-day habit streak",
                description: isArabic ? "حافظ على إنجاز عاداتك الصحية كل يوم." : "Maintain your healthy habits every day.",
                type: .habits,
                frequency: .weekly,
                targetValue: 7,
                unit: isArabic ? "يوم" : "days",
                xpReward: 140,
                coinsReward: 10,
                isPremiumOnly: false   // ✅ مجاني
            )
        ]
    }

    static func monthly(isArabic: Bool) -> [FGChallenge] {
        [
            FGChallenge(
                id: UUID(),
                title: isArabic ? "١٠٠ ألف خطوة في الشهر" : "100k steps in a month",
                description: isArabic ? "اجمع ١٠٠ ألف خطوة خلال ٣٠ يوم." : "Reach 100k steps within 30 days.",
                type: .steps,
                frequency: .monthly,
                targetValue: 100_000,
                unit: isArabic ? "خطوة" : "steps",
                xpReward: 600,
                coinsReward: 30,
                isPremiumOnly: false   // ✅ مجاني
            )
        ]
    }

    static func longTerm(isArabic: Bool) -> [FGChallenge] {
        [
            FGChallenge(
                id: UUID(),
                title: isArabic ? "تحدي ٩٠ يوم تغيير جسم" : "90-day body transformation",
                description: isArabic ? "التزام ببرنامج تدريب وتغذية لمدة ٩٠ يوم." : "Follow a training & nutrition plan for 90 days.",
                type: .workouts,
                frequency: .longTerm,
                targetValue: 90,
                unit: isArabic ? "يوم" : "days",
                xpReward: 1500,
                coinsReward: 80,
                isPremiumOnly: false   // ✅ مجاني
            )
        ]
    }
}

// MARK: - ChallengesView

struct ChallengesView: View {

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    // ربط بالتقدم الحقيقي (خطوات، سعرات، تمارين)
    private let progressManager = ProgressManager.shared

    @State private var dailyChallenges: [FGChallenge] = []
    @State private var weeklyChallenges: [FGChallenge] = []
    @State private var monthlyChallenges: [FGChallenge] = []
    @State private var longTermChallenges: [FGChallenge] = []

    @State private var showPaywall: Bool = false   // سيظل موجود لو حبيت ترجع تحديات بريميوم لاحقاً

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var isPremiumUser: Bool {
        subscriptionStore.state.isSubscriptionActive
    }

    // MARK: - Counters (حقيقية من حالة التحديات / XP / Coins)

    private var totalJoinedChallenges: Int {
        (dailyChallenges + weeklyChallenges + monthlyChallenges + longTermChallenges)
            .filter { $0.isJoined }
            .count
    }

    private var totalCompletedChallenges: Int {
        (dailyChallenges + weeklyChallenges + monthlyChallenges + longTermChallenges)
            .filter { $0.isCompleted }
            .count
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    headerCard

                    sectionHeader(title: FGChallengeFrequency.daily.title(isArabic: isArabic))
                    ForEach($dailyChallenges) { $ch in
                        ChallengeCardView(
                            challenge: $ch,
                            isArabic: isArabic,
                            isPremiumUser: isPremiumUser,
                            currentValue: currentValue(for: ch),
                            onPremiumRequested: { showPaywall = true }
                        )
                        .environmentObject(themeManager)
                        .environmentObject(playerProgress)
                    }

                    sectionHeader(title: FGChallengeFrequency.weekly.title(isArabic: isArabic))
                    ForEach($weeklyChallenges) { $ch in
                        ChallengeCardView(
                            challenge: $ch,
                            isArabic: isArabic,
                            isPremiumUser: isPremiumUser,
                            currentValue: currentValue(for: ch),
                            onPremiumRequested: { showPaywall = true }
                        )
                        .environmentObject(themeManager)
                        .environmentObject(playerProgress)
                    }

                    sectionHeader(title: FGChallengeFrequency.monthly.title(isArabic: isArabic))
                    ForEach($monthlyChallenges) { $ch in
                        ChallengeCardView(
                            challenge: $ch,
                            isArabic: isArabic,
                            isPremiumUser: isPremiumUser,
                            currentValue: currentValue(for: ch),
                            onPremiumRequested: { showPaywall = true }
                        )
                        .environmentObject(themeManager)
                        .environmentObject(playerProgress)
                    }

                    sectionHeader(title: FGChallengeFrequency.longTerm.title(isArabic: isArabic))
                    ForEach($longTermChallenges) { $ch in
                        ChallengeCardView(
                            challenge: $ch,
                            isArabic: isArabic,
                            isPremiumUser: isPremiumUser,
                            currentValue: currentValue(for: ch),
                            onPremiumRequested: { showPaywall = true }
                        )
                        .environmentObject(themeManager)
                        .environmentObject(playerProgress)
                    }

                    Spacer(minLength: 16)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "التحديات" : "Challenges")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // تحميل الكتالوج حسب اللغة الحالية
            dailyChallenges    = FGChallengeCatalog.daily(isArabic: isArabic)
            weeklyChallenges   = FGChallengeCatalog.weekly(isArabic: isArabic)
            monthlyChallenges  = FGChallengeCatalog.monthly(isArabic: isArabic)
            longTermChallenges = FGChallengeCatalog.longTerm(isArabic: isArabic)
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primary, themeManager.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.16), radius: 12, x: 0, y: 6)

            VStack(alignment: isArabic ? .trailing : .leading, spacing: 12) {

                HStack(alignment: .top) {
                    VStack(alignment: isArabic ? .trailing : .leading, spacing: 4) {
                        Text(isArabic ? "تحديات FITGET" : "FITGET Challenges")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.95))

                        Text(
                            isArabic
                            ? "ادخل التحديات، اربح XP وعملات، وحرّك مستواك للأعلى."
                            : "Join challenges, earn XP & coins, and push your level higher."
                        )
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(playerProgress.currentXP) XP")
                            .font(.caption.bold())
                            .foregroundColor(.white)

                        Text("\(playerProgress.totalCoins) 🪙")
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.95))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 10) {
                    summaryPill(
                        icon: "person.3.fill",
                        title: isArabic ? "منضم" : "Joined",
                        value: "\(totalJoinedChallenges)"
                    )
                    summaryPill(
                        icon: "checkmark.seal.fill",
                        title: isArabic ? "مكتمل" : "Completed",
                        value: "\(totalCompletedChallenges)"
                    )
                    summaryPill(
                        icon: "bolt.fill",
                        title: isArabic ? "المستوى" : "Level",
                        value: "Lv \(playerProgress.currentLevel)"
                    )
                }
            }
            .padding(16)
        }
    }

    private func summaryPill(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 10))
                Text(value)
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.16))
        .clipShape(Capsule())
        .foregroundColor(.white)
    }

    // MARK: - Section Header

    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            Spacer()
        }
    }

    // MARK: - Helpers

    /// قيمة التقدم الحالية للتحدي بناءً على النوع (خطوات، سعرات، تمارين...)
    private func currentValue(for challenge: FGChallenge) -> Int {
        switch challenge.type {
        case .steps:
            return progressManager.todaySteps                  // بيانات حقيقية من اليوم
        case .calories:
            return progressManager.todayCalories               // إن وجد في ProgressManager
        case .workouts:
            return progressManager.todayWorkouts               // عدد التمارين اليوم
        case .habits:
            // لاحقاً يمكن ربطها بـ HabitsManager، حالياً ٠ لو ما في ربط
            return 0
        }
    }
}

// MARK: - Challenge Card

struct ChallengeCardView: View {

    @Binding var challenge: FGChallenge
    let isArabic: Bool
    let isPremiumUser: Bool
    let currentValue: Int
    let onPremiumRequested: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var playerProgress: PlayerProgress

    private var clampedProgressValue: Int {
        min(currentValue, challenge.targetValue)
    }

    private var progressRatio: Double {
        guard challenge.targetValue > 0 else { return 0 }
        return min(1.0, Double(currentValue) / Double(challenge.targetValue))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // العنوان + الأيقونة
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: challenge.type.iconName())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.subheadline.bold())
                        .foregroundColor(themeManager.textPrimary)

                    Text(challenge.description)
                        .font(.footnote)
                        .foregroundColor(themeManager.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            // الهدف + الجوائز
            HStack(spacing: 8) {
                Text(
                    isArabic
                    ? "الهدف: \(challenge.targetValue) \(challenge.unit)"
                    : "Target: \(challenge.targetValue) \(challenge.unit)"
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)

                Spacer()

                Text("\(challenge.xpReward) XP · \(challenge.coinsReward) 🪙")
                    .font(.caption2.bold())
                    .foregroundColor(themeManager.textSecondary)
            }

            // شريط التقدم الحقيقي من البيانات
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: progressRatio)
                    .tint(.accentColor)

                Text(
                    isArabic
                    ? "التقدم: \(clampedProgressValue) / \(challenge.targetValue) \(challenge.unit)"
                    : "Progress: \(clampedProgressValue) / \(challenge.targetValue) \(challenge.unit)"
                )
                .font(.caption2)
                .foregroundColor(themeManager.textSecondary)
            }

            // أزرار الانضمام / الإكمال
            HStack {
                if challenge.isCompleted {
                    Label(isArabic ? "تم الإنجاز" : "Completed", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                } else if challenge.isJoined {
                    Button {
                        complete()
                    } label: {
                        Text(isArabic ? "تحديد كمكتمل" : "Mark as done")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button {
                        join()
                    } label: {
                        Text(isArabic ? "انضم للتحدي" : "Join challenge")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(themeManager.cardBackground)
                            .foregroundColor(themeManager.textPrimary)
                            .cornerRadius(10)
                    }
                }

                Spacer()
            }
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        .overlay(
            Group {
                if challenge.isPremiumOnly && !isPremiumUser {
                    Color.black.opacity(0.25)
                        .cornerRadius(18)
                        .overlay(
                            Button {
                                onPremiumRequested()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "lock.fill")
                                    Text(isArabic ? "متاح مع بريميوم" : "Premium only")
                                }
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                            }
                        )
                }
            }
        )
    }

    private func join() {
        if challenge.isPremiumOnly && !isPremiumUser {
            onPremiumRequested()
            return
        }
        challenge.isJoined = true
    }

    private func complete() {
        guard !challenge.isCompleted else { return }
        challenge.isCompleted = true

        // ✅ منح XP + Coins من إعدادات التحدي نفسها (ليست أرقام عشوائية)
        playerProgress.addXP(challenge.xpReward)
        playerProgress.addCoins(challenge.coinsReward)
    }
}

#Preview {
    let store = FGSubscriptionStore()
    var state = FGUserSubscriptionState()
    state.role = .free
    store.state = state

    return NavigationStack {
        ChallengesView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(store)
            .environmentObject(PlayerProgress())
    }
}
