//
//  ProgramDetailView.swift
//  FITGET
//

import SwiftUI

struct ProgramDetailView: View {
    let program: WorkoutProgram

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var titleText: String {
        isArabic ? program.titleAr : program.titleEn
    }

    private var focusText: String {
        switch program.focus {
        case "full_body":   return isArabic ? "جسم كامل" : "Full body"
        case "upper_body":  return isArabic ? "جزء علوي" : "Upper body"
        case "lower_body":  return isArabic ? "جزء سفلي" : "Lower body"
        case "cardio":      return isArabic ? "كارديو" : "Cardio"
        default:            return program.focus
        }
    }

    private var levelText: String {
        switch program.level {
        case "beginner":      return isArabic ? "مبتدئ" : "Beginner"
        case "intermediate":  return isArabic ? "متوسط" : "Intermediate"
        case "advanced":      return isArabic ? "متقدم" : "Advanced"
        default:              return program.level
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard
                statsCard
                structureCard
                exercisesPreviewCard
                startButtonCard
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "برنامج تمرين" : "Workout program")
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
            .frame(height: 190)
            .cornerRadius(24)
            .shadow(radius: 8)

            VStack(alignment: .leading, spacing: 10) {
                Text(titleText)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    pill(
                        systemImage: "target",
                        text: focusText
                    )
                    pill(
                        systemImage: "speedometer",
                        text: levelText
                    )
                    pill(
                        systemImage: "clock",
                        text: "\(program.durationMinutes) min"
                    )
                }

                Text(
                    isArabic
                    ? "برنامج جاهز مصمم لهدف محدد. نفّذ التمارين كما هو موضح لتحصل على أفضل نتيجة."
                    : "Ready-made plan designed for a specific goal. Follow the sessions to get the best results."
                )
                .font(.caption)
                .foregroundColor(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
    }

    private func pill(systemImage: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
                .lineLimit(1)
        }
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.18))
        .foregroundColor(.white)
        .clipShape(Capsule())
    }

    // MARK: - Stats

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "ملخص" : "Overview")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "كل حصة من هذا البرنامج تحرق تقريبًا \(program.calories) سعرة وتعطيك \(program.xpReward) نقطة خبرة."
                : "Each session of this program burns around \(program.calories) kcal and grants \(program.xpReward) XP."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            HStack {
                statItem(
                    title: isArabic ? "السعرات المتوقعة" : "Estimated calories",
                    value: "\(program.calories) kcal"
                )
                Spacer()
                statItem(
                    title: "XP",
                    value: "\(program.xpReward)"
                )
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 4)
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            Text(value)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
        }
    }

    // MARK: - Structure

    private var structureCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "هيكلة البرنامج" : "Program structure")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "نفّذ هذا البرنامج من ٣ إلى ٥ مرات أسبوعيًا حسب مستواك. يمكنك دمجه مع خطة التغذية من قسم التغذية."
                : "Run this program 3-5 times per week depending on your level. Combine it with a nutrition plan from the Nutrition tab."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 3)
    }

    // MARK: - Exercises preview

    private var exercisesPreviewCard: some View {
        let exercises = WorkoutExerciseInfo.sample(for: program)

        return VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "محتوى الجلسة" : "Session content")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "أمثلة للتمارين التي يمكن أن تحتويها الجلسة. لاحقًا يمكن ربطها ببيانات حقيقية من المدربين."
                : "Example exercises that a session may include. Later this can be backed by real data from trainers."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            ForEach(exercises) { ex in
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.primary.opacity(0.12))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "figure.strengthtraining.traditional")
                                .foregroundColor(themeManager.primary)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(isArabic ? ex.nameAr : ex.nameEn)
                            .font(.subheadline.bold())
                            .foregroundColor(themeManager.textPrimary)

                        Text(
                            "\(ex.sets)x\(ex.reps) • \(isArabic ? "راحة" : "Rest") \(ex.restSeconds)s"
                        )
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    }

                    Spacer()
                }
                .padding(8)
                .background(themeManager.cardBackground)
                .cornerRadius(14)
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 3)
    }

    // MARK: - Start button

    private var startButtonCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "جاهز للبدء؟" : "Ready to start?")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "ابدأ أول جلسة، وتابع تقدمك يدويًا الآن. لاحقًا يمكن ربط التتبع بنظام كامل للعدّات والأوزان."
                : "Start your first session and track your progress manually for now. Later this can be connected to full tracking with sets & weights."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            NavigationLink {
                ProgramWorkoutSessionView(program: program)
            } label: {
                HStack {
                    Spacer()
                    Text(isArabic ? "بدء هذا البرنامج" : "Start this program")
                        .font(.subheadline.bold())
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(themeManager.primary)
                .foregroundColor(.white)
                .cornerRadius(22)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 3)
    }
}

// MARK: - Local exercise model + session view

