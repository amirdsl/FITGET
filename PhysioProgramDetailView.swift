//
//  PhysioProgramDetailView.swift
//  FITGET
//

import SwiftUI

struct PhysioProgramDetailView: View {

    let program: PhysioProgram
    @ObservedObject var physioService: PhysioRemoteService

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var completedExercises: Int = 0
    @State private var isLoadingExercises = false
    @State private var programStarted = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var exercises: [PhysioExercise] {
        physioService.exercisesByProgram[program.id] ?? []
    }

    private var totalExercises: Int {
        exercises.count
    }

    private var progressValue: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(completedExercises) / Double(totalExercises)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                progressCard
                exercisesSection
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "خطة التأهيل" : "Rehab plan")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadExercisesIfNeeded()
            startProgramIfNeeded()
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? program.nameAr : program.nameEn)
                .font(.title3.bold())
                .foregroundColor(.white)

            HStack {
                Label("\(program.durationWeeks)w", systemImage: "calendar")
                Label("\(program.sessionsPerWeek)x", systemImage: "figure.walk")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [themeManager.primary, themeManager.accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
    }

    // MARK: - Progress

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "تقدمك في البرنامج" : "Your progress")
                .font(.headline)

            ProgressView(value: progressValue)
                .tint(themeManager.primary)

            Text(
                isArabic
                ? "\(completedExercises) من \(totalExercises) تمارين مكتملة"
                : "\(completedExercises) of \(totalExercises) exercises completed"
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
    }

    // MARK: - Exercises

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "تمارين البرنامج" : "Program exercises")
                .font(.headline)

            if exercises.isEmpty && !isLoadingExercises {
                Text(isArabic ? "لم يتم تحميل التمارين بعد" : "Exercises not loaded yet")
                    .font(.caption)
            } else {
                ForEach(exercises.indices, id: \.self) { index in
                    exerciseRow(exercises[index], index: index)
                }
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
    }

    private func exerciseRow(_ exercise: PhysioExercise, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? exercise.nameAr : exercise.nameEn)
                .font(.subheadline.bold())

            if let inst = isArabic ? exercise.instructionsAr : exercise.instructionsEn {
                Text(inst)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }

            Button {
                completeExercise()
            } label: {
                Text(isArabic ? "تم التنفيذ" : "Mark as done")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(themeManager.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(index < completedExercises)
        }
        .padding()
        .background(themeManager.secondaryBackground.opacity(0.5))
        .cornerRadius(14)
    }

    // MARK: - Logic

    private func startProgramIfNeeded() {
        guard !programStarted,
              let id = authManager.authUser?.id,
              let userId = UUID(uuidString: id),
              totalExercises > 0 else { return }

        programStarted = true

        Task {
            await PhysioProgressManager.shared.startProgram(
                userId: userId,
                programId: program.id,
                totalExercises: totalExercises
            )
        }
    }

    private func completeExercise() {
        guard let id = authManager.authUser?.id,
              let userId = UUID(uuidString: id) else { return }

        completedExercises += 1

        PhysioGamificationBridge.shared.onExerciseCompleted()

        if completedExercises == totalExercises {
            PhysioGamificationBridge.shared.onProgramCompleted()
        }

        Task {
            await PhysioProgressManager.shared.completeExercise(
                userId: userId,
                programId: program.id,
                completedExercises: completedExercises,
                totalExercises: totalExercises
            )
        }
    }

    private func loadExercisesIfNeeded() async {
        if physioService.exercisesByProgram[program.id] != nil { return }
        isLoadingExercises = true
        defer { isLoadingExercises = false }
        await physioService.loadExercises(for: program.id)
    }
}
