//
//  ExercisesView.swift
//  FITGET
//
//  تم التحديث ليتوافق مع WorkoutExercise + MuscleGroup الجديدة
//

import SwiftUI

struct ExercisesView: View {

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    // نستخدم خدمة التمرين المرتبطة بسوبابيس
    @StateObject private var workoutService = WorkoutRemoteService.shared

    @State private var selectedGroup: MuscleGroup? = nil   // nil = الكل
    @State private var searchText: String = ""

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // MARK: - Filtered list

    private var filteredExercises: [WorkoutExercise] {
        var base = workoutService.exercises

        if let g = selectedGroup {
            base = base.filter { $0.muscleGroupEnum == g }
        }

        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }

        let lower = q.lowercased()
        return base.filter { ex in
            ex.nameEn.lowercased().contains(lower)
            || ex.nameAr.lowercased().contains(lower)
            || ex.primaryMuscle.lowercased().contains(lower)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()

                VStack(spacing: 14) {
                    header
                    searchField
                    muscleGroupsChips

                    if workoutService.isLoading && workoutService.exercises.isEmpty {
                        ProgressView()
                            .padding(.top, 40)
                        Spacer()
                    } else if filteredExercises.isEmpty {
                        emptyState
                    } else {
                        exercisesList
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle(isArabic ? "تمارين العضلات" : "Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if workoutService.exercises.isEmpty {
                    await workoutService.loadExercises()
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 4) {
            Text(isArabic ? "مكتبة التمارين" : "Exercise library")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "اختر العضلة وشاهد جميع التمارين المناسبة في المنزل أو الجيم."
                : "Pick a muscle group and explore exercises for home & gym."
            )
            .font(.system(size: 13))
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField(
                isArabic ? "ابحث عن تمرين أو عضلة" : "Search exercise or muscle",
                text: $searchText
            )
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Muscle Chips

    private var muscleGroupsChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                let allSelected = (selectedGroup == nil)
                ProgramFilterChip(
                    title: isArabic ? "الكل" : "All",
                    isSelected: allSelected
                ) {
                    selectedGroup = nil
                }

                ForEach(MuscleGroup.allCases) { group in
                    let selected = (selectedGroup == group)
                    ProgramFilterChip(
                        title: group.displayName(isArabic: isArabic),
                        isSelected: selected
                    ) {
                        selectedGroup = group
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - List

    private var exercisesList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredExercises) { exercise in
                    NavigationLink {
                        ExerciseDetailView(exercise: exercise)
                            .environmentObject(languageManager)
                            .environmentObject(themeManager)
                    } label: {
                        ExerciseCardView(exercise: exercise, isArabic: isArabic)
                            .environmentObject(themeManager)
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
            Image(systemName: "questionmark.circle")
                .font(.system(size: 40))
                .foregroundColor(themeManager.textSecondary)

            Text(isArabic ? "لا توجد تمارين مطابقة" : "No exercises found")
                .foregroundColor(themeManager.textPrimary)
                .font(.headline)

            Text(
                isArabic
                ? "جرّب تغيير العضلة أو حذف البحث."
                : "Try changing muscle group or clearing the search."
            )
            .foregroundColor(themeManager.textSecondary)
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Card

struct ExerciseCardView: View {
    let exercise: WorkoutExercise
    let isArabic: Bool

    @EnvironmentObject var themeManager: ThemeManager

    private var title: String {
        isArabic ? exercise.nameAr : exercise.nameEn
    }

    private var difficultyLabel: String {
        switch exercise.difficulty {
        case "beginner":     return isArabic ? "مبتدئ" : "Beginner"
        case "intermediate": return isArabic ? "متوسط" : "Intermediate"
        case "advanced":     return isArabic ? "متقدم" : "Advanced"
        default:             return exercise.difficulty
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "00d4ff").opacity(0.35),
                                Color(hex: "0091ff").opacity(0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                // ✅ بدون optional chaining – muscleGroupEnum غير اختياري
                Image(systemName: exercise.muscleGroupEnum.systemIcon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.textPrimary)
                    .lineLimit(2)

                Text(exercise.primaryMuscle)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.textSecondary)

                HStack(spacing: 6) {
                    chip(text: difficultyLabel)
                    chip(text: exercise.equipment)
                }
            }

            Spacer()
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
    }

    private func chip(text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            .foregroundColor(.white.opacity(0.9))
    }
}

#Preview {
    NavigationStack {
        ExercisesView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
