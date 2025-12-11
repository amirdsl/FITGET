//
//  ProgramsView.swift
//  FITGET
//
//  شاشة البرامج الجاهزة (برامج مدفوعة بأسعار مخفضة)
//

import SwiftUI
import Combine

struct ProgramsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // ViewModel جاهز لاحقًا للربط مع Supabase / Backend
    @StateObject private var viewModel = ProgramsViewModel()

    @State private var selectedGoal: ProgramGoalFilter = .all
    @State private var selectedDifficulty: ProgramDifficultyFilter = .all

    // برنامج نشط حاليًا (Placeholder، لاحقًا نربطه بالتقدم الفعلي)
    @State private var activeProgramID: UUID?

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    filtersSection
                    programsGrid
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(isArabic ? "البرامج الجاهزة" : "Ready programs")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadLocalProgramsIfNeeded()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: isArabic ? .bottomTrailing : .bottomLeading) {
            LinearGradient(
                colors: [
                    themeManager.primary.opacity(0.95),
                    themeManager.primary.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 150)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)

            VStack(alignment: isArabic ? .trailing : .leading, spacing: 8) {
                Text(
                    isArabic
                    ? "برامج جاهزة بأسعار مخفضة"
                    : "Ready-made plans with special prices"
                )
                .font(.title3.bold())
                .foregroundColor(.white)

                Text(
                    isArabic
                    ? "اختر برنامج يناسب هدفك: نزول دهون، بناء عضل، لياقة أو تمارين منزلية."
                    : "Pick a plan that matches your goal: fat loss, muscle gain, fitness or home workouts."
                )
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
        }
    }

    // MARK: - Filters

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "فلترة البرامج" : "Filter programs")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ProgramGoalFilter.allCases, id: \.self) { filter in
                        ProgramFilterChip(
                            title: isArabic ? filter.titleAR : filter.titleEN,
                            isSelected: selectedGoal == filter
                        ) {
                            selectedGoal = filter
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ProgramDifficultyFilter.allCases, id: \.self) { filter in
                        ProgramFilterChip(
                            title: isArabic ? filter.titleAR : filter.titleEN,
                            isSelected: selectedDifficulty == filter
                        ) {
                            selectedDifficulty = filter
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Programs Grid

    private var programsGrid: some View {
        let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ]

        let filtered = viewModel.programs.filter { p in
            (selectedGoal == .all || p.goal == selectedGoal) &&
            (selectedDifficulty == .all || p.difficulty == selectedDifficulty)
        }

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filtered) { program in
                NavigationLink {
                    ProgramDetailsView(
                        program: program,
                        isArabic: isArabic,
                        isActive: activeProgramID == program.id
                    ) { startedProgram in
                        activeProgramID = startedProgram.id
                    }
                } label: {
                    WorkoutProgramCard(
                        program: program,
                        isArabic: isArabic,
                        isActive: activeProgramID == program.id
                    )
                }
                .buttonStyle(.plain)
            }

            if filtered.isEmpty {
                Text(isArabic ? "لا توجد برامج بهذا الفلتر" : "No programs for this filter")
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .gridCellColumns(2)
            }
        }
    }
}

// MARK: - ViewModel (جاهز لربط Supabase لاحقاً)

final class ProgramsViewModel: ObservableObject {
    @Published var programs: [WorkoutProgramInfo] = []

    func loadLocalProgramsIfNeeded() {
        if programs.isEmpty {
            programs = WorkoutProgramInfo.samplePrograms
        }
    }

    // لاحقاً:
    // func loadFromSupabase() async throws { ... }
}

// MARK: - Program Models

enum ProgramGoalFilter: CaseIterable {
    case all
    case loseFat
    case buildMuscle
    case improveFitness
    case home

    var titleAR: String {
        switch self {
        case .all: return "الكل"
        case .loseFat: return "نزول دهون"
        case .buildMuscle: return "بناء عضل"
        case .improveFitness: return "لياقة"
        case .home: return "منزلي"
        }
    }

    var titleEN: String {
        switch self {
        case .all: return "All"
        case .loseFat: return "Fat loss"
        case .buildMuscle: return "Muscle gain"
        case .improveFitness: return "Fitness"
        case .home: return "Home"
        }
    }
}

