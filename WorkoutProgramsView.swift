//
//  WorkoutProgramsView.swift
//  FITGET
//
//  قائمة برامج التمرين المبنية على جدول workout_programs
//

import SwiftUI

struct WorkoutProgramsView: View {

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var playerProgress: PlayerProgress

    @StateObject private var workoutService = WorkoutRemoteService.shared

    @State private var selectedFocus: WorkoutProgramFocusFilter? = nil
    @State private var selectedLevel: WorkoutProgramLevelFilter? = nil

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // MARK: - Filtered list

    private var filteredPrograms: [WorkoutProgram] {
        var items = workoutService.programs

        if let focusFilter = selectedFocus {
            items = items.filter { focusFilter.matches($0.focus) }
        }

        if let levelFilter = selectedLevel {
            items = items.filter { levelFilter.matches($0.level) }
        }

        return items
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()

                VStack(spacing: 16) {
                    heroHeader

                    filtersRow

                    if workoutService.isLoading && workoutService.programs.isEmpty {
                        ProgressView()
                            .padding(.top, 40)
                        Spacer()
                    } else if filteredPrograms.isEmpty {
                        emptyState
                    } else {
                        programsList
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle(isArabic ? "البرامج الجاهزة" : "Ready programs")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if workoutService.programs.isEmpty {
                    await workoutService.loadPrograms()
                }
            }
        }
    }

    // MARK: - Header

    private var heroHeader: some View {
        ZStack(alignment: isArabic ? .bottomTrailing : .bottomLeading) {
            LinearGradient(
                colors: [
                    themeManager.primary,
                    themeManager.accent
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 150)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)

            VStack(
                alignment: isArabic ? .trailing : .leading,
                spacing: 8
            ) {
                Text(
                    isArabic
                    ? "اختر برنامج جاهز يناسب هدفك"
                    : "Pick a ready-made program for your goal"
                )
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

                Text(
                    isArabic
                    ? "نزول دهون، بناء عضل، لياقة أو برامج منزلية سريعة."
                    : "Fat loss, muscle gain, performance or quick home plans."
                )
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.92))

                HStack(spacing: 10) {
                    Label(
                        "\(workoutService.programs.count)",
                        systemImage: "square.grid.2x2"
                    )
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.95))

