//
//  FitnessTestsView.swift
//  FITGET
//

import SwiftUI

struct FitnessTestsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // MARK: - Local model

    struct FitnessTest: Identifiable {
        let id = UUID()
        let icon: String
        let elementAR: String
        let elementEN: String
        let nameAR: String
        let nameEN: String
        let descriptionAR: String
        let descriptionEN: String
        let unit: String
    }

    @State private var results: [UUID: String] = [:]

    private var tests: [FitnessTest] {
        [
            FitnessTest(
                icon: "bolt.fill",
                elementAR: "سرعة",
                elementEN: "Speed",
                nameAR: "اختبار العدو 30 متر",
                nameEN: "30m sprint test",
                descriptionAR: "الجري بأقصى سرعة لمسافة 30 متر وتسجيل الزمن بالثواني.",
                descriptionEN: "Run 30 meters at full speed and record your time in seconds.",
                unit: "sec"
            ),
            FitnessTest(
                icon: "hand.raised.fill",
                elementAR: "قوة",
                elementEN: "Strength",
                nameAR: "اختبار الضغط في دقيقة",
                nameEN: "1-min push-up test",
                descriptionAR: "أكبر عدد من تمارين الضغط في 60 ثانية مع تقنية صحيحة.",
                descriptionEN: "Maximum number of push-ups in 60 seconds with proper form.",
                unit: isArabic ? "عدّات" : "reps"
            ),
            FitnessTest(
                icon: "figure.run",
                elementAR: "رشاقة",
                elementEN: "Agility",
                nameAR: "اختبار الجري المتعرج 5-10-5",
                nameEN: "5-10-5 shuttle test",
                descriptionAR: "الانتقال يمين/يسار بين 3 نقاط بسرعة، المسافة الإجمالية 20 متر تقريباً.",
                descriptionEN: "Change direction quickly between 3 cones, total distance ≈ 20 m.",
                unit: "sec"
            ),
            FitnessTest(
                icon: "figure.cooldown",
                elementAR: "مرونة",
                elementEN: "Flexibility",
                nameAR: "اختبار الجلوس والوصول",
                nameEN: "Sit-and-reach test",
                descriptionAR: "الجلوس ومد الذراعين للأمام فوق مسطرة وتسجيل أقصى مسافة تصل لها.",
                descriptionEN: "Sit and reach forward over a ruler, record the furthest distance reached.",
                unit: "cm"
            ),
            FitnessTest(
                icon: "heart.fill",
                elementAR: "تحمل دوري تنفسي",
                elementEN: "Cardio endurance",
                nameAR: "اختبار الجري 6 دقائق",
                nameEN: "6-minute run test",
                descriptionAR: "الركض أو المشي السريع لأطول مسافة ممكنة في 6 دقائق.",
                descriptionEN: "Run / power-walk as far as possible in 6 minutes.",
                unit: "m"
            )
        ]
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header

                    ForEach(tests) { test in
                        testCard(test)
                    }

                    legendSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(isArabic ? "اختبارات اللياقة" : "Fitness tests")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 6) {
            Text(isArabic ? "قيّم مستواك الحالي" : "Assess your current fitness")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "نفّذ هذه الاختبارات قبل بدء البرنامج ثم بعد ٤–٨ أسابيع لملاحظة التطور في السرعة والقوة والرشاقة والمرونة والتحمل."
                : "Do these tests before starting your plan and again after 4–8 weeks to see your progress in speed, strength, agility, flexibility and endurance."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }

    // MARK: - Test card

    private func testCard(_ test: FitnessTest) -> some View {
        let resultBinding = Binding(
            get: { results[test.id] ?? "" },
            set: { results[test.id] = $0 }
        )

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.primary.opacity(0.12))
                        .frame(width: 46, height: 46)

                    Image(systemName: test.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(themeManager.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? test.elementAR : test.elementEN)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(themeManager.textSecondary)

                    Text(isArabic ? test.nameAR : test.nameEN)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            Text(isArabic ? test.descriptionAR : test.descriptionEN)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(isArabic ? "نتيجتك:" : "Your result:")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)

                Spacer()

                HStack(spacing: 4) {
                    TextField("0", text: resultBinding)
                        .keyboardType(.decimalPad)
                        .frame(width: 70)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(themeManager.textPrimary)
                        .padding(.vertical, 4)
                        .background(themeManager.secondaryBackground.opacity(0.9))
                        .cornerRadius(8)

                    Text(test.unit)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Legend

    private var legendSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? "كيف أستخدم النتائج؟" : "How to use these results?")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "يمكنك حفظ النتائج كمرجع شخصي، أو مشاركتها مع المدرب الشخصي داخل التطبيق لاحقاً لتحديد مستوى لياقتك بشكل أدق."
                : "You can keep these values as a personal baseline, or share them later with your online coach to better define your training level."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }
}

#Preview {
    NavigationStack {
        FitnessTestsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
