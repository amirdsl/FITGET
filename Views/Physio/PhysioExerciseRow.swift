//
//  PhysioExerciseRow.swift
//  FITGET
//

import SwiftUI

struct PhysioExerciseRow: View {
    let exercise: PhysioExercise
    let isArabic: Bool

    @EnvironmentObject var themeManager: ThemeManager

    private var nameText: String {
        let nameAr = exercise.nameAr.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameEn = exercise.nameEn.trimmingCharacters(in: .whitespacesAndNewlines)

        if isArabic {
            return nameAr.isEmpty ? (nameEn.isEmpty ? " " : nameEn) : nameAr
        } else {
            return nameEn.isEmpty ? (nameAr.isEmpty ? " " : nameAr) : nameEn
        }
    }

    private var instructionsText: String {
        let instAr = exercise.instructionsAr?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let instEn = exercise.instructionsEn?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if isArabic {
            return instAr.isEmpty ? instEn : instAr
        } else {
            return instEn.isEmpty ? instAr : instEn
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(nameText)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(themeManager.textPrimary)

            if !instructionsText.isEmpty {
                Text(instructionsText)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .background(themeManager.cardBackground.opacity(0.7))
        .cornerRadius(14)
    }
}

#Preview {
    PhysioExerciseRow(
        exercise: PhysioExercise(
            id: UUID(),
            nameEn: "Heel Slides",
            nameAr: "سلايد الكعب",
            bodyArea: "knee",
            stage: "mobility",
            videoURL: nil,
            instructionsEn: "Slide heel towards your glutes while lying on your back.",
            instructionsAr: "أنت مستلقٍ على ظهرك، اسحب الكعب باتجاه المؤخرة.",
            precautionsEn: nil,
            precautionsAr: nil,
            difficulty: "easy"
        ),
        isArabic: true
    )
    .environmentObject(ThemeManager.shared)
}