                    Label(
                        "\(filteredPrograms.count)",
                        systemImage: "line.3.horizontal.decrease.circle"
                    )
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.95))
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Filters

    private var filtersRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "فلترة البرامج" : "Filter programs")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {

                    // Focus filter
                    ProgramFilterChip(
                        title: isArabic ? "كل الأهداف" : "All focuses",
                        isSelected: selectedFocus == nil
                    ) {
                        selectedFocus = nil
                    }

                    ForEach(WorkoutProgramFocusFilter.allCases) { filter in
                        ProgramFilterChip(
                            title: filter.title(isArabic: isArabic),
                            isSelected: selectedFocus == filter
                        ) {
                            selectedFocus = (selectedFocus == filter) ? nil : filter
                        }
                    }

                    Divider()
                        .frame(height: 22)

                    // Level filter
                    ProgramFilterChip(
                        title: isArabic ? "كل المستويات" : "All levels",
                        isSelected: selectedLevel == nil
                    ) {
                        selectedLevel = nil
                    }

                    ForEach(WorkoutProgramLevelFilter.allCases) { filter in
                        ProgramFilterChip(
                            title: filter.title(isArabic: isArabic),
                            isSelected: selectedLevel == filter
                        ) {
                            selectedLevel = (selectedLevel == filter) ? nil : filter
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - List

    private var programsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredPrograms) { program in
                    NavigationLink {
                        ProgramDetailView(program: program)
                    } label: {
                        WorkoutProgramRow(
                            program: program,
                            isArabic: isArabic,
                            themeManager: themeManager
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 16)
            }
            .padding(.vertical, 4)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.system(size: 40))
                .foregroundColor(themeManager.textSecondary)

            Text(isArabic ? "لا توجد برامج متاحة حاليًا" : "No programs available yet")
                .foregroundColor(themeManager.textPrimary)
                .font(.headline)

            Text(
                isArabic
                ? "سيتم إضافة المزيد من برامج التمرين قريبًا، جرّب تحديث الصفحة لاحقًا."
                : "More programs will be added soon. Try refreshing later."
            )
            .foregroundColor(themeManager.textSecondary)
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Row view

struct WorkoutProgramRow: View {
    let program: WorkoutProgram
    let isArabic: Bool
    let themeManager: ThemeManager

    private var titleText: String {
        isArabic ? program.titleAr : program.titleEn
    }

    private var focusLabel: String {
        WorkoutProgramFocusFilter.label(for: program.focus, isArabic: isArabic)
    }

    private var levelLabel: String {
        WorkoutProgramLevelFilter.label(for: program.level, isArabic: isArabic)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.primary.opacity(0.22),
                                themeManager.accent.opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)

                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(titleText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.textPrimary)
                        .lineLimit(2)

                    Spacer()

                    if program.isFeatured {
                        Text(isArabic ? "مميز" : "Featured")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.2))
                            .foregroundColor(.yellow)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 6) {
                    chip(text: focusLabel)
                    chip(text: levelLabel)
                }

                HStack(spacing: 10) {
                    Label("\(program.durationMinutes) min", systemImage: "clock")
                    Label("\(program.calories) kcal", systemImage: "flame.fill")
                    Label("\(program.xpReward) XP", systemImage: "sparkles")
                }
                .font(.system(size: 11))
                .foregroundColor(themeManager.textSecondary)
            }

            Spacer()
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 3)
    }

    private func chip(text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(themeManager.primary.opacity(0.08))
            .cornerRadius(10)
            .foregroundColor(themeManager.textPrimary)
    }
}

// MARK: - Focus filter helper

enum WorkoutProgramFocusFilter: String, CaseIterable, Identifiable {
    case fullBody   = "full_body"
    case upperBody  = "upper_body"
    case lowerBody  = "lower_body"
    case cardio     = "cardio"

    var id: String { rawValue }

    func matches(_ focus: String) -> Bool {
        focus == rawValue
    }

    func title(isArabic: Bool) -> String {
        switch self {
        case .fullBody:
            return isArabic ? "جسم كامل" : "Full body"
        case .upperBody:
            return isArabic ? "جزء علوي" : "Upper body"
        case .lowerBody:
            return isArabic ? "جزء سفلي" : "Lower body"
        case .cardio:
            return isArabic ? "كارديو" : "Cardio"
        }
    }

    static func label(for focus: String, isArabic: Bool) -> String {
        guard let f = WorkoutProgramFocusFilter(rawValue: focus) else {
            return focus
        }
        return f.title(isArabic: isArabic)
    }
}

// MARK: - Level filter helper

enum WorkoutProgramLevelFilter: String, CaseIterable, Identifiable {
    case beginner     = "beginner"
    case intermediate = "intermediate"
    case advanced     = "advanced"

    var id: String { rawValue }

    func matches(_ level: String) -> Bool {
        level == rawValue
    }

    func title(isArabic: Bool) -> String {
        switch self {
        case .beginner:     return isArabic ? "مبتدئ" : "Beginner"
        case .intermediate: return isArabic ? "متوسط" : "Intermediate"
        case .advanced:     return isArabic ? "متقدم" : "Advanced"
        }
    }

    static func label(for level: String, isArabic: Bool) -> String {
        guard let l = WorkoutProgramLevelFilter(rawValue: level) else {
            return level
        }
        return l.title(isArabic: isArabic)
    }
}

#Preview {
    NavigationStack {
        WorkoutProgramsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(PlayerProgress())
    }
}
