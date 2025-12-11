//
//  ProgramsLibraryView.swift
//  FITGET
//
//  مكتبة البرامج الجاهزة بهوية FITGET.
//  تحاول جلب البيانات من ProgramsBackendService (workout_programs).
//  لو الخدمة غير مربوطة أو حدث خطأ → تستخدم بيانات محلية تجريبية.
//

import SwiftUI

// MARK: - Models (UI)

struct LibraryProgramItem: Identifiable, Equatable {
    let id: UUID
    let titleAr: String
    let titleEn: String
    let subtitleAr: String
    let subtitleEn: String
    let goal: LibraryProgramGoal
    let level: LibraryProgramLevel
    let weeks: Int
    let daysPerWeek: Int
    let xpPerSession: Int
    let isPremium: Bool
    let tagColor: Color
}

// لتفادي التعارض مع ProgramGoalFilter الموجود في ملفات أخرى
enum LibraryProgramGoal: String, CaseIterable, Identifiable {
    case all
    case buildMuscle
    case loseFat
    case improveFitness
    case home

    var id: String { rawValue }

    var titleAR: String {
        switch self {
        case .all:            return "الكل"
        case .buildMuscle:    return "تضخيم"
        case .loseFat:        return "تنشيف"
        case .improveFitness: return "لياقة"
        case .home:           return "منزلي"
        }
    }

    var titleEN: String {
        switch self {
        case .all:            return "All"
        case .buildMuscle:    return "Build muscle"
        case .loseFat:        return "Fat loss"
        case .improveFitness: return "Fitness"
        case .home:           return "Home"
        }
    }
}

enum LibraryProgramLevel: String, CaseIterable, Identifiable {
    case all
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }

    var titleAR: String {
        switch self {
        case .all:          return "كل المستويات"
        case .beginner:     return "مبتدئ"
        case .intermediate: return "متوسط"
        case .advanced:     return "متقدم"
        }
    }

    var titleEN: String {
        switch self {
        case .all:          return "All levels"
        case .beginner:     return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced:     return "Advanced"
        }
    }
}

