//
//  MoreSectionsScreen.swift
//  FITGET
//

import SwiftUI

struct MoreSectionsScreen: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    @State private var showPaywall = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // Grid عصري – عمودين
    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 14),
        count: 2
    )

    var body: some View {
        ZStack {
            // خلفية قريبة من الهوية الجديدة
            LinearGradient(
                colors: [
                    themeManager.backgroundColor,
                    themeManager.backgroundColor.opacity(0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    headerCard          // الهيدر + حالة الاشتراك + هوية FITGET
                    featuredRow         // شريط مختارات سريعة (Chips)
                    sectionGrid         // Grid كل الأقسام
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header (هوية + حالة الاشتراك)

    private var headerCard: some View {
        let s = subscriptionStore.state

        let statusText: String = {
            if s.isSubscriptionActive {
                return isArabic ? "اشتراك بريميوم مفعل" : "Premium subscription active"
            }
            if s.role == .guest {
                return isArabic ? "وضع الضيف – ميزات محدودة" : "Guest mode – limited features"
            }
            return isArabic ? "خطة مجانية – بعض الميزات مقفلة" : "Free plan – some features locked"
        }()

        return ZStack {
            // خلفية مزخرفة خفيفة
            RoundedRectangle(cornerRadius: 28)
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
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
                .overlay(
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 120, height: 120)
                            .offset(x: 90, y: -60)

                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 80, height: 80)
                            .offset(x: -80, y: 60)
                    }
                )

            HStack(alignment: .top, spacing: 16) {

                // mini logo / هوية
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 72, height: 72)

                    VStack(spacing: 2) {
                        Text("FG")
                            .font(.title2.weight(.black))
                            .foregroundColor(.white)
                        Text("HUB")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white.opacity(0.92))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(isArabic ? "كل أقسام FITGET" : "All FITGET sections")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)

                    Text(
                        isArabic
                        ? "من هذا الهَب تقدر توصل للتمارين، التغذية، التأهيل، التحديات، المجتمع، المتجر والأدوات من مكان واحد."
                        : "From this hub you can jump to workouts, nutrition, rehab, challenges, community, shop and tools in one place."
                    )
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        Image(systemName: s.isSubscriptionActive
                              ? "crown.fill"
                              : (s.role == .guest ? "clock.badge.exclamationmark" : "star.leadinghalf.filled"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.yellow)

                        Text(statusText)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.white.opacity(0.96))

                        Spacer(minLength: 0)

                        if !s.isSubscriptionActive {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    showPaywall = true
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(isArabic ? "الترقية" : "Upgrade")
                                        .font(.caption.bold())
                                    Image(systemName: "chevron.up.circle.fill")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.22))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
        .frame(height: 180)
    }

    // MARK: - Featured Row (مختارات سريعة / Chips)

    private var featuredRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "مختارات سريعة" : "Quick access")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    featureChip(
                        feature: .account,
                        titleAR: "حسابي",
                        titleEN: "My account",
                        icon: "person.crop.circle",
                        gradient: [.indigo, .purple]
                    )
                    featureChip(
                        feature: .workouts,
                        titleAR: "التمارين",
                        titleEN: "Workouts",
                        icon: "figure.strengthtraining.traditional",
                        gradient: [.orange, .red]
                    )
                    featureChip(
                        feature: .physio,
                        titleAR: "التأهيل",
                        titleEN: "Rehab & physio",
                        icon: "cross.case.fill",
                        gradient: [.pink, .orange]
                    )
                    featureChip(
                        feature: .nutrition,
                        titleAR: "التغذية",
                        titleEN: "Nutrition",
                        icon: "fork.knife.circle.fill",
                        gradient: [.green, .teal]
                    )
                    featureChip(
                        feature: .challenges,
                        titleAR: "التحديات",
                        titleEN: "Challenges",
                        icon: "flag.2.crossed.fill",
                        gradient: [.pink, .purple]
                    )
                    featureChip(
                        feature: .community,
                        titleAR: "المجتمع",
                        titleEN: "Community",
                        icon: "person.3.fill",
                        gradient: [.cyan, .blue]
                    )
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func featureChip(
        feature: MoreFeature,
        titleAR: String,
        titleEN: String,
        icon: String,
        gradient: [Color]
    ) -> some View {
        let locked = isLocked(feature)

        return Group {
            if locked {
                Button { showPaywall = true } label: {
                    chipContent(
                        titleAR: titleAR,
                        titleEN: titleEN,
                        icon: icon,
                        gradient: gradient,
                        locked: true
                    )
                }
            } else {
                NavigationLink {
                    destination(for: feature)
                } label: {
                    chipContent(
                        titleAR: titleAR,
                        titleEN: titleEN,
                        icon: icon,
                        gradient: gradient,
                        locked: false
                    )
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func chipContent(
        titleAR: String,
        titleEN: String,
        icon: String,
        gradient: [Color],
        locked: Bool
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
            Text(isArabic ? titleAR : titleEN)
                .font(.footnote.bold())

            if locked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundColor(.white)
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }

    // MARK: - Section Grid (كل الأقسام)

    private var sectionGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "كل الأقسام" : "All sections")
                .font(.headline)
            .foregroundColor(themeManager.textPrimary)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(allItems) { item in
                    sectionCard(item: item)
                }
            }
        }
    }

    private func sectionCard(item: MoreItem) -> some View {
        let locked = isLocked(item.feature)

        return Group {
            if locked {
                Button { showPaywall = true } label: {
                    cardContent(item: item, locked: true)
                }
            } else {
                NavigationLink {
                    destination(for: item.feature)
                } label: {
                    cardContent(item: item, locked: false)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func cardContent(item: MoreItem, locked: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // أيقونة في مستطيل ملون
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                item.accent.opacity(0.22),
                                item.accent.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: item.systemIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(item.accent)
            }
            .frame(height: 56)

            // العنوان
            Text(isArabic ? item.titleAR : item.titleEN)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(themeManager.textPrimary)
                .lineLimit(1)

            // الوصف
            Text(isArabic ? item.subtitleAR : item.subtitleEN)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            // حالة القفل / الفتح
            HStack(spacing: 4) {
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                    Text(isArabic ? "مقفل – يتطلب بريميوم" : "Locked – Premium")
                        .font(.caption2)
                        .foregroundColor(.orange)
                } else {
                    Text(isArabic ? "دخول القسم" : "Open section")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Image(systemName: isArabic ? "chevron.left" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray.opacity(0.9))
                }
                Spacer()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 6)
        )
    }

    // MARK: - ACCESS CONTROL

    private func isLocked(_ f: MoreFeature) -> Bool {
        let s = subscriptionStore.state

        if s.isSubscriptionActive { return false }

        if s.role == .guest {
            // الضيف: يقدر يدخل على التمارين، التغذية، الإعدادات، اللغة، حسابي، الخطوات، التأهيل
            // أضفنا: قياسات الجسم + اختبارات اللياقة مجاناً للضيف
            return !(f == .steps ||
                     f == .workouts ||
                     f == .nutrition ||
                     f == .settings ||
                     f == .language ||
                     f == .account ||
                     f == .physio ||
                     f == .bodyMeasurements ||
                     f == .fitnessTests)
        }

        if s.role == .free {
            // المجاني: بعض الأقسام المقفلة (مثلاً التحديات، متجر العملات، الكوتش أونلاين، برامج الأداء، الناشئين)
            return (f == .challenges ||
                    f == .coinsShop ||
                    f == .onlineCoaching ||
                    f == .sportsPerformance ||
                    f == .youth)
        }

        return false
    }

    // MARK: - DESTINATIONS

    @ViewBuilder
    private func destination(for f: MoreFeature) -> some View {
        switch f {
        case .steps: StepsTrackerView()
        case .workouts: ExercisesView()
        case .nutrition: NutritionView()
        case .programs: ProgramsView()
        case .mealPlans: MealPlansView()
        case .calories: CalorieCalculatorView()
        case .progress: ProgressDashboardView()
        case .challenges: ChallengesView()
        case .community: CommunityView()
        case .coinsShop: StoreView()          // المتجر الأساسي
        case .cart: CartView()
        case .supplements: SupplementsView()
        case .vitaminPrograms: VitaminProgramsView()
        case .onlineCoaching: OnlineCoachingView()
        case .timer: WorkoutTimerView()
        case .notes: WorkoutNotesView()
        case .tips: TipsView()
        case .settings: SettingsView()
        case .language: LanguageSettingsView()
        case .account: AccountRootView()
        case .physio: PhysioHubView()
        case .sportsPerformance: SportsPerformanceView()
        case .youth: YouthHubView()
        case .fitnessTests: FitnessTestsView()
        case .bodyMeasurements: BodyMeasurementsView()
        }
    }

    // MARK: - DATA (العناصر المعروضة في Grid)

    private var allItems: [MoreItem] {
        [
            // ✅ أول كارت: حسابي
            MoreItem(.account,
                     "حسابي", "My account",
                     "بيانات الجسم، المستوى، التقدم والاشتراك",
                     "Body data, level, progress & subscription",
                     "person.crop.circle", .indigo),

            // Main
            MoreItem(.workouts,
                     "التمارين", "Workouts",
                     "تمارينك وخطط التدريب", "Your workouts & plans",
                     "dumbbell", .orange),

            // التأهيل
            MoreItem(.physio,
                     "التأهيل والعلاج الطبيعي", "Rehab & physio",
                     "برامج علاجية لإصابات الركبة، الكتف، وأسفل الظهر",
                     "Therapeutic programs for knee, shoulder and low back",
                     "cross.case.fill", .pink),

            // الرياضات والأداء
            MoreItem(.sportsPerformance,
                     "أداء الرياضيين", "Sports performance",
                     "برامج خاصة لكرة القدم والرياضات المختلفة",
                     "Sport-specific performance programs",
                     "figure.run", .blue),

            // الناشئين
            MoreItem(.youth,
                     "تدريب الناشئين", "Youth training",
                     "برامج لياقة من ٧ إلى ١٧ سنة",
                     "Youth fitness programs (7–17)",
                     "person.2.fill", .mint),

            // قياسات واختبارات
            MoreItem(.bodyMeasurements,
                     "قياسات الجسم", "Body measurements",
                     "تسجيل الوزن والمقاسات قبل وبعد",
                     "Track body measurements before & after",
                     "ruler", .purple),

            MoreItem(.fitnessTests,
                     "اختبارات اللياقة", "Fitness tests",
                     "قيّم مستواك في السرعة والقوة والتحمل",
                     "Assess your fitness level",
                     "clipboard.checkmark", .teal),

            // Nutrition
            MoreItem(.nutrition,
                     "التغذية", "Nutrition",
                     "الوجبات، الماكروز والسعرات", "Meals, macros & calories",
                     "fork.knife", .green),

            MoreItem(.programs,
                     "البرامج", "Programs",
                     "برامج تدريب جاهزة", "Structured training programs",
                     "square.grid.2x2.fill", .purple),

            MoreItem(.steps,
                     "متتبع الخطوات", "Steps tracker",
                     "تعقب عدد خطواتك اليومية", "Track your daily steps",
                     "figure.walk", .blue),

            // Nutrition extra
            MoreItem(.mealPlans,
                     "خطط غذائية", "Meal plans",
                     "خطط أسبوعية وشهرية", "Weekly & monthly nutrition plans",
                     "list.bullet.rectangle.portrait", .mint),

            MoreItem(.calories,
                     "حاسبة السعرات", "Calorie calculator",
                     "احسب احتياجك اليومي", "Calculate your daily needs",
                     "flame.fill", .red),

            // Progress / challenges
            MoreItem(.progress,
                     "لوحة التقدم", "Progress board",
                     "XP – المستوى – السلسلة", "XP, levels & streaks",
                     "chart.line.uptrend.xyaxis", .cyan),

            MoreItem(.challenges,
                     "التحديات", "Challenges",
                     "تحديات فردية وجماعية", "Individual & group challenges",
                     "trophy.fill", .yellow),

            // Social / coaching
            MoreItem(.community,
                     "المجتمع", "Community",
                     "منشورات وتفاعل مع الآخرين", "Posts and interaction",
                     "person.3.fill", .teal),

            MoreItem(.onlineCoaching,
                     "المدرب الشخصي", "Online coaching",
                     "جلسات مخصصة ومتابعة", "1:1 tailored coaching",
                     "person.fill.questionmark", .indigo),

            // Shop
            MoreItem(.supplements,
                     "المكملات الغذائية", "Supplements",
                     "منتجات – فوائد – الجرعات", "Products, benefits & dosage",
                     "pills.fill", .pink),

            MoreItem(.vitaminPrograms,
                     "برامج الفيتامينات", "Vitamin programs",
                     "خطط حسب الهدف والصحة", "Plans by health & goal",
                     "cross.case", .orange),

            MoreItem(.coinsShop,
                     "متجر العملات", "Coins shop",
                     "شراء عملات وفتح المزايا", "Buy coins and unlock features",
                     "bitcoinsign.circle.fill", .yellow),

            MoreItem(.cart,
                     "سلة المشتريات", "Cart",
                     "العناصر التي أضفتها للشراء", "Items added to your cart",
                     "basket.fill", .green),

            // Tools
            MoreItem(.timer,
                     "مؤقت التمرين", "Workout timer",
                     "إدارة وقت كل مجموعة", "Manage set & rest times",
                     "timer", .orange),

            MoreItem(.notes,
                     "ملاحظات التمرين", "Workout notes",
                     "دوّن ما تشعر به بعد كل حصة", "Log how you feel after each session",
                     "note.text", .brown),

            MoreItem(.tips,
                     "نصائح", "Tips",
                     "نصائح سريعة للتغذية والتمرين", "Quick fitness & nutrition tips",
                     "lightbulb.fill", .yellow),

            // Settings
            MoreItem(.settings,
                     "الإعدادات", "Settings",
                     "الحساب، الأمان، الإشعارات", "Account, security & notifications",
                     "gearshape.fill", .gray),

            MoreItem(.language,
                     "اللغة", "Language",
                     "التبديل بين العربية والإنجليزية", "Switch between Arabic & English",
                     "globe", .teal)
        ]
    }
}

