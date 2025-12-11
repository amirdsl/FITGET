//
//  ProgressDashboardView.swift
//  FITGET
//

import SwiftUI

struct ProgressDashboardView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var nutritionManager: NutritionManager
    @EnvironmentObject var playerProgress: PlayerProgress

    // Singletons – كلها بيانات حقيقية من التطبيق
    private let progressManager = ProgressManager.shared
    private let challengesManager = ChallengesManager.shared

    var isArabic: Bool { languageManager.currentLanguage == "ar" }

    // MARK: - Computed

    private var dailyCaloriesTarget: Int {
        let target = nutritionManager.targetCalories
        return target > 0 ? target : 2000   // قيمة افتراضية منطقية
    }

    private var xpNextLevel: Int {
        XPRewardEngine.shared.requiredXP(for: playerProgress.currentLevel + 1)
    }

    private var xpProgressText: String {
        "\(playerProgress.currentXP) / \(xpNextLevel)"
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // Header (Level + XP + Rank)
                    headerCard

                    // شريط الكروت الأفقي (إحصائيات اليوم)
                    statsStrip

                    // عنوان قسم التفاصيل
                    VStack(
                        alignment: isArabic ? .trailing : .leading,
                        spacing: 6
                    ) {
                        Text(isArabic ? "تفاصيل التقدم" : "Progress details")
                            .font(.headline)
                            .foregroundColor(themeManager.textPrimary)

                        Text(
                            isArabic
                            ? "كل الأدوات التي تساعدك على متابعة رحلتك."
                            : "All the tools that help you track your journey."
                        )
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: isArabic ? .trailing : .leading
                    )
                    .padding(.horizontal)

                    // الروابط (نفس الشاشات القديمة لكن بشكل أفضل)
                    NavigationLink(destination: HabitsView()) {
                        progressRow(
                            icon: "checkmark.circle.fill",
                            iconColors: [.purple, .blue],
                            title: isArabic ? "العادات اليومية" : "Daily Habits",
                            subtitle: isArabic ? "نظّم عاداتك وحقق أهدافك" : "Build habits and hit your goals"
                        )
                    }

                    NavigationLink(destination: TrainingPlanView()) {
                        progressRow(
                            icon: "flame.fill",
                            iconColors: [.orange, .pink],
                            title: isArabic ? "التمارين" : "Workouts",
                            subtitle: isArabic ? "خطة تمارينك الأسبوعية" : "Your weekly training plan"
                        )
                    }

                    NavigationLink(destination: ProgramsLibraryView()) {
                        progressRow(
                            icon: "square.grid.2x2.fill",
                            iconColors: [.blue, .cyan],
                            title: isArabic ? "البرامج الجاهزة" : "Programs Library",
                            subtitle: isArabic ? "اختر برنامج يناسب هدفك" : "Choose a program that fits your goal"
                        )
                    }

                    NavigationLink(destination: LeaderboardView()) {
                        progressRow(
                            icon: "trophy.fill",
                            iconColors: [.yellow, .orange],
                            title: isArabic ? "لوحة المتصدرين" : "Leaderboard",
                            subtitle: isArabic ? "قارن مستواك بالآخرين" : "Compare your ranking with others"
                        )
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(isArabic ? "مستوى التقدم" : "Progress")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header card

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            themeManager.primary,
                            themeManager.accent
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isArabic ? "لوحة التقدم" : "Progress dashboard")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.95))

                        Text(
                            isArabic
                            ? "تابع مستواك وإنجازاتك"
                            : "Track your level & achievements"
                        )
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Lv \(playerProgress.currentLevel)")
                            .font(.title.weight(.heavy))
                            .foregroundColor(.white)

                        Text(PlayerRankTitle.title(for: playerProgress.currentLevel))
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Capsule())
                    }
                }

                // XP progress
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("XP")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Text(xpProgressText)
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    ProgressView(
                        value: Double(playerProgress.currentXP),
                        total: Double(xpNextLevel)
                    )
                    .tint(.white)
                }

                // streak / coins / active challenges
                HStack(spacing: 10) {
                    smallPill(
                        icon: "flame.fill",
                        label: isArabic ? "سلسلة الأيام" : "Streak",
                        value: "\(progressManager.currentStreak)d"
                    )
                    smallPill(
                        icon: "bitcoinsign.circle.fill",
                        label: isArabic ? "العملات" : "Coins",
                        value: "\(playerProgress.totalCoins)"
                    )
                    smallPill(
                        icon: "flag.2.crossed",
                        label: isArabic ? "تحديات نشطة" : "Active",
                        value: "\(challengesManager.activeChallengesCount)"
                    )
                }
            }
            .padding(18)
        }
        .padding(.horizontal)
    }

    private func smallPill(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
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

    // MARK: - Horizontal strip

    private var statsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                // Steps
                ProgressWideCard(
                    title: isArabic ? "خطوات اليوم" : "Steps today",
                    value: "\(progressManager.todaySteps)",
                    footer: isArabic ? "هدف يومي 10,000" : "Daily goal 10,000",
                    icon: "figure.walk",
                    gradient: LinearGradient(
                        colors: [Color.blue, Color.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // Challenges
                ProgressWideCard(
                    title: isArabic ? "تحديات نشطة" : "Active challenges",
                    value: "\(challengesManager.activeChallengesCount)",
                    footer: isArabic ? "زد من التحديات للتحفيز" : "Join more challenges for motivation",
                    icon: "trophy.fill",
                    gradient: LinearGradient(
                        colors: [Color.green, Color.mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // Calories
                ProgressWideCard(
                    title: isArabic ? "السعرات اليوم" : "Calories today",
                    value: "\(progressManager.todayCalories)",
                    footer: "\(dailyCaloriesTarget) \(isArabic ? "هدف يومي" : "daily target")",
                    icon: "flame.fill",
                    gradient: LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // Level
                ProgressWideCard(
                    title: isArabic ? "المستوى" : "Level",
                    value: "Lv \(playerProgress.currentLevel)",
                    footer: "XP \(xpProgressText)",
                    icon: "bolt.fill",
                    gradient: LinearGradient(
                        colors: [Color.purple, Color.indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Row builder (الصفوف السفلية)

    private func progressRow(
        icon: String,
        iconColors: [Color],
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                LinearGradient(
                    colors: iconColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title2.bold())
            }

            VStack(
                alignment: isArabic ? .trailing : .leading,
                spacing: 6
            ) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(themeManager.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
}

// MARK: - Wide card used في الشريط الأفقي

struct ProgressWideCard: View {
    let title: String
    let value: String
    let footer: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white.opacity(0.95))
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
            }

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text(footer)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(width: 210, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(gradient)
                .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 6)
        )
    }
}

#Preview {
    NavigationStack {
        ProgressDashboardView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(NutritionManager.shared)
            .environmentObject(PlayerProgress())
    }
}