struct ProgramsLibraryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var selectedGoal: LibraryProgramGoal = .all
    @State private var selectedLevel: LibraryProgramLevel = .all

    @State private var programs: [LibraryProgramItem] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private var isArabic: Bool { languageManager.currentLanguage == "ar" }

    // MARK: - بيانات تجريبية (fallback لو الباك إند غير جاهز)

    private var fallbackPrograms: [LibraryProgramItem] {
        [
            LibraryProgramItem(
                id: UUID(),
                titleAr: "برنامج تضخيم الجسم الكامل",
                titleEn: "Full-Body Mass Builder",
                subtitleAr: "٣ أيام في الأسبوع • أجهزة كاملة",
                subtitleEn: "3 days/week • Full gym",
                goal: .buildMuscle,
                level: .beginner,
                weeks: 6,
                daysPerWeek: 3,
                xpPerSession: 60,
                isPremium: false,
                tagColor: .purple
            ),
            LibraryProgramItem(
                id: UUID(),
                titleAr: "حرق دهون منزلي بدون معدات",
                titleEn: "Home Fat Loss – No Equipment",
                subtitleAr: "٤ أيام في الأسبوع • بالبيت",
                subtitleEn: "4 days/week • Home",
                goal: .loseFat,
                level: .intermediate,
                weeks: 4,
                daysPerWeek: 4,
                xpPerSession: 55,
                isPremium: true,
                tagColor: .orange
            ),
            LibraryProgramItem(
                id: UUID(),
                titleAr: "برنامج لياقة عامة وتحسين النفس",
                titleEn: "General Fitness & Conditioning",
                subtitleAr: "٥ أيام في الأسبوع • HIIT + قوة",
                subtitleEn: "5 days/week • HIIT + strength",
                goal: .improveFitness,
                level: .intermediate,
                weeks: 8,
                daysPerWeek: 5,
                xpPerSession: 70,
                isPremium: true,
                tagColor: .green
            ),
            LibraryProgramItem(
                id: UUID(),
                titleAr: "برنامج منزلي للمبتدئين",
                titleEn: "Home Beginner Plan",
                subtitleAr: "٣ أيام في الأسبوع • بدون أجهزة",
                subtitleEn: "3 days/week • No equipment",
                goal: .home,
                level: .beginner,
                weeks: 4,
                daysPerWeek: 3,
                xpPerSession: 40,
                isPremium: false,
                tagColor: .cyan
            ),
            LibraryProgramItem(
                id: UUID(),
                titleAr: "برنامج متقدم للقوة والكتلة",
                titleEn: "Advanced Strength & Mass",
                subtitleAr: "٤ أيام في الأسبوع • قسم علوي/سفلي",
                subtitleEn: "4 days/week • Upper/Lower split",
                goal: .buildMuscle,
                level: .advanced,
                weeks: 10,
                daysPerWeek: 4,
                xpPerSession: 90,
                isPremium: true,
                tagColor: .red
            )
        ]
    }

    private var filteredPrograms: [LibraryProgramItem] {
        programs.filter { program in
            let goalMatch: Bool = {
                if selectedGoal == .all { return true }
                return program.goal == selectedGoal
            }()

            let levelMatch: Bool = {
                if selectedLevel == .all { return true }
                return program.level == selectedLevel
            }()

            return goalMatch && levelMatch
        }
    }

    // Grid
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    filtersSection
                    programsGrid
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }

            if isLoading {
                Color.black.opacity(0.05).ignoresSafeArea()
                ProgressView()
            }
        }
        .navigationTitle(isArabic ? "البرامج الجاهزة" : "Programs")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPrograms()
        }
        .alert(isPresented: Binding(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )) {
            Alert(
                title: Text(isArabic ? "خطأ" : "Error"),
                message: Text(errorMessage ?? ""),
                dismissButton: .default(Text(isArabic ? "حسناً" : "OK"))
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 8) {
            Text(isArabic ? "اختر برنامج يناسب هدفك" : "Choose a program for your goal")
                .font(.title3.weight(.bold))
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "برامج تدريب جاهزة لمdifferent الأهداف والمستويات. لاحقاً سيتم ربطها بحسابك وتتبع تقدّمك تلقائياً."
                : "Ready-made plans for different goals and levels. Later these will sync with your account and track progress automatically."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity,
               alignment: isArabic ? .trailing : .leading)
    }

    // MARK: - Filters

    private var filtersSection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 10) {

            // Goal filters
            Text(isArabic ? "الهدف" : "Goal")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(themeManager.textPrimary)
                .frame(maxWidth: .infinity,
                       alignment: isArabic ? .trailing : .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LibraryProgramGoal.allCases) { filter in
                        goalChip(filter: filter)
                    }
                }
                .padding(.vertical, 2)
            }

            // Level filters
            Text(isArabic ? "المستوى" : "Level")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(themeManager.textPrimary)
                .frame(maxWidth: .infinity,
                       alignment: isArabic ? .trailing : .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LibraryProgramLevel.allCases) { filter in
                        levelChip(filter: filter)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func goalChip(filter: LibraryProgramGoal) -> some View {
        let isSelected = filter == selectedGoal

        return Button {
            selectedGoal = filter
        } label: {
            Text(isArabic ? filter.titleAR : filter.titleEN)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange, Color.pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(themeManager.cardBackground)
                        }
                    }
                )
                .foregroundColor(isSelected ? .white : themeManager.textPrimary)
        }
        .buttonStyle(.plain)
    }

    private func levelChip(filter: LibraryProgramLevel) -> some View {
        let isSelected = filter == selectedLevel

        return Button {
            selectedLevel = filter
        } label: {
            Text(isArabic ? filter.titleAR : filter.titleEN)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(themeManager.cardBackground)
                        }
                    }
                )
                .foregroundColor(isSelected ? .white : themeManager.textPrimary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Programs Grid

    private var programsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "كل البرامج" : "All programs")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            if filteredPrograms.isEmpty {
                Text(isArabic ? "لا يوجد برامج بهذا الفلتر حالياً." :
                        "No programs match the current filters.")
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filteredPrograms) { program in
                        ProgramLibraryCard(
                            item: program,
                            isArabic: isArabic,
                            themeManager: themeManager
                        )
                    }
                }
            }
        }
    }

    // MARK: - تحميل من الباك إند + fallback

    private func loadPrograms() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let backendItems = try await ProgramsRemoteService.shared.fetchPrograms()

            let mapped: [LibraryProgramItem] = backendItems.map { backend in
                // تحويل نص الـ goal إلى فلتر داخلي (بسيط – يمكن تحسينه لاحقاً)
                let goal: LibraryProgramGoal = {
                    guard let g = backend.goal?.lowercased() else { return .all }
                    if g.contains("muscle") || g.contains("bulk") { return .buildMuscle }
                    if g.contains("fat") || g.contains("cut")   { return .loseFat }
                    if g.contains("fit")                        { return .improveFitness }
                    if g.contains("home")                       { return .home }
                    return .all
                }()

                let level: LibraryProgramLevel = {
                    let d = backend.difficulty.lowercased()
                    if d.contains("beginner")     { return .beginner }
                    if d.contains("intermediate") { return .intermediate }
                    if d.contains("advanced")     { return .advanced }
                    return .all
                }()

                return LibraryProgramItem(
                    id: backend.id,
                    titleAr: backend.nameAr,
                    titleEn: backend.nameEn,
                    subtitleAr: backend.subtitleAr ?? "",
                    subtitleEn: backend.subtitleEn ?? "",
                    goal: goal,
                    level: level,
                    weeks: backend.durationWeeks ?? 4,
                    daysPerWeek: backend.daysPerWeek ?? 3,
                    xpPerSession: backend.xpPerSession ?? 50,
                    isPremium: backend.isPremium,
                    tagColor: .purple // ممكن لاحقاً نختار اللون من tags
                )
            }

            await MainActor.run {
                self.programs = mapped.isEmpty ? self.fallbackPrograms : mapped
            }
        } catch ProgramsRemoteError.notConfigured {
            // لو ما تم الربط لسه → نستخدم البيانات التجريبية بصمت
            await MainActor.run {
                self.programs = self.fallbackPrograms
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.programs = self.fallbackPrograms
            }
        }
    }
}

