//
//  MainTabEntryView.swift
//  FITGET
//

import SwiftUI
import Combine

struct MainTabEntryView: View {

    // MARK: - Environment

    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress
    @EnvironmentObject var authSession: AuthSession
    @EnvironmentObject var supabaseAuth: SupabaseAuthService

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var nutritionManager: NutritionManager
    @EnvironmentObject var onboardingManager: OnboardingManager
    @EnvironmentObject var authManager: AuthenticationManager

    // MARK: - Tabs
    /// الرئيسية - التحديات - المدرب - المجتمع - الأقسام
    private enum Tab: Hashable {
        case home
        case challenges
        case coach
        case community
        case sections
    }

    @State private var selectedTab: Tab = .home

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: - Home
            NavigationStack {
                HomeDashboardView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text(isArabic ? "الرئيسية" : "Home")
            }
            .tag(Tab.home)

            // MARK: - Challenges
            NavigationStack {
                ChallengesHubView()
            }
            .tabItem {
                Image(systemName: "flag.2.crossed.fill")
                Text(isArabic ? "التحديات" : "Challenges")
            }
            .tag(Tab.challenges)

            // MARK: - Personal Coach
            NavigationStack {
                PersonalCoachRootView()
            }
            .tabItem {
                Image(systemName: "person.fill.badge.plus")
                Text(isArabic ? "المدرب" : "Coach")
            }
            .tag(Tab.coach)

            // MARK: - Community
            NavigationStack {
                CommunityView()
            }
            .tabItem {
                Image(systemName: "person.2.wave.2.fill")
                Text(isArabic ? "المجتمع" : "Community")
            }
            .tag(Tab.community)

            // MARK: - Sections
            NavigationStack {
                MoreSectionsScreen()
                    .navigationTitle(isArabic ? "الأقسام" : "Sections")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "square.grid.2x2.fill")
                Text(isArabic ? "الأقسام" : "Sections")
            }
            .tag(Tab.sections)
        }
        .tint(themeManager.primary)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
}

// MARK: - Training Root (للاستخدام من الأقسام لاحقاً)

struct TrainingRootView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(isArabic ? "قسم التمارين" : "Training")
                    .font(.title2.bold())
                    .frame(
                        maxWidth: .infinity,
                        alignment: isArabic ? .trailing : .leading
                    )
                    .padding(.horizontal)

                Text(
                    isArabic
                    ? "هنا يمكن عرض برامج التمرين، تمارين اليوم، أو خطة الأسبوع."
                    : "Here you can show workout programs, today's workout, or a weekly plan."
                )
                .font(.footnote)
                .foregroundColor(themeManager.textSecondary)
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "التمارين" : "Training")
    }
}

// MARK: - Shop Root (المتجر / المكملات – من الأقسام)

struct StoreRootView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        VStack(spacing: 0) {
            SupplementsView()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "المتجر" : "Shop")
    }
}

// MARK: - Account Root (الربط مع ProfileView الجديد)

struct AccountRootView: View {
    // هذا الهيكل الآن يعمل كجسر (Bridge)
    // أي مكان في التطبيق يستدعي AccountRootView سيقوم بفتح ProfileView الجديد
    var body: some View {
        ProfileView()
    }
}

// MARK: - Personal Coach Root (شاشة المدرب الشخصي)