struct WorkoutExerciseInfo: Identifiable {
    let id = UUID()
    let nameAr: String
    let nameEn: String
    let sets: Int
    let reps: Int
    let restSeconds: Int
}

extension WorkoutExerciseInfo {
    static func sample(for program: WorkoutProgram) -> [WorkoutExerciseInfo] {
        switch program.focus {
        case "upper_body":
            return [
                WorkoutExerciseInfo(
                    nameAr: "ضغط بنش بالبار",
                    nameEn: "Barbell bench press",
                    sets: 4, reps: 8, restSeconds: 90
                ),
                WorkoutExerciseInfo(
                    nameAr: "سحب ظهر عريض",
                    nameEn: "Lat pulldown",
                    sets: 4, reps: 10, restSeconds: 75
                ),
                WorkoutExerciseInfo(
                    nameAr: "ضغط كتف دمبل",
                    nameEn: "Dumbbell shoulder press",
                    sets: 3, reps: 12, restSeconds: 75
                )
            ]
        case "lower_body":
            return [
                WorkoutExerciseInfo(
                    nameAr: "سكوات",
                    nameEn: "Back squat",
                    sets: 4, reps: 8, restSeconds: 120
                ),
                WorkoutExerciseInfo(
                    nameAr: "لونج مشي",
                    nameEn: "Walking lunges",
                    sets: 3, reps: 12, restSeconds: 90
                ),
                WorkoutExerciseInfo(
                    nameAr: "رفع سمانة",
                    nameEn: "Standing calf raises",
                    sets: 3, reps: 15, restSeconds: 60
                )
            ]
        case "cardio":
            return [
                WorkoutExerciseInfo(
                    nameAr: "جري على السير",
                    nameEn: "Treadmill run",
                    sets: 1, reps: 15, restSeconds: 0
                ),
                WorkoutExerciseInfo(
                    nameAr: "قفز حبل",
                    nameEn: "Jump rope",
                    sets: 4, reps: 45, restSeconds: 45
                ),
                WorkoutExerciseInfo(
                    nameAr: "إير بايك",
                    nameEn: "Air bike",
                    sets: 3, reps: 30, restSeconds: 60
                )
            ]
        default: // full_body أو أي شيء آخر
            return [
                WorkoutExerciseInfo(
                    nameAr: "سكوات وزن الجسم",
                    nameEn: "Bodyweight squats",
                    sets: 3, reps: 15, restSeconds: 60
                ),
                WorkoutExerciseInfo(
                    nameAr: "ضغط أرض",
                    nameEn: "Push-ups",
                    sets: 3, reps: 12, restSeconds: 60
                ),
                WorkoutExerciseInfo(
                    nameAr: "بلانك",
                    nameEn: "Plank hold",
                    sets: 3, reps: 40, restSeconds: 45
                )
            ]
        }
    }
}

struct ProgramWorkoutSessionView: View {
    let program: WorkoutProgram

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    @State private var completed: Set<UUID> = []

    private var exercises: [WorkoutExerciseInfo] {
        WorkoutExerciseInfo.sample(for: program)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                ForEach(exercises) { ex in
                    exerciseRow(ex)
                }

                summaryCard
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "جلسة التمرين" : "Workout session")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "خطة الجلسة" : "Session plan")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "حدد التمارين المكتملة يدويًا الآن. لاحقًا يمكن إضافة عداد تلقائي للأوزان والعدات والراحة."
                : "Mark finished exercises manually for now. Later we can add automatic tracking for sets, weights & rest."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 3)
    }

    private func exerciseRow(_ ex: WorkoutExerciseInfo) -> some View {
        let isDone = completed.contains(ex.id)

        return Button {
            if isDone {
                completed.remove(ex.id)
            } else {
                completed.insert(ex.id)
            }
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .strokeBorder(isDone ? Color.green : themeManager.primary, lineWidth: 2)
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: isDone ? "checkmark" : "play.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(isDone ? .green : themeManager.primary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? ex.nameAr : ex.nameEn)
                        .font(.subheadline.bold())
                        .foregroundColor(themeManager.textPrimary)

                    Text(
                        "\(ex.sets)x\(ex.reps) • \(isArabic ? "راحة" : "Rest") \(ex.restSeconds)s"
                    )
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                }

                Spacer()
            }
            .padding(10)
            .background(themeManager.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "ملخص الجلسة" : "Session summary")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "\(completed.count) / \(exercises.count) تمرين مكتمل."
                : "\(completed.count) / \(exercises.count) exercises completed."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            Text(
                isArabic
                ? "السعرات و XP هنا تقديرية حسب البرنامج: \(program.calories) kcal • \(program.xpReward) XP."
                : "Calories & XP are estimated from this program: \(program.calories) kcal • \(program.xpReward) XP."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(radius: 3)
    }
}

#Preview {
    NavigationStack {
        ProgramDetailView(program: .demo)
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
