// FILE: PhysioProgramDetailView.swift
// FITGET

import SwiftUI

struct PhysioProgramDetailView: View {
    let program: PhysioProgram
    @ObservedObject var physioService: PhysioRemoteService

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var playerProgress: PlayerProgress
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var isLoadingExercises = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // MARK: - Text helpers

    private var titleText: String {
        let nameAr = program.nameAr.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameEn = program.nameEn.trimmingCharacters(in: .whitespacesAndNewlines)

        if isArabic {
            return nameAr.isEmpty ? (nameEn.isEmpty ? " " : nameEn) : nameAr
        } else {
            return nameEn.isEmpty ? (nameAr.isEmpty ? " " : nameAr) : nameEn
        }
    }

    private var descriptionText: String {
        let descAr = (program.descriptionAr ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let descEn = (program.descriptionEn ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if isArabic {
            return descAr.isEmpty ? descEn : descAr
        } else {
            return descEn.isEmpty ? descAr : descEn
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                overviewCard
                exercisesSection

                // Pain history block
                if let idString = authManager.authUser?.id,
                   let userUUID = UUID(uuidString: idString) {
                    VStack(alignment: .leading, spacing: 10) {
                        PhysioPainHistoryView(
                            program: program,
                            userId: userUUID
                        )
                    }
                    .padding()
                    .background(themeManager.cardBackground)
                    .cornerRadius(18)
                    .shadow(radius: 4)
                }
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "خطة التأهيل" : "Rehab plan")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadExercisesIfNeeded()
        }
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

                if !descriptionText.isEmpty {
                    Text(descriptionText)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    Label("\(program.durationWeeks)w", systemImage: "calendar")
                    Label("\(program.sessionsPerWeek)x / w", systemImage: "figure.walk")

                    if let difficultyRaw = program.difficulty {
                        let difficultyText = difficultyRaw.localized(isArabic: isArabic)
                        if !difficultyText.isEmpty {
                            Label(difficultyText, systemImage: "speedometer")
                        }
                    }
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.95))
            }
            .padding()
        }
    }

    // MARK: - Overview

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "ملخص البرنامج" : "Program overview")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "التزم بالتمارين كما هو موضح، وتوقف إذا زاد الألم بشكل واضح أو ظهر تورم جديد."
                : "Follow the exercises as described. Stop if pain increases significantly or new swelling appears."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 4)
    }

    // MARK: - Exercises

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(isArabic ? "تمارين البرنامج" : "Program exercises")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)

                Spacer()

                if isLoadingExercises {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }

            let list = physioService.exercisesByProgram[program.id] ?? []

            if list.isEmpty && !isLoadingExercises {
                Text(isArabic ? "لم يتم تحميل التمارين بعد." : "Exercises not loaded yet.")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(list) { ex in
                        PhysioExerciseRow(
                            exercise: ex,
                            isArabic: isArabic
                        )
                    }
                }
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 4)
    }

    // MARK: - Load

    private func loadExercisesIfNeeded() async {
        let programId = program.id
        if physioService.exercisesByProgram[programId] != nil { return }
        isLoadingExercises = true
        defer { isLoadingExercises = false }
        await physioService.loadExercises(for: programId)
    }
}