enum ProgramDifficultyFilter: CaseIterable {
    case all
    case beginner
    case intermediate
    case advanced

    var titleAR: String {
        switch self {
        case .all: return "كل المستويات"
        case .beginner: return "مبتدئ"
        case .intermediate: return "متوسط"
        case .advanced: return "متقدم"
        }
    }

    var titleEN: String {
        switch self {
        case .all: return "All levels"
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

struct WorkoutProgramInfo: Identifiable {
    let id = UUID()

    let nameAR: String
    let nameEN: String
    let subtitleAR: String
    let subtitleEN: String

    let goal: ProgramGoalFilter
    let difficulty: ProgramDifficultyFilter
    let durationWeeks: Int
    let daysPerWeek: Int

    let environment: String    // gym / home / mix
    let imageName: String      // SF Symbol أو اسم صورة من الأصول

    let xpPerSession: Int
    let estimatedCaloriesPerSession: Int

    // تسعير / مونيتيزيشن
    let isPremium: Bool
    let priceCoins: Int?   // سعر بالعملات داخل التطبيق (إن وجد)
    let priceUSD: Double?  // سعر تقريبي حقيقي (اختياري)
}

extension WorkoutProgramInfo {
    static let samplePrograms: [WorkoutProgramInfo] = [
        WorkoutProgramInfo(
            nameAR: "برنامج بناء عضل للمبتدئين",
            nameEN: "Beginner Muscle Builder",
            subtitleAR: "٣ أيام بالأسبوع – جسم كامل",
            subtitleEN: "3 days/week – full body",
            goal: .buildMuscle,
            difficulty: .beginner,
            durationWeeks: 6,
            daysPerWeek: 3,
            environment: "gym",
            imageName: "figure.strengthtraining.traditional",
            xpPerSession: 40,
            estimatedCaloriesPerSession: 250,
            isPremium: true,
            priceCoins: 120,
            priceUSD: 9.99
        ),
        WorkoutProgramInfo(
            nameAR: "حرق دهون سريع",
            nameEN: "Rapid Fat Loss",
            subtitleAR: "٤ أيام – كارديو + مقاومة",
            subtitleEN: "4 days – cardio & strength mix",
            goal: .loseFat,
            difficulty: .intermediate,
            durationWeeks: 8,
            daysPerWeek: 4,
            environment: "gym",
            imageName: "flame.fill",
            xpPerSession: 45,
            estimatedCaloriesPerSession: 350,
            isPremium: true,
            priceCoins: 150,
            priceUSD: 11.99
        ),
        WorkoutProgramInfo(
            nameAR: "لياقة وأداء رياضي",
            nameEN: "Athletic Performance",
            subtitleAR: "٥ أيام – سرعة ورشاقة وقوة",
            subtitleEN: "5 days – agility, speed & power",
            goal: .improveFitness,
            difficulty: .advanced,
            durationWeeks: 8,
            daysPerWeek: 5,
            environment: "gym",
            imageName: "shoeprints.fill",
            xpPerSession: 60,
            estimatedCaloriesPerSession: 400,
            isPremium: true,
            priceCoins: 200,
            priceUSD: 14.99
        ),
        WorkoutProgramInfo(
            nameAR: "تمرين منزلي بدون أدوات",
            nameEN: "No-Equipment Home Workout",
            subtitleAR: "٤ أيام – مناسب للمنزل والسفر",
            subtitleEN: "4 days – perfect for home & travel",
            goal: .home,
            difficulty: .beginner,
            durationWeeks: 4,
            daysPerWeek: 4,
            environment: "home",
            imageName: "house.fill",
            xpPerSession: 30,
            estimatedCaloriesPerSession: 200,
            isPremium: false,
            priceCoins: 0,
            priceUSD: nil
        ),
        WorkoutProgramInfo(
            nameAR: "إعادة تشكيل الجسم",
            nameEN: "Body Recomposition",
            subtitleAR: "٣–٤ أيام – توازن بين العضل والدهون",
            subtitleEN: "3–4 days – balance muscle & fat loss",
            goal: .improveFitness,
            difficulty: .intermediate,
            durationWeeks: 10,
            daysPerWeek: 4,
            environment: "gym",
            imageName: "square.stack.3d.up.fill",
            xpPerSession: 50,
            estimatedCaloriesPerSession: 320,
            isPremium: true,
            priceCoins: 180,
            priceUSD: 13.99
        ),
        WorkoutProgramInfo(
            nameAR: "برنامج Push / Pull / Legs",
            nameEN: "Push / Pull / Legs Split",
            subtitleAR: "٦ أيام – متقدم لبناء العضل",
            subtitleEN: "6 days – advanced hypertrophy split",
            goal: .buildMuscle,
            difficulty: .advanced,
            durationWeeks: 8,
            daysPerWeek: 6,
            environment: "gym",
            imageName: "square.grid.3x3.fill",
            xpPerSession: 70,
            estimatedCaloriesPerSession: 450,
            isPremium: true,
            priceCoins: 220,
            priceUSD: 16.99
        )
    ]
}

// MARK: - UI Components

struct ProgramFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemBackground))
                .foregroundColor(isSelected ? Color.accentColor : Color.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: 1)
                )
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

