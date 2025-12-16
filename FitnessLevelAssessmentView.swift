//
//  FitnessLevelAssessmentView.swift
//  FITGET
//

import SwiftUI

struct FitnessLevelAssessmentView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // إجابات الاختبار (0..n حسب عدد الخيارات)
    @State private var q1 = 0
    @State private var q2 = 0
    @State private var q3 = 0
    @State private var q4 = 0

    private var totalScore: Int {
        q1 + q2 + q3 + q4
    }

    private var levelTitle: String {
        if totalScore <= 3 {
            return isArabic ? "مبتدئ" : "Beginner"
        } else if totalScore <= 7 {
            return isArabic ? "متوسط" : "Intermediate"
        } else {
            return isArabic ? "متقدم" : "Advanced"
        }
    }

    private var levelDescription: String {
        if totalScore <= 3 {
            return isArabic
            ? "مناسب لبرامج التأسيس، تعلم الأساسيات، تمارين وزن الجسم، والتركيز على التقنية."
            : "Best suited for base-building programs, learning technique and bodyweight-focused training."
        } else if totalScore <= 7 {
            return isArabic
            ? "مناسب لبرامج متوسطة تحتوي على أوزان معتدلة، تمارين مركبة، وتقدم تدريجي في الحجم والشدة."
            : "You fit well with intermediate programs using moderate weights, compound lifts and progressive overload."
        } else {
            return isArabic
            ? "مستوى متقدم – يمكنك العمل على برامج قوية، تقسيمات تدريب متقدمة، وتركيز على التفاصيل."
            : "Advanced level – you can handle demanding programs, advanced splits and more detailed periodization."
        }
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    questionsSection
                    resultSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(isArabic ? "تحديد مستوى اللياقة" : "Fitness level")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 6) {
            Text(isArabic ? "اعرف مستواك قبل اختيار البرنامج" : "Know your level before choosing a plan")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "جاوب بصراحة عن الأسئلة التالية، النتيجة ستساعدك تختار بين برامج المبتدئين، المتوسطة أو المتقدمة داخل التطبيق."
                : "Answer honestly. Your score will help you choose between beginner, intermediate or advanced programs."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }

    // MARK: - Questions

    private var questionsSection: some View {
        VStack(spacing: 12) {
            questionCard(
                index: 1,
                titleAR: "خبرتك السابقة مع التدريب",
                titleEN: "Your training experience",
                optionsAR: [
                    "لم أتمرن من قبل أو بشكل متقطع",
                    "أتمرن بانتظام منذ أقل من سنة",
                    "أتمرن بانتظام منذ أكثر من سنة"
                ],
                optionsEN: [
                    "I’m new or very inconsistent",
                    "Training regularly for < 1 year",
                    "Training regularly for > 1 year"
                ],
                selection: $q1
            )

            questionCard(
                index: 2,
                titleAR: "عدد حصص التمرين في الأسبوع",
                titleEN: "Weekly training frequency",
                optionsAR: [
                    "٠–١ حصة في الأسبوع",
                    "٢–٣ حصص في الأسبوع",
                    "٤ حصص أو أكثر في الأسبوع"
                ],
                optionsEN: [
                    "0–1 session / week",
                    "2–3 sessions / week",
                    "4+ sessions / week"
                ],
                selection: $q2
            )

            questionCard(
                index: 3,
                titleAR: "قدرتك على التمارين المركبة",
                titleEN: "Ability with compound lifts",
                optionsAR: [
                    "لا أمارس السكوات / الديدلفت / البنش بانتظام",
                    "أمارسها بأوزان خفيفة مع تقنية جيدة",
                    "أمارسها بأوزان متوسطة إلى عالية بثقة"
                ],
                optionsEN: [
                    "Rarely do squats / deadlifts / bench",
                    "Do them with light weights and good form",
                    "Comfortable with moderate to heavy loads"
                ],
                selection: $q3
            )

            questionCard(
                index: 4,
                titleAR: "التحمل في تمارين وزن الجسم",
                titleEN: "Bodyweight endurance",
                optionsAR: [
                    "أقل من ٨ ضغط أو ١٠ سكوات",
                    "بين ٨–٢٠ ضغط أو ١٠–٣٠ سكوات",
                    "أكثر من ٢٠ ضغط أو ٣٠ سكوات"
                ],
                optionsEN: [
                    "< 8 push-ups or < 10 squats",
                    "8–20 push-ups or 10–30 squats",
                    "20+ push-ups or 30+ squats"
                ],
                selection: $q4
            )
        }
    }

    private func questionCard(
        index: Int,
        titleAR: String,
        titleEN: String,
        optionsAR: [String],
        optionsEN: [String],
        selection: Binding<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(themeManager.primary.opacity(0.14))
                        .frame(width: 26, height: 26)
                    Text("\(index)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(themeManager.primary)
                }

                Text(isArabic ? titleAR : titleEN)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)

                Spacer()
            }

            VStack(spacing: 6) {
                let options = isArabic ? optionsAR : optionsEN

                ForEach(options.indices, id: \.self) { i in
                    let text = options[i]
                    let isSelected = selection.wrappedValue == i

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selection.wrappedValue = i
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                .font(.system(size: 16))
                                .foregroundColor(isSelected ? themeManager.primary : themeManager.textSecondary)

                            Text(text)
                                .font(.caption)
                                .foregroundColor(themeManager.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? themeManager.primary.opacity(0.08) : themeManager.secondaryBackground.opacity(0.9))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Result

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "نتيجتك الحالية" : "Your current level")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [themeManager.primary, themeManager.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 80)

                    VStack(spacing: 4) {
                        Text(levelTitle)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                        Text(isArabic ? "مستوى تقديري" : "Estimated level")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(levelDescription)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(
                        isArabic
                        ? "استخدم هذه النتيجة لاختيار البرامج المناسبة داخل التطبيق. يمكنك إعادة الاختبار بعد ٨–١٢ أسبوع."
                        : "Use this level to pick the right programs. You can repeat the assessment after 8–12 weeks."
                    )
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary.opacity(0.9))
                }
            }
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    NavigationStack {
        FitnessLevelAssessmentView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