struct PersonalCoachRootView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore

    private var isArabic: Bool { languageManager.currentLanguage == "ar" }

    /// هل المستخدم لديه اشتراك يفتح له المدرب؟
    private var hasCoachAccess: Bool {
        let state = subscriptionStore.state
        if state.role == .coach { return true }
        if state.role == .pro { return true }
        if state.isSubscriptionActive { return true }
        return false
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                headerCard

                benefitsSection

                if hasCoachAccess {
                    premiumAccessSection
                } else {
                    upgradeSection
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "المدرب الشخصي" : "Coach")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCard: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    themeManager.primary,
                    themeManager.accent
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 190)
            .cornerRadius(24)
            .shadow(radius: 10)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 70, height: 70)
                        Image(systemName: "person.fill.badge.plus")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(isArabic ? "مدربك الشخصي" : "Your personal coach")
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        Text(
                            isArabic
                            ? "خطط تدريب مخصصة، متابعة أسبوعية، ورسائل مباشرة مع المدرب."
                            : "Custom training plans, weekly check-ins, and direct chat with your coach."
                        )
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.92))
                    }

                    Spacer()
                }

                HStack(spacing: 8) {
                    Label {
                        Text(isArabic ? "خطة خاصة لهدفك" : "Goal-based plan")
                    } icon: {
                        Image(systemName: "target")
                    }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())

                    Label {
                        Text(isArabic ? "متابعة أسبوعية" : "Weekly check-ins")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())
                }
                .foregroundColor(.white)
            }
            .padding()
        }
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isArabic ? "ماذا ستحصل؟" : "What you get")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(spacing: 12) {
                CoachBenefitRow(
                    icon: "list.clipboard.fill",
                    titleAR: "برنامج تدريب مخصص لك",
                    titleEN: "Training plan tailored to you",
                    descriptionAR: "خطة مبنية على هدفك، مستواك، والأدوات المتوفرة لديك.",
                    descriptionEN: "A plan built around your goal, level and available equipment.",
                    themeManager: themeManager,
                    isArabic: isArabic
                )

                CoachBenefitRow(
                    icon: "fork.knife.circle.fill",
                    titleAR: "توجيه غذائي أساسي",
                    titleEN: "Basic nutrition guidance",
                    descriptionAR: "توصيات بالسعرات والتقسيمات اليومية لدعم تقدمك.",
                    descriptionEN: "Calorie and macro guidance to support your progress.",
                    themeManager: themeManager,
                    isArabic: isArabic
                )

                CoachBenefitRow(
                    icon: "bubble.left.and.bubble.right.fill",
                    titleAR: "متابعة ورسائل مع المدرب",
                    titleEN: "Check-ins & messages",
                    descriptionAR: "تقييم أسبوعي للتقدم، مع إمكانية طرح الأسئلة مباشرة.",
                    descriptionEN: "Weekly progress review with direct Q&A.",
                    themeManager: themeManager,
                    isArabic: isArabic
                )
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(radius: 4)
    }

    // MARK: - Premium access

    private var premiumAccessSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isArabic ? "جاهز نبدأ؟" : "Ready to start?")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "بما أنك تملك اشتراكاً مناسباً، يمكنك فتح لوحة المدرب الآن والبدء في أول استبيان إعداد للخطة."
                : "Since you already have an eligible subscription, you can open the coach dashboard now and fill your first setup questionnaire."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            NavigationLink {
                CoachDashboardView()
            } label: {
                HStack {
                    Spacer()
                    Text(isArabic ? "فتح لوحة المدرب" : "Open coach dashboard")
                        .font(.subheadline.bold())
                    Spacer()
                }
                .padding()
                .background(themeManager.primary)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(radius: 4)
    }

    // MARK: - Upgrade section

    private var upgradeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isArabic ? "فعل المدرب الشخصي" : "Activate your personal coach")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "للوصول إلى المدرب الشخصي تحتاج إلى باقة مدفوعة. يمكنك الترقية الآن من داخل التطبيق."
                : "To unlock your personal coach you need an eligible paid plan. You can upgrade now inside the app."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            NavigationLink {
                SubscriptionPaywallView()
                    .environmentObject(subscriptionStore)
            } label: {
                HStack {
                    Spacer()
                    Text(isArabic ? "عرض خطط المدرب" : "View coach plans")
                        .font(.subheadline.bold())
                    Spacer()
                }
                .padding()
                .background(themeManager.primary)
                .foregroundColor(.white)
                .cornerRadius(16)
            }

            Text(
                isArabic
                ? "بعد الاشتراك سيتم فتح لوحة المدرب هنا تلقائيًا."
                : "After subscribing, the coach dashboard will open here automatically."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(radius: 4)
    }
}

// MARK: - Coach benefit row

struct CoachBenefitRow: View {
    let icon: String
    let titleAR: String
    let titleEN: String
    let descriptionAR: String
    let descriptionEN: String
    let themeManager: ThemeManager
    let isArabic: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(themeManager.primary.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? titleAR : titleEN)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)

                Text(isArabic ? descriptionAR : descriptionEN)
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

// MARK: - Coach dashboard placeholder

struct CoachDashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    private var isArabic: Bool { languageManager.currentLanguage == "ar" }

    var body: some View {
        VStack(spacing: 16) {
            Text(isArabic ? "لوحة المدرب" : "Coach dashboard")
                .font(.title2.bold())
                .frame(maxWidth: .infinity,
                       alignment: isArabic ? .trailing : .leading)

            Text(
                isArabic
                ? "هنا سيتم عرض خطة الأسابيع، رسائل المتابعة، والتقييمات القادمة."
                : "Here you will see weekly plan, follow-up messages, and upcoming check-ins."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            Spacer()
        }
        .padding()
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "لوحة المدرب" : "Coach")
    }
}

// MARK: - Programs Cart Root

struct ProgramsCartRootView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore

    private var isArabic: Bool { languageManager.currentLanguage == "ar" }

    var body: some View {
        VStack(spacing: 16) {
            Text(isArabic ? "سلة البرامج والاشتراكات" : "Programs & subscriptions cart")
                .font(.title2.bold())
                .frame(
                    maxWidth: .infinity,
                    alignment: isArabic ? .trailing : .leading
                )
                .padding(.horizontal)

            Text(
                isArabic
                ? "هذه السلة خاصة بخطط التدريب، الكوتش أونلاين، والاشتراكات داخل التطبيق، وليست لمشتريات المكملات."
                : "This cart is dedicated to training plans, online coaching and in-app subscriptions, not supplement purchases."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
            .padding(.horizontal)

            Spacer()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "السلة" : "Cart")
    }
}

#Preview {
    MainTabEntryView()
        .environmentObject(FGSubscriptionStore())
        .environmentObject(PlayerProgress())
        .environmentObject(AuthSession())
        .environmentObject(SupabaseAuthService.shared)
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(NutritionManager.shared)
        .environmentObject(OnboardingManager.shared)
        .environmentObject(AuthenticationManager.shared)
}
