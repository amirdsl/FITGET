//
//  PhysioProgramRowView.swift
//  FITGET
//

import SwiftUI

struct PhysioProgramRowView: View {

    let program: PhysioProgram
    let progress: Double
    let isArabic: Bool

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(isArabic ? program.nameAr : program.nameEn)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            if let difficulty = program.difficulty {
                Text(difficulty.physioDifficultyTitle(isArabic: isArabic))
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }

            ProgressView(value: progress)
                .tint(themeManager.primary)

            HStack(spacing: 12) {
                Label("\(program.durationWeeks)w", systemImage: "calendar")
                Label("\(program.sessionsPerWeek)x", systemImage: "figure.walk")
            }
            .font(.caption2)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }
}
