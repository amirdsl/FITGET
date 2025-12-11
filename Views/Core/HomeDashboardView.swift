//
//  HomeDashboardView.swift
//  FITGET
//

import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var nutritionManager: NutritionManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    // Singletons
    private let progressManager = ProgressManager.shared
    private let challengesManager = ChallengesManager.shared

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // MARK: - Computed values

    private var xpProgressText: String {
        let next = XPRewardEngine.shared.requiredXP(for: playerProgress.currentLevel + 1)
        return "\(playerProgress.currentXP) / \(next)"
    }

    private var caloriesText: String {
        "\(progressManager.todayCalories)"
    }

    private var workoutsText: String {
        "\(progressManager.todayWorkouts)"
    }

    private var dailyCaloriesTarget: Int {
        let target = nutritionManager.targetCalories
        return target > 0 ? target : 2000
    }

    private var todayMacros: MacroBreakdown {
        MacroBreakdown(
            protein: nutritionManager.todayProtein,
            carbs: nutritionManager.todayCarbs,
            fats: nutritionManager.todayFats,
            calories: nutritionManager.todayCalories
        )
    }

    // تمارين مميزة
    private var featuredWorkouts: [FeaturedWorkout] {
        [
            FeaturedWorkout(
                id: UUID(),
                titleAR: "برنامج الجسم الكامل",
                titleEN: "Full body program",
                tagAR: "3 أيام أسبوعياً",
                tagEN: "3 days / week"
            ),
            FeaturedWorkout(
                id: UUID(),
                titleAR: "خطة تضخيم عضلي",
                titleEN: "Muscle gain plan",
                tagAR: "متوسط",
                tagEN: "Intermediate"
            ),
            FeaturedWorkout(
                id: UUID(),
                titleAR: "حرق دهون بالبيت",
                titleEN: "Fat loss at home",
                tagAR: "بدون معدات",
                tagEN: "No equipment"
            )
        ]
    }

    // تمارين سريعة (10–15 دقيقة)
    private var quickWorkouts: [QuickWorkout] {
        [
            QuickWorkout(
                titleAR: "كارديو سريع",
                titleEN: "Quick cardio",
                minutes: 10,
                calories: 80,
                xp: 30
            ),
            QuickWorkout(
                titleAR: "تمرين مكتب",
                titleEN: "Desk mobility",
                minutes: 8,
                calories: 40,
                xp: 20
            ),
            QuickWorkout(
                titleAR: "كور سريع",
                titleEN: "Fast core",
                minutes: 12,
                calories: 90,
                xp: 35
            )
        ]
    }

    private var greetingTitle: String {
        isArabic ? "جاهز نطوّر مستواك؟" : "Ready to level up?"
    }

    private var greetingSubtitle: String {
        isArabic
        ? "خطتك، تمارينك، تغذيتك، وتحدياتك في مكان واحد."
        : "Your plan, workouts, nutrition and challenges in one place."
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    brandHeaderSection
                    subscriptionStatusSection
                    quickAccessRow

                    NavigationLink {
                        AccountRootView()
                    } label: {
                        headerSection
                    }
                    .buttonStyle(.plain)

                    progressSection
                    featuredWorkoutsSection
                    nutritionSection
                    quickWorkoutsSection
                    sectionsCommunityGrid
                    todayChallengesSection
                    tipsSection
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }

    // MARK: - Brand header

    private var brandHeaderSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
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
                    .frame(width: 60, height: 60)

                VStack(spacing: 2) {
                    Text("FG")
                        .font(.title2.weight(.black))
                        .foregroundColor(.white)
                    Text("X")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("FITGET")
                    .font(.headline.weight(.bold))
                    .foregroundColor(themeManager.textPrimary)

                Text(greetingTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)

                Text(greetingSubtitle)
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            NavigationLink {
                AccountRootView()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                    Text(isArabic ? "حسابي" : "Me")
                        .font(.caption)
                }
                .foregroundColor(themeManager.primary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            themeManager.cardBackground,
                            themeManager.cardBackground.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(themeManager.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
    }

    // MARK: - Subscription / Guest status

    private var subscriptionStatusSection: some View {
        let state = subscriptionStore.state

        if state.isSubscriptionActive {
            return AnyView(
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18, weight: .bold))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isArabic ? "اشتراك مفعل" : "Subscription active")
                            .font(.subheadline.bold())
                        Text(state.activePlan?.tier.localizedName ?? (isArabic ? "مشترك" : "Member"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(isArabic ? "استفد من كل الميزات" : "Enjoy all premium features")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .appCardCornerRadius()
            )
        }

        if state.role == .guest, let start = state.guestTrialStart {
            let limit = state.guestTrialDaysLimit
            let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
            let remaining = max(0, limit - days)

            return AnyView(
                HStack(spacing: 12) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.system(size: 18, weight: .bold))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isArabic ? "وضع الضيف" : "Guest mode")
                            .font(.subheadline.bold())
                        Text(isArabic ? "متبقي \(remaining) يوم من التجربة" :
                                "\(remaining) days left in your trial")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    NavigationLink {
                        SubscriptionPaywallView()
                            .environmentObject(subscriptionStore)
                            .environmentObject(playerProgress)
                    } label: {
                        Text(isArabic ? "الترقية" : "Upgrade")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .appCardCornerRadius()
            )
        }

        if state.role == .free {
            return AnyView(
                HStack(spacing: 12) {
                    Image(systemName: "star.leadinghalf.filled")
                        .font(.system(size: 18, weight: .bold))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isArabic ? "وضع مجاني" : "Free plan")
                            .font(.subheadline.bold())
                        Text(isArabic ? "بعض الميزات مقفلة، يمكنك الترقية في أي وقت." :
                                "Some features are locked, you can upgrade anytime.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    NavigationLink {
                        SubscriptionPaywallView()
                            .environmentObject(subscriptionStore)
                            .environmentObject(playerProgress)
                    } label: {
                        Text(isArabic ? "الترقية" : "Upgrade")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .appCardCornerRadius()
            )
        }

        return AnyView(EmptyView())
    }

    // MARK: - Quick access row

    private var quickAccessRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                NavigationLink {
                    ExercisesView()
                } label: {
                    QuickAccessChip(
                        icon: "figure.strengthtraining.traditional",
                        titleAR: "التمارين",
                        titleEN: "Workouts",
                        color: .orange,
                        isArabic: isArabic
                    )
                }

                NavigationLink {
                    NutritionView()
                } label: {
                    QuickAccessChip(
                        icon: "fork.knife.circle",
                        titleAR: "التغذية",
                        titleEN: "Nutrition",
                        color: .green,
                        isArabic: isArabic
                    )
                }

                NavigationLink {
                    ProgramsCartRootView()
                } label: {
                    QuickAccessChip(
                        icon: "cart.fill",
                        titleAR: "السلة",
                        titleEN: "Cart",
                        color: .blue,
                        isArabic: isArabic
                    )
                }

                NavigationLink {
                    ProgressDashboardView()
                } label: {
                    QuickAccessChip(
                        icon: "chart.line.uptrend.xyaxis",
                        titleAR: "التقدم",
                        titleEN: "Progress",
                        color: .purple,
                        isArabic: isArabic
                    )
                }

                NavigationLink {
                    ChallengesHubView()
                } label: {
                    QuickAccessChip(
                        icon: "flag.2.crossed.fill",
                        titleAR: "التحديات",
                        titleEN: "Challenges",
                        color: .pink,
                        isArabic: isArabic
                    )
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Header (XP + Level)

    private var headerSection: some View {
        ZStack {
            AppGradients.royalPower
                .appCardCornerRadius()
                .appShadow(AppShadows.softElevated)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isArabic ? "مستوى التقدم الحالي" : "Current Progress")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("Lv \(playerProgress.currentLevel)")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)

                            Text(PlayerRankTitle.title(for: playerProgress.currentLevel))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("XP")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(playerProgress.currentXP)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                ProgressView(
                    value: Double(playerProgress.currentXP),
                    total: Double(XPRewardEngine.shared.requiredXP(for: playerProgress.currentLevel + 1))
                ) {
                    EmptyView()
                } currentValueLabel: {
                    Text(xpProgressText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .tint(Color.white)
                .padding(.top, 4)

                HStack(spacing: 12) {
                    HomeStatPill(
                        icon: "flame.fill",
                        title: isArabic ? "متتالية الأيام" : "Streak",
                        value: "\(progressManager.currentStreak)d"
                    )
                    HomeStatPill(
                        icon: "bitcoinsign.circle.fill",
                        title: isArabic ? "العملات" : "Coins",
                        value: "\(playerProgress.totalCoins)"
                    )
                    HomeStatPill(
                        icon: "flag.2.crossed",
                        title: isArabic ? "تحديات نشطة" : "Active Challenges",
                        value: "\(challengesManager.activeChallengesCount)"
                    )
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
    }

    // MARK: - Progress section

    private var progressSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {

                NavigationLink {
                    NutritionView()
                } label: {
                    HomeStatCardView(
                        icon: "flame.fill",
                        title: isArabic ? "السعرات اليوم" : "Calories today",
                        value: caloriesText,
                        subtitle: "\(dailyCaloriesTarget) \(isArabic ? "هدف" : "target")",
                        gradient: LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    ProgressDashboardView()
                } label: {
                    HomeStatCardView(
                        icon: "figure.walk",
                        title: isArabic ? "الخطوات اليوم" : "Steps today",
                        value: "\(progressManager.todaySteps)",
                        subtitle: isArabic ? "استمر بالحركة!" : "Keep moving!",
                        gradient: LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    ExercisesView()
                } label: {
                    HomeStatCardView(
                        icon: "figure.strengthtraining.traditional",
                        title: isArabic ? "جلسات اليوم" : "Workouts",
                        value: workoutsText,
                        subtitle: isArabic ? "تمارين منجزة" : "Completed",
                        gradient: LinearGradient(
                            colors: [Color.green, Color.mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Featured Workouts

    private var featuredWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isArabic ? "برامج مميزة" : "Featured programs")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    ExercisesView()
                } label: {
                    Text(isArabic ? "كل التمارين" : "All workouts")
                        .font(.footnote)
                        .foregroundColor(Color.accentColor)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(featuredWorkouts) { workout in
                        NavigationLink {
                            ExercisesView()
                        } label: {
                            FeaturedWorkoutCard(
                                workout: workout,
                                isArabic: isArabic,
                                themeManager: themeManager
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .homeCardStyle()
    }

    // MARK: - Nutrition section

    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isArabic ? "تغذية اليوم" : "Today’s Nutrition")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    NutritionView()
                } label: {
                    Text(isArabic ? "عرض الكل" : "View all")
                        .font(.footnote)
                        .foregroundColor(Color.accentColor)
                }
            }

            HStack(spacing: 16) {
                NutritionRingView(
                    consumedCalories: todayMacros.calories,
                    targetCalories: dailyCaloriesTarget
                )
                .frame(width: 120, height: 120)

                VStack(alignment: .leading, spacing: 8) {
                    MacroRow(
                        title: isArabic ? "بروتين" : "Protein",
                        grams: todayMacros.protein
                    )
                    MacroRow(
                        title: isArabic ? "كربوهيدرات" : "Carbs",
                        grams: todayMacros.carbs
                    )
                    MacroRow(
                        title: isArabic ? "دهون" : "Fats",
                        grams: todayMacros.fats
                    )
                }
            }
            .padding(.top, 4)
        }
        .homeCardStyle()
    }

    // MARK: - Quick Workouts section

    private var quickWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "تمارين سريعة" : "Quick workouts")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickWorkouts) { workout in
                        NavigationLink {
                            ExercisesView()
                        } label: {
                            HomeQuickWorkoutCard(workout: workout, isArabic: isArabic)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .homeCardStyle()
    }

    // MARK: - Sections / Community / Challenges / Tips

    private var sectionsCommunityGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "أهم الأقسام" : "Key sections")
                .font(.headline)

            HStack(spacing: 12) {
                HomeSectionCard(
                    icon: "flag.2.crossed.fill",
                    title: isArabic ? "التحديات" : "Challenges",
                    subtitle: isArabic ? "نافس وارفَع حماسك" : "Compete & stay motivated",
                    tint: .orange,
                    destination: { ChallengesHubView() },
                    themeManager: themeManager
                )

                HomeSectionCard(
                    icon: "person.2.wave.2.fill",
                    title: isArabic ? "المجتمع" : "Community",
                    subtitle: isArabic ? "شارك تقدمك واسأل غيرك" : "Share progress & ask others",
                    tint: .cyan,
                    destination: { CommunityView() },
                    themeManager: themeManager
                )
            }

            HomeSectionCard(
                icon: "square.grid.2x2.fill",
                title: isArabic ? "كل الأقسام" : "All sections",
                subtitle: isArabic ? "أدوات، عادات، متجر، والمزيد" : "Tools, habits, shop & more",
                tint: .mint,
                destination: { MoreSectionsScreen() },
                themeManager: themeManager
            )
            .frame(maxWidth: .infinity)
        }
        .homeCardStyle()
    }

    private var todayChallengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isArabic ? "تحدياتك" : "Your Challenges")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    ChallengesHubView()
                } label: {
                    Text(isArabic ? "عرض التحديات" : "View challenges")
                        .font(.footnote)
                        .foregroundColor(Color.accentColor)
                }
            }

            if challengesManager.activeChallengesCount == 0 {
                Text(
                    isArabic
                    ? "لا يوجد تحديات حالية، جرّب الانضمام لتحدي جديد!"
                    : "No active challenges, try joining a new one!"
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            } else {
                Text(
                    isArabic
                    ? "لديك \(challengesManager.activeChallengesCount) تحديات نشطة."
                    : "You have \(challengesManager.activeChallengesCount) active challenges."
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
        .homeCardStyle()
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isArabic ? "نصائح سريعة" : "Quick Tips")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    TipsView()
                } label: {
                    Text(isArabic ? "المزيد" : "More")
                        .font(.footnote)
                        .foregroundColor(Color.accentColor)
                }
            }

            Text(
                isArabic
                ? "تذكر شرب الماء، الإحماء قبل التمرين، والنوم الجيد لدعم تقدمك."
                : "Remember to hydrate, warm up before workouts, and get quality sleep."
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .homeCardStyle()
    }
}