struct WorkoutProgramCard: View {
    let program: WorkoutProgramInfo
    let isArabic: Bool
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(
                        colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))

                Image(systemName: program.imageName)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color.accentColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if program.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11))
                        Text(isArabic ? "مدفوع" : "Premium")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.45))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(8)
                }

                if isActive {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                        Text(isArabic ? "نشط الآن" : "Active")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
            .frame(height: 80)

            Text(isArabic ? program.nameAR : program.nameEN)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
                .lineLimit(2)

            Text(isArabic ? program.subtitleAR : program.subtitleEN)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Spacer(minLength: 4)

            HStack(spacing: 6) {
                TagPill(text: "\(program.daysPerWeek)x / \(program.durationWeeks)w")
                TagPill(text: difficultyLabel(program.difficulty, isArabic: isArabic))
            }

            HStack {
                Text("~\(program.estimatedCaloriesPerSession) kcal • \(program.xpPerSession) XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                priceView
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func difficultyLabel(_ d: ProgramDifficultyFilter, isArabic: Bool) -> String {
        switch d {
        case .beginner: return isArabic ? "مبتدئ" : "Beginner"
        case .intermediate: return isArabic ? "متوسط" : "Intermediate"
        case .advanced: return isArabic ? "متقدم" : "Advanced"
        case .all: return isArabic ? "كل المستويات" : "All levels"
        }
    }

    @ViewBuilder
    private var priceView: some View {
        if !program.isPremium {
            Text(isArabic ? "مجاني" : "Free")
                .font(.caption2.bold())
                .foregroundColor(.green)
        } else if let coins = program.priceCoins {
            HStack(spacing: 3) {
                Image(systemName: "bitcoinsign.circle.fill")
                Text("\(coins)")
            }
            .font(.caption2.bold())
            .foregroundColor(.orange)
        } else if let price = program.priceUSD {
            Text(String(format: "$%.2f", price))
                .font(.caption2.bold())
                .foregroundColor(.orange)
        }
    }
}

struct TagPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .foregroundColor(.secondary)
            .clipShape(Capsule())
    }
}

// MARK: - Program Details

