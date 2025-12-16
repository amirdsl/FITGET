//
//  ExerciseDetailView.swift
//  FITGET
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: WorkoutExercise

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var titleText: String {
        isArabic ? exercise.nameAr : exercise.nameEn
    }

    private var instructionsText: String {
        let ar = (exercise.instructionsAr ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let en = (exercise.instructionsEn ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if isArabic {
            return ar.isEmpty ? en : ar
        } else {
            return en.isEmpty ? ar : en
        }
    }

    private var difficultyLabel: String {
        switch exercise.difficulty {
        case "beginner":      return isArabic ? "مبتدئ" : "Beginner"
        case "intermediate":  return isArabic ? "متوسط" : "Intermediate"
        case "advanced":      return isArabic ? "متقدم" : "Advanced"
        default:              return exercise.difficulty
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                infoCard
                if !instructionsText.isEmpty {
                    instructionsCard
                }
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "تفاصيل التمرين" : "Exercise")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCard: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [themeManager.primary, themeManager.accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)
            .cornerRadius(24)
            .shadow(radius: 8)

            VStack(alignment: .leading, spacing: 8) {
                Text(titleText)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Text(exercise.primaryMuscle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 8) {
                    Label(difficultyLabel, systemImage: "speedometer")
                    Label(exercise.equipment, systemImage: "dumbbell.fill")
                    Label("\(exercise.defaultXP) XP", systemImage: "star.fill")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
    }

    // MARK: - Info

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "معلومات التمرين" : "Exercise info")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "استهدف عضلة \(exercise.primaryMuscle) مع هذا التمرين. ركّز على التقنية الجيدة قبل زيادة الوزن."
                : "Target your \(exercise.primaryMuscle) with this move. Focus on good technique before adding load."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 4)
    }

    // MARK: - Instructions

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "الشرح والخطوات" : "How to perform")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(instructionsText)
                .font(.footnote)
                .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 4)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: .demo)
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
