//
//  ExerciseIconCard.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import SwiftUI

struct ExerciseIconCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    let exercise: Exercise

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var title: String {
        isArabic ? exercise.nameAr : exercise.nameEn
    }

    private var subtitle: String {
        let difficulty = difficultyLabel(exercise.difficulty)
        let equipment = equipmentLabel(exercise.equipment)
        return isArabic
        ? "\(difficulty) • \(equipment)"
        : "\(difficulty) • \(equipment)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // أيقونة بسيطة تعتمد على نوع العضلة
            ZStack {
                Circle()
                    .fill(themeManager.primary.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: iconName(for: exercise.muscleGroup))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.primary)
            }

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.textPrimary)
                .lineLimit(2)

            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(themeManager.textSecondary)
                .lineLimit(2)

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                Label {
                    Text(isArabic ? "سعرات" : "kcal")
                } icon: {
                    Image(systemName: "flame.fill")
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(themeManager.accent)

                Spacer()

                if exercise.isPremium {
                    Text(isArabic ? "Premium" : "Premium")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(themeManager.primary.opacity(0.15))
                        .foregroundColor(themeManager.primary)
                        .cornerRadius(10)
                } else {
                    Text(isArabic ? "مجاني" : "Free")
                        .font(.system(size: 9, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(themeManager.cardBackground.opacity(0.8))
                        .foregroundColor(themeManager.textSecondary)
                        .cornerRadius(10)
                }
            }
        }
        .padding(10)
        .frame(width: 160, height: 150)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private func iconName(for group: String) -> String {
        switch group {
        case "chest": return "square.split.diagonal.2x2"
        case "back": return "rectangle.portrait.split.2x1"
        case "legs": return "figure.walk"
        case "shoulders": return "circle.grid.2x2"
        case "arms": return "dumbbell"
        case "core": return "circle.dashed"
        case "full_body": return "figure.highintensity.intervaltraining"
        case "cardio": return "waveform.path.ecg"
        default: return "staroflife"
        }
    }

    private func difficultyLabel(_ value: String) -> String {
        switch value {
        case "beginner":
            return isArabic ? "مبتدئ" : "Beginner"
        case "intermediate":
            return isArabic ? "متوسط" : "Intermediate"
        case "advanced":
            return isArabic ? "متقدم" : "Advanced"
        default:
            return value
        }
    }

    private func equipmentLabel(_ value: String) -> String {
        if !isArabic { return value.capitalized }
        switch value {
        case "barbell": return "بار"
        case "dumbbell": return "دمبل"
        case "machine": return "جهاز"
        case "bodyweight": return "وزن الجسم"
        case "cable": return "كابل"
        case "kettlebell": return "كتل بيل"
        case "band": return "حبل مطاطي"
        default: return value
        }
    }
}

#Preview {
    ExerciseIconCard(
        exercise: Exercise.all.first ?? Exercise(
            slug: "preview",
            nameEn: "Preview Exercise",
            nameAr: "تمرين تجريبي",
            descriptionEn: "Preview only.",
            descriptionAr: "عرض تجريبي فقط.",
            muscleGroup: "chest",
            equipment: "bodyweight",
            difficulty: "beginner",
            isBodyweight: true,
            primaryMuscle: "chest",
            stepsEn: ["Step"],
            stepsAr: ["خطوة"],
            tipsEn: ["Tip"],
            tipsAr: ["نصيحة"],
            caloriesPerMinute: 5.0
        )
    )
    .environmentObject(ThemeManager.shared)
    .environmentObject(LanguageManager.shared)
    .padding()
    .background(Color.black)
}