// MARK: - Featured workout model & card

struct FeaturedWorkout: Identifiable {
    let id: UUID
    let titleAR: String
    let titleEN: String
    let tagAR: String
    let tagEN: String
}

struct FeaturedWorkoutCard: View {
    let workout: FeaturedWorkout
    let isArabic: Bool
    let themeManager: ThemeManager

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            themeManager.primary.opacity(0.95),
                            themeManager.accent.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(isArabic ? workout.tagAR : workout.tagEN)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Text(isArabic ? workout.titleAR : workout.titleEN)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(12)
        }
        .frame(width: 220, height: 140)
        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Quick access chip view

struct QuickAccessChip: View {
    let icon: String
    let titleAR: String
    let titleEN: String
    let color: Color
    let isArabic: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
            Text(isArabic ? titleAR : titleEN)
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}

// MARK: - Helpers

struct HomeStatPill: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 11))
                Text(value)
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.15))
        .clipShape(Capsule())
        .foregroundColor(.white)
    }
}

struct HomeStatCardView: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Text(value)
                .font(.system(size: 22, weight: .bold))
            Text(subtitle)
                .font(.system(size: 11))
        }
        .foregroundColor(.white)
        .padding()
        .frame(width: 160, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(gradient)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
        )
    }
}

struct MacroBreakdown {
    let protein: Int
    let carbs: Int
    let fats: Int
    let calories: Int
}

