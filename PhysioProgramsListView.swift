//
//  PhysioProgramsListView.swift
//  FITGET
//

import SwiftUI

struct PhysioProgramsListView: View {

    let bodyArea: String
    @ObservedObject var physioService: PhysioRemoteService

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var programs: [PhysioProgram] {
        physioService.programs.filter { $0.bodyArea == bodyArea }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(programs) { program in
                    NavigationLink {
                        PhysioProgramDetailView(
                            program: program,
                            physioService: physioService
                        )
                    } label: {
                        programCard(program)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(isArabic ? "برامج التأهيل" : "Rehab Programs")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func programCard(_ program: PhysioProgram) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(isArabic ? program.nameAr : program.nameEn)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            if let diff = program.difficulty {
                Text(diff.physioDifficultyTitle(isArabic: isArabic))
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }

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