// MARK: - DATA MODELS

enum MoreFeature: Hashable {
    case steps, workouts, nutrition, programs
    case mealPlans, calories
    case progress, challenges
    case community, coinsShop, cart
    case supplements, vitaminPrograms
    case onlineCoaching
    case timer, notes
    case tips
    case settings, language
    case account
    case physio              // قسم التأهيل
    case sportsPerformance   // أداء الرياضيين
    case youth               // تدريب الناشئين
    case fitnessTests        // اختبارات اللياقة
    case bodyMeasurements    // قياسات الجسم
}

struct MoreItem: Identifiable {
    let id = UUID()
    let feature: MoreFeature
    let titleAR: String
    let titleEN: String
    let subtitleAR: String
    let subtitleEN: String
    let systemIcon: String
    let accent: Color

    init(_ feature: MoreFeature,
         _ titleAR: String, _ titleEN: String,
         _ subtitleAR: String, _ subtitleEN: String,
         _ icon: String, _ accent: Color) {
        self.feature = feature
        self.titleAR = titleAR
        self.titleEN = titleEN
        self.subtitleAR = subtitleAR
        self.subtitleEN = subtitleEN
        self.systemIcon = icon
        self.accent = accent
    }
}

#Preview {
    NavigationStack {
        MoreSectionsScreen()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