// MARK: - Program Card

struct ProgramLibraryCard: View {
    let item: LibraryProgramItem
    let isArabic: Bool
    let themeManager: ThemeManager

    var title: String {
        isArabic ? item.titleAr : item.titleEn
    }

    var subtitle: String {
        isArabic ? item.subtitleAr : item.subtitleEn
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // صورة/غلاف مبسّط
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [item.tagColor.opacity(0.85), item.tagColor.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(16)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                .padding(10)
            }
            .frame(height: 110)

            // معلومات مختصرة أسفل الكرت
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 11, weight: .medium))
                Text("\(item.weeks)\(isArabic ? " أسابيع" : " weeks")")
                    .font(.caption2)
            }
            .foregroundColor(themeManager.textSecondary)

            HStack(spacing: 6) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 11, weight: .medium))
                Text("\(item.daysPerWeek)\(isArabic ? " أيام/أسبوع" : " days/week")")
                    .font(.caption2)
            }
            .foregroundColor(themeManager.textSecondary)

            HStack {
                Text("\(item.xpPerSession) XP")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(AppColors.primaryBlue)

                Spacer()

                if item.isPremium {
                    Text(isArabic ? "بريميوم" : "Premium")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(10)
                } else {
                    Text(isArabic ? "مجاني" : "Free")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(10)
                }
            }
        }
        .padding(8)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProgramsLibraryView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
