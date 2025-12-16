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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 1. Header الجديد المحسن
                    modernHeaderSection
                    
                    // 2. حالة الاشتراك
                    subscriptionStatusSection
                    
                    // 3. الوصول السريع
                    quickAccessRow

                    // 4. ملخص التقدم
                    progressSection
                    
                    // 5. التمارين المميزة
                    featuredWorkoutsSection
                    
                    // 6. قسم التغذية
                    nutritionSection
                    
                    // 7. التمارين السريعة
                    quickWorkoutsSection
                    
                    // 8. الأقسام والمجتمع
                    sectionsCommunityGrid
                    
                    // 9. التحديات
                    todayChallengesSection
                    
                    // 10. النصائح
                    tipsSection
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 100) // مسافة للتاب بار
            }
        }
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }

    // MARK: - 1. Modern Header Section (Updated)

    private var modernHeaderSection: some View {
        HStack(alignment: .center, spacing: 16) {
            // صورة المستخدم أو الأفاتار
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [themeManager.primary, themeManager.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: themeManager.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text(initialsFromName(isArabic ? "مستخدم" : "User"))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // نصوص الترحيب
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text(greetingSubtitle)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // زر الملف الشخصي (Profile)
            NavigationLink {
                // نربط هنا مباشرة مع ProfileView الجديد
                ProfileView()
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.primary)
                    .padding(8)
                    .background(themeManager.primary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Subscription / Guest status

    private var subscriptionStatusSection: some View {
        let state = subscriptionStore.state

        // Active Subscription
        if state.isSubscriptionActive {
            return AnyView(
                statusCard(
                    icon: "crown.fill",
                    title: isArabic ? "اشتراك مفعل" : "Subscription active",
                    subtitle: state.activePlan?.tier.localizedName ?? (isArabic ? "بريميوم" : "Premium"),
                    trailingText: isArabic ? "المميزات مفتوحة" : "All features unlocked",
                    color: .yellow
                )
            )
        }

        // Guest Mode
        if state.role == .guest, let start = state.guestTrialStart {
            let limit = state.guestTrialDaysLimit
            let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
            let remaining = max(0, limit - days)

            return AnyView(
                HStack(spacing: 0) {
                    statusCard(
                        icon: "clock.badge.exclamationmark",
                        title: isArabic ? "وضع الضيف" : "Guest mode",
                        subtitle: isArabic ? "متبقي \(remaining) يوم" : "\(remaining) days left",
                        trailingText: "",
                        color: .orange
                    )
                    
                    Spacer()
                    
                    NavigationLink {
                        SubscriptionPaywallView()
                            .environmentObject(subscriptionStore)
                            .environmentObject(playerProgress)
                    } label: {
                        Text(isArabic ? "ترقية" : "Upgrade")
                            .font(.caption.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(themeManager.primary)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .padding(.trailing, 12)
                }
                .background(themeManager.cardBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
            )
        }

        // Free Plan
        if state.role == .free {
            return AnyView(
                HStack(spacing: 0) {
                    statusCard(
                        icon: "star.leadinghalf.filled",
                        title: isArabic ? "باقة مجانية" : "Free plan",
                        subtitle: isArabic ? "ترقية لفتح المزيد" : "Upgrade for more",
                        trailingText: "",
                        color: .blue
                    )
                    
                    Spacer()
                    
                    NavigationLink {
                        SubscriptionPaywallView()
                            .environmentObject(subscriptionStore)
                            .environmentObject(playerProgress)
                    } label: {
                        Text(isArabic ? "ترقية" : "Upgrade")
                            .font(.caption.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(themeManager.primary)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .padding(.trailing, 12)
                }
                .background(themeManager.cardBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
            )
        }

        return AnyView(EmptyView())
    }
    
    // Helper for status card content
    private func statusCard(icon: String, title: String, subtitle: String, trailingText: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            if !trailingText.isEmpty {
                Text(trailingText)
                    .font(.caption2.bold())
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    // MARK: - Quick access row

    private var quickAccessRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                quickAccessButton(
                    icon: "figure.strengthtraining.traditional",
                    title: isArabic ? "تمارين" : "Workouts",
                    color: .orange
                ) { ExercisesView() }

                quickAccessButton(
                    icon: "fork.knife",
                    title: isArabic ? "تغذية" : "Nutrition",
                    color: .green
                ) { NutritionView() }

                quickAccessButton(
                    icon: "cart.fill",
                    title: isArabic ? "المتجر" : "Store",
                    color: .blue
                ) { ProgramsCartRootView() }

                quickAccessButton(
                    icon: "chart.bar.fill",
                    title: isArabic ? "تقدمي" : "Progress",
                    color: .purple
                ) { ProgressDashboardView() }
                
                quickAccessButton(
                    icon: "flag.2.crossed.fill",
                    title: isArabic ? "تحديات" : "Challenges",
                    color: .pink
                ) { ChallengesHubView() }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
        }
    }
    
    private func quickAccessButton<Dest: View>(icon: String, title: String, color: Color, destination: @escaping () -> Dest) -> some View {
        NavigationLink(destination: destination()) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textPrimary)
            }
        }
    }

    // MARK: - Progress section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "ملخص يومك" : "Daily Summary")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    NavigationLink { NutritionView() } label: {
                        summaryCard(
                            icon: "flame.fill",
                            title: isArabic ? "سعرات" : "Calories",
                            value: caloriesText,
                            subtitle: "/ \(dailyCaloriesTarget)",
                            color1: .orange,
                            color2: .red
                        )
                    }

                    NavigationLink { ProgressDashboardView() } label: {
                        summaryCard(
                            icon: "figure.walk",
                            title: isArabic ? "خطوات" : "Steps",
                            value: "\(progressManager.todaySteps)",
                            subtitle: isArabic ? "خطوة" : "steps",
                            color1: .blue,
                            color2: .cyan
                        )
                    }

                    NavigationLink { ExercisesView() } label: {
                        summaryCard(
                            icon: "dumbbell.fill",
                            title: isArabic ? "تمارين" : "Workouts",
                            value: workoutsText,
                            subtitle: isArabic ? "منجزة" : "done",
                            color1: .green,
                            color2: .mint
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private func summaryCard(icon: String, title: String, value: String, subtitle: String, color1: Color, color2: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(14)
        .frame(width: 140, height: 110)
        .background(
            LinearGradient(colors: [color1, color2], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(18)
        .shadow(color: color1.opacity(0.3), radius: 6, x: 0, y: 4)
    }

    // MARK: - Featured Workouts

    private var featuredWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isArabic ? "برامج مميزة" : "Featured programs")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Spacer()
                NavigationLink {
                    ExercisesView()
                } label: {
                    Text(isArabic ? "الكل" : "See all")
                        .font(.subheadline)
                        .foregroundColor(themeManager.primary)
                }
            }
            .padding(.horizontal, 4)

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
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Nutrition section

    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(isArabic ? "تغذية اليوم" : "Today’s Nutrition")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Spacer()
                NavigationLink {
                    NutritionView()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundColor(themeManager.textSecondary)
                }
            }

            HStack(spacing: 20) {
                NutritionRingView(
                    consumedCalories: todayMacros.calories,
                    targetCalories: dailyCaloriesTarget
                )
                .frame(width: 100, height: 100)

                VStack(alignment: .leading, spacing: 10) {
                    MacroRow(title: isArabic ? "بروتين" : "Protein", grams: todayMacros.protein, color: .blue)
                    MacroRow(title: isArabic ? "كربوهيدرات" : "Carbs", grams: todayMacros.carbs, color: .orange)
                    MacroRow(title: isArabic ? "دهون" : "Fats", grams: todayMacros.fats, color: .yellow)
                }
            }
            .padding(16)
            .background(themeManager.cardBackground)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Quick Workouts section

    private var quickWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "تمارين سريعة" : "Quick workouts")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickWorkouts) { workout in
                        NavigationLink {
                            ExercisesView()
                        } label: {
                            HomeQuickWorkoutCard(workout: workout, isArabic: isArabic, themeManager: themeManager)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Sections / Community / Challenges / Tips

    private var sectionsCommunityGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "استكشف" : "Explore")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
                .padding(.horizontal, 4)

            HStack(spacing: 12) {
                NavigationLink { ChallengesHubView() } label: {
                    exploreCard(
                        icon: "flag.2.crossed.fill",
                        title: isArabic ? "التحديات" : "Challenges",
                        color: .orange
                    )
                }

                NavigationLink { CommunityView() } label: {
                    exploreCard(
                        icon: "person.2.wave.2.fill",
                        title: isArabic ? "المجتمع" : "Community",
                        color: .cyan
                    )
                }
            }
            
            NavigationLink { MoreSectionsScreen() } label: {
                HStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundColor(.mint)
                    Text(isArabic ? "كل الأقسام والأدوات" : "All sections & tools")
                        .font(.subheadline.bold())
                        .foregroundColor(themeManager.textPrimary)
                    Spacer()
                    Image(systemName: isArabic ? "chevron.left" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(themeManager.cardBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private func exploreCard(icon: String, title: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.headline)
                )
            
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(themeManager.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    private var todayChallengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "التحديات النشطة" : "Active Challenges")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
                .padding(.horizontal, 4)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if challengesManager.activeChallengesCount == 0 {
                        Text(isArabic ? "لا يوجد تحديات حالياً" : "No active challenges")
                            .font(.subheadline)
                            .foregroundColor(themeManager.textPrimary)
                        Text(isArabic ? "انضم لتحدي جديد وابدأ المنافسة!" : "Join a challenge and start competing!")
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    } else {
                        Text(isArabic ? "لديك \(challengesManager.activeChallengesCount) تحديات" : "You have \(challengesManager.activeChallengesCount) challenges")
                            .font(.subheadline.bold())
                            .foregroundColor(themeManager.textPrimary)
                    }
                }
                Spacer()
                
                NavigationLink {
                    ChallengesHubView()
                } label: {
                    Text(isArabic ? "عرض" : "View")
                        .font(.caption.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(themeManager.primary.opacity(0.1))
                        .foregroundColor(themeManager.primary)
                        .cornerRadius(20)
                }
            }
            .padding(16)
            .background(themeManager.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
    }

    private var tipsSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? "نصيحة اليوم" : "Tip of the day")
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.textPrimary)
                Text(
                    isArabic
                    ? "شرب الماء بانتظام يساعد على تحسين الأداء الرياضي وتقليل الإجهاد."
                    : "Regular hydration improves athletic performance and reduces fatigue."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .lineLimit(2)
            }
            Spacer()
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // Helper
    private func initialsFromName(_ name: String) -> String {
        let comps = name.split(separator: " ")
        let letters = comps.prefix(2).compactMap { $0.first }
        return letters.map { String($0) }.joined().uppercased()
    }
}

// MARK: - Subviews & Models

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
            // Background Image Placeholder (Gradient for now)
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primary.opacity(0.8), themeManager.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Content Overlay
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(isArabic ? workout.tagAR : workout.tagEN)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Spacer()

                Text(isArabic ? workout.titleAR : workout.titleEN)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(radius: 2)
            }
            .padding(12)
        }
        .frame(width: 200, height: 130)
        .shadow(color: themeManager.primary.opacity(0.2), radius: 8, x: 0, y: 4)
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
    let themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(themeManager.backgroundColor)
                    .frame(width: 40, height: 40)
                Image(systemName: "play.fill")
                    .font(.caption.bold())
                    .foregroundColor(themeManager.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isArabic ? workout.titleAR : workout.titleEN)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text("\(workout.minutes) min • \(workout.calories) kcal")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding(12)
        .frame(width: 220)
        .background(
            LinearGradient(
                colors: [themeManager.accent, themeManager.primary],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
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
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(grams)g")
                .font(.caption.bold())
                .foregroundColor(.primary)
        }
    }
}

struct NutritionRingView: View {
    let consumedCalories: Int
    let targetCalories: Int

    private var progress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(Double(consumedCalories) / Double(targetCalories), 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.1), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.green, Color.mint]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(consumedCalories)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("kcal")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
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
