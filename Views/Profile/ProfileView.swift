//
//  ProfileView.swift
//  FITGET
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    private let progressManager = ProgressManager.shared
    private let challengesManager = ChallengesManager.shared
    private let nutritionManager = NutritionManager.shared

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var displayName: String {
        isArabic ? "مستخدم FITGET" : "FITGET user"
    }

    private var subscriptionTitle: String {
        let state = subscriptionStore.state
        if state.isSubscriptionActive {
            return isArabic ? "مشترك بريميوم" : "Premium member"
        }
        switch state.role {
        case .guest:
            return isArabic ? "وضع الضيف" : "Guest mode"
        case .free:
            return isArabic ? "خطة مجانية" : "Free plan"
        default:
            return isArabic ? "مستخدم" : "User"
        }
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    levelAndXPSection
                    activitySection
                    nutritionQuickSection
                    coachSection
                    accountSection
                    appSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(isArabic ? "حسابي" : "My account")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.primary.opacity(0.18),
                                themeManager.accent.opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                Text(initialsFromName(displayName))
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 3)

                Circle()
                    .fill(Color.black.opacity(0.55))
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 4, y: 4)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(displayName)
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                    .lineLimit(1)

                Text(subscriptionTitle)
                    .font(.caption2.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(themeManager.primary.opacity(0.12))
                    .foregroundColor(themeManager.primary)
                    .clipShape(Capsule())

                HStack(spacing: 8) {
                    Label(
                        isArabic ? "سلسلة \(progressManager.currentStreak) يوم" : "\(progressManager.currentStreak)d streak",
                        systemImage: "flame.fill"
                    )
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)

                    Label(
                        "\(playerProgress.totalCoins)",
                        systemImage: "bitcoinsign.circle.fill"
                    )
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(themeManager.cardBackground)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    // MARK: - Level & XP / Coins

    private var levelAndXPSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(isArabic ? "المستوى والتقدم" : "Level & progress")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Spacer()
                Text("Lv \(playerProgress.currentLevel)")
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.primary)
            }

            HStack(spacing: 10) {
                miniStat(
                    icon: "sparkles",
                    titleAR: "الخبرة",
                    titleEN: "XP",
                    value: "\(playerProgress.currentXP)"
                )

                miniStat(
                    icon: "bitcoinsign.circle.fill",
                    titleAR: "العملات",
                    titleEN: "Coins",
                    value: "\(playerProgress.totalCoins)"
                )

                miniStat(
                    icon: "trophy.fill",
                    titleAR: "مستوى عام",
                    titleEN: "Overall",
                    value: levelLabel
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(isArabic ? "التقدم إلى المستوى التالي" : "Progress to next level")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)

                let nextXP = XPRewardEngine.shared.requiredXP(for: playerProgress.currentLevel + 1)
                let current = min(playerProgress.currentXP, nextXP)

                ProgressView(
                    value: Double(current),
                    total: Double(nextXP)
                ) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(current) / \(nextXP) XP")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                }
                .tint(themeManager.primary)
            }
        }
        .padding(14)
        .background(themeManager.cardBackground)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var levelLabel: String {
        let level = playerProgress.currentLevel
        if isArabic {
            switch level {
            case 1..<5:   return "مبتدئ"
            case 5..<10:  return "متقدم"
            default:      return "محترف"
            }
        } else {
            switch level {
            case 1..<5:   return "Beginner"
            case 5..<10:  return "Intermediate"
            default:      return "Advanced"
            }
        }
    }

    // MARK: - Activity

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "نشاطك اليوم" : "Today’s activity")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            HStack(spacing: 12) {
                miniStat(
                    icon: "flame.fill",
                    titleAR: "سلسلة الأيام",
                    titleEN: "Streak",
                    value: "\(progressManager.currentStreak)d"
                )

                miniStat(
                    icon: "figure.walk",
                    titleAR: "خطوات اليوم",
                    titleEN: "Steps",
                    value: "\(progressManager.todaySteps)"
                )

                miniStat(
                    icon: "flag.2.crossed",
                    titleAR: "تحديات نشطة",
                    titleEN: "Challenges",
                    value: "\(challengesManager.activeChallengesCount)"
                )
            }

            HStack(spacing: 12) {
                miniStat(
                    icon: "flame",
                    titleAR: "سعرات اليوم",
                    titleEN: "Calories",
                    value: "\(nutritionManager.todayCalories)"
                )

                miniStat(
                    icon: "dumbbell.fill",
                    titleAR: "تمارين اليوم",
                    titleEN: "Workouts",
                    value: "\(progressManager.todayWorkouts)"
                )
            }
        }
        .padding(14)
        .background(themeManager.cardBackground)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Nutrition quick summary

    private var nutritionQuickSection: some View {
        let target = nutritionManager.targetCalories
        let today = nutritionManager.todayCalories
        let total = max(target, 1)

        return VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "الأهداف الغذائية" : "Nutrition goals")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(isArabic ? "السعرات اليومية" : "Daily calories")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)

                    if target > 0 {
                        Text("\(today) / \(target) kcal")
                            .font(.subheadline.bold())
                            .foregroundColor(themeManager.textPrimary)

                        let remaining = max(target - today, 0)
                        Text(
                            isArabic
                            ? "متبقي \(remaining) سعرة لليوم"
                            : "\(remaining) kcal remaining today"
                        )
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                    } else {
                        Text("\(today) kcal")
                            .font(.subheadline.bold())
                            .foregroundColor(themeManager.textPrimary)

                        Text(
                            isArabic
                            ? "لم يتم تعيين هدف بعد، يمكنك ضبطه من قسم التغذية."
                            : "No target set yet, you can configure it from the Nutrition tab."
                        )
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ProgressView(
                    value: Double(min(today, total)),
                    total: Double(total)
                )
                .tint(themeManager.primary)
                .frame(width: 90)
            }
            .padding(10)
            .background(themeManager.cardBackground.opacity(0.9))
            .cornerRadius(16)
        }
        .padding(14)
        .background(themeManager.cardBackground)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Coach (placeholder)

    private var coachSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "المدرب الشخصي" : "Personal coach")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(themeManager.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(themeManager.primary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? "مدربك في FITGET" : "Your FITGET coach")
                        .font(.subheadline.bold())
                        .foregroundColor(themeManager.textPrimary)

                    Text(
                        isArabic
                        ? "سيتم عرض بيانات المدرب وخططه التي اشتركت بها هنا لاحقاً."
                        : "Coach info and purchased plans will appear here later."
                    )
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
        .padding(14)
        .background(themeManager.cardBackground)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Account / body data

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "الحساب والبيانات" : "Account & data")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text(isArabic ? "حالة الاشتراك" : "Subscription status")
                        .font(.subheadline.bold())
                    Spacer()
                }

                Text(subscriptionDescription())
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }

            Divider()

            if let user = authManager.currentUser {
                VStack(alignment: .leading, spacing: 6) {
                    Text(isArabic ? "بيانات الجسم" : "Body data")
                        .font(.subheadline.bold())
                        .foregroundColor(themeManager.textPrimary)

                    HStack(spacing: 12) {
                        if let age = user.age {
                            bodyChip(
                                title: isArabic ? "العمر" : "Age",
                                value: "\(age)"
                            )
                        }
                        if let h = user.height {
                            bodyChip(
                                title: isArabic ? "الطول" : "Height",
                                value: "\(Int(h)) cm"
                            )
                        }
                        if let w = user.weight {
                            bodyChip(
                                title: isArabic ? "الوزن" : "Weight",
                                value: "\(Int(w)) kg"
                            )
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(themeManager.cardBackground)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - App / settings shortcuts

    private var appSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "إعدادات التطبيق" : "App settings")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            NavigationLink {
                SettingsView()
            } label: {
                settingsRow(
                    icon: "gearshape.fill",
                    titleAR: "الإعدادات",
                    titleEN: "Settings",
                    subtitleAR: "الإشعارات، المظهر، الخصوصية",
                    subtitleEN: "Notifications, appearance, privacy"
                )
            }

            NavigationLink {
                LanguageSettingsView()
            } label: {
                settingsRow(
                    icon: "globe",
                    titleAR: "اللغة",
                    titleEN: "Language",
                    subtitleAR: "التبديل بين العربية والإنجليزية",
                    subtitleEN: "Switch between Arabic & English"
                )
            }
        }
        .padding(14)
        .background(themeManager.cardBackground)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Helpers UI

    private func miniStat(icon: String, titleAR: String, titleEN: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(isArabic ? titleAR : titleEN)
                    .font(.caption2)
            }
            .foregroundColor(themeManager.textSecondary)

            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(themeManager.textPrimary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.cardBackground.opacity(0.9))
        .cornerRadius(14)
    }

    private func bodyChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(themeManager.textSecondary)
            Text(value)
                .font(.caption.bold())
                .foregroundColor(themeManager.textPrimary)
        }
        .padding(8)
        .background(themeManager.cardBackground.opacity(0.9))
        .cornerRadius(12)
    }

    private func settingsRow(icon: String,
                             titleAR: String,
                             titleEN: String,
                             subtitleAR: String,
                             subtitleEN: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(themeManager.primary.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? titleAR : titleEN)
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.textPrimary)
                Text(isArabic ? subtitleAR : subtitleEN)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }

            Spacer()

            Image(systemName: isArabic ? "chevron.left" : "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
    }

    private func initialsFromName(_ name: String) -> String {
        let comps = name.split(separator: " ")
        let letters = comps.prefix(2).compactMap { $0.first }
        return letters.map { String($0) }.joined().uppercased()
    }

    private func subscriptionDescription() -> String {
        let state = subscriptionStore.state

        if state.isSubscriptionActive {
            if let plan = state.activePlan {
                let name = plan.tier.localizedName
                return isArabic
                ? "أنت على خطة \(name)، كل المميزات مفتوحة."
                : "You are on the \(name) plan with all features unlocked."
            }
            return isArabic
            ? "اشتراك بريميوم مفعل."
            : "Premium subscription is active."
        }

        switch state.role {
        case .guest:
            return isArabic
            ? "أنت في وضع الضيف، بعض المميزات محدودة. يمكنك إنشاء حساب أو الترقية لاحقاً."
            : "You are in guest mode with limited features. You can create an account or upgrade later."
        case .free:
            return isArabic
            ? "خطة مجانية مع قيود بسيطة. الترقية تفتح البرامج المتقدمة، التحديات الخاصة، ومكافآت إضافية."
            : "Free plan with some limitations. Upgrading unlocks advanced programs, special challenges and extra rewards."
        default:
            return isArabic
            ? "يمكنك إدارة اشتراكك من شاشة المتجر أو إعدادات الحساب."
            : "You can manage your subscription from the shop or account settings."
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(AuthenticationManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