struct MacroRow: View {
    let title: String
    let grams: Int

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Spacer()
            Text("\(grams) g")
                .font(.system(size: 13, weight: .bold))
        }
    }
}

struct NutritionRingView: View {
    let consumedCalories: Int
    let targetCalories: Int

    private var progress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(Double(consumedCalories) / Double(targetCalories), 1.2)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.green, Color.orange, Color.red]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack {
                Text("\(consumedCalories)")
                    .font(.system(size: 20, weight: .bold))
                Text("kcal")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct QuickWorkout: Identifiable {
    let id = UUID()
    let titleAR: String
    let titleEN: String
    let minutes: Int
    let calories: Int
    let xp: Int
}

struct HomeQuickWorkoutCard: View {
    let workout: QuickWorkout
    let isArabic: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? workout.titleAR : workout.titleEN)
                .font(.system(size: 13, weight: .semibold))
            Text("\(workout.minutes) min • \(workout.calories) kcal • \(workout.xp) XP")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 180, alignment: .leading)
        .homeCardStyle()
    }
}

// كارت عام للأقسام
struct HomeSectionCard<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let destination: () -> Destination
    let themeManager: ThemeManager

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(tint.opacity(0.14))
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(tint)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(themeManager.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func homeCardStyle() -> some View {
        self
            .padding(12)
            .background(Color(.systemBackground))
            .appCardCornerRadius()
            .appShadow(AppShadows.softElevated)
    }
}

#Preview {
    NavigationStack {
        HomeDashboardView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(NutritionManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