struct ProgramDetailsView: View {
    let program: WorkoutProgramInfo
    let isArabic: Bool
    let isActive: Bool
    let onStartProgram: (WorkoutProgramInfo) -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var playerProgress: PlayerProgress

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                overview
                weeklyStructure
                xpSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 30)
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "تفاصيل البرنامج" : "Program details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.9), Color.accentColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 190)
            .cornerRadius(24)
            .shadow(radius: 8)

            VStack(spacing: 12) {
                Image(systemName: program.imageName)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                Text(isArabic ? program.nameAR : program.nameEN)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(isArabic ? program.subtitleAR : program.subtitleEN)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                HStack(spacing: 8) {
                    TagPill(text: difficultyLabel)
                    TagPill(text: envLabel)
                    TagPill(text: goalText)
                }

                priceBadge
            }
            .padding(.horizontal, 12)
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "نظرة عامة" : "Overview")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "هذا البرنامج مصمم لدعم هدفك في \(goalTextAR). يمكنك دمجه مع خطة غذائية مناسبة من قسم التغذية للحصول على أفضل نتيجة."
                : "This program is designed to support your \(goalTextEN) goal. Combine it with a proper nutrition plan from the Nutrition section for best results."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(radius: 3)
    }

    private var weeklyStructure: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "هيكلة الأسبوع" : "Weekly structure")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            HStack {
                statRow(
                    titleAR: "مدة البرنامج",
                    titleEN: "Duration",
                    value: "\(program.durationWeeks) \(isArabic ? "أسابيع" : "weeks")"
                )
                Spacer()
                statRow(
                    titleAR: "أيام بالأسبوع",
                    titleEN: "Days / week",
                    value: "\(program.daysPerWeek)"
                )
            }

            HStack {
                statRow(
                    titleAR: "البيئة",
                    titleEN: "Environment",
                    value: envLabel
                )
                Spacer()
                statRow(
                    titleAR: "المستوى",
                    titleEN: "Level",
                    value: difficultyLabel
                )
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(radius: 3)
    }

    private var xpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "نقاط الخبرة والمكافآت" : "XP & rewards")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "كل حصة تدريبية تعطي تقريبًا \(program.xpPerSession) نقطة XP و \(program.estimatedCaloriesPerSession) سعرة حرارية محسوبة. إكمال البرنامج كاملًا يرفع مستواك بشكل ملحوظ."
                : "Each workout session grants around \(program.xpPerSession) XP and burns about \(program.estimatedCaloriesPerSession) kcal. Finishing the full plan will significantly level you up."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            Button {
                onStartProgram(program)
            } label: {
                HStack {
                    Spacer()
                    Text(isActive
                         ? (isArabic ? "هذا هو البرنامج النشط" : "This program is active")
                         : (isArabic ? "بدء هذا البرنامج" : "Start this program")
                    )
                    .font(.subheadline.bold())
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(isActive ? Color.green : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(22)
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(radius: 3)
    }

    private func statRow(titleAR: String, titleEN: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isArabic ? titleAR : titleEN)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(themeManager.textPrimary)
        }
    }

    private var goalTextAR: String {
        switch program.goal {
        case .loseFat: return "نزول الدهون"
        case .buildMuscle: return "بناء العضل"
        case .improveFitness: return "تحسين اللياقة"
        case .home: return "التمرين المنزلي"
        case .all: return "اللياقة العامة"
        }
    }

    private var goalTextEN: String {
        switch program.goal {
        case .loseFat: return "fat loss"
        case .buildMuscle: return "muscle building"
        case .improveFitness: return "fitness"
        case .home: return "home training"
        case .all: return "overall fitness"
        }
    }

    private var goalText: String {
        isArabic ? goalTextAR : goalTextEN
    }

    private var envLabel: String {
        switch program.environment {
        case "home":
            return isArabic ? "منزلي" : "Home"
        case "gym":
            return isArabic ? "نادي" : "Gym"
        default:
            return program.environment
        }
    }

    private var difficultyLabel: String {
        switch program.difficulty {
        case .beginner: return isArabic ? "مبتدئ" : "Beginner"
        case .intermediate: return isArabic ? "متوسط" : "Intermediate"
        case .advanced: return isArabic ? "متقدم" : "Advanced"
        case .all: return isArabic ? "كل المستويات" : "All levels"
        }
    }

    @ViewBuilder
    private var priceBadge: some View {
        if !program.isPremium {
            Text(isArabic ? "برنامج مجاني" : "Free program")
                .font(.caption2.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.green.opacity(0.9))
                .foregroundColor(.white)
                .clipShape(Capsule())
        } else if let coins = program.priceCoins {
            HStack(spacing: 4) {
                Image(systemName: "bitcoinsign.circle.fill")
                Text("\(coins)")
            }
            .font(.caption2.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.45))
            .foregroundColor(.orange)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    NavigationStack {
        ProgramsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
