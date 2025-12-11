//
//  CoachingPlanOverviewView.swift
//  FITGET
//
//  ملخص خطة التدريب والتغذية للمدرب الشخصي
//

import SwiftUI

struct CoachingPlanOverviewView: View {
    let isArabic: Bool

    @EnvironmentObject var themeManager: ThemeManager

    // في النسخة الكاملة ستأتي هذه البيانات من Supabase حسب خطة المستخدم
    private let sampleSplit = [
        "Day 1 – Upper Push",
        "Day 2 – Lower / Glutes",
        "Day 3 – Upper Pull",
        "Day 4 – Full body / Conditioning"
    ]

    private let sampleSplitAR = [
        "اليوم ١ – دفع علوي (صدر / كتف أمامي / تراي)",
        "اليوم ٢ – الجزء السفلي / الأرداف",
        "اليوم ٣ – سحب علوي (ظهر / باي)",
        "اليوم ٤ – جسم كامل / لياقة"
    ]

    private let sampleMealsAR = [
        "فطور: شوفان + بروتين + فاكهة",
        "غداء: بروتين (دجاج / لحم) + أرز / بطاطس + خضار",
        "سناك: زبادي عالي البروتين + مكسرات",
        "عشاء: بيض / تونة + سلطة"
    ]

    private let sampleMealsEN = [
        "Breakfast: Oats + protein + fruit",
        "Lunch: Protein (chicken/beef) + rice/potatoes + veggies",
        "Snack: High-protein yogurt + nuts",
        "Dinner: Eggs / tuna + salad"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header

                caloriesCard
                trainingSplitCard
                mealsCard
                rulesCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "خطة التدريب والتغذية" : "Coaching plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? "هذا مثال لشكل الخطة" : "Example of how your plan looks")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "في النسخة الكاملة سيقوم المدرب بتخصيص الأرقام والتقسيمات بناءً على بياناتك من النموذج والمتابعات الأسبوعية."
                : "In the full version your coach will customise all numbers and split based on your form and weekly check-ins."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Calories / macros card

    private var caloriesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isArabic ? "السعرات والماكروز" : "Calories & macros")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "flame.fill")
            }
            .foregroundColor(themeManager.textPrimary)

            HStack(spacing: 18) {
                macroItem(
                    title: isArabic ? "السعرات" : "Calories",
                    value: "2100 kcal"
                )
                macroItem(
                    title: "Protein",
                    value: "150 g"
                )
                macroItem(
                    title: "Carbs",
                    value: "190 g"
                )
                macroItem(
                    title: "Fat",
                    value: "65 g"
                )
            }

            Text(
                isArabic
                ? "هذه الأرقام مثال لشخص بوزن متوسط هدفه خسارة دهون مع الحفاظ على العضل."
                : "Numbers here are an example for a medium-weight person aiming for fat loss while keeping muscle."
            )
            .font(.caption2)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func macroItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(themeManager.textSecondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundColor(themeManager.textPrimary)
        }
    }

    // MARK: - Training split card

    private var trainingSplitCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isArabic ? "تقسيمة التمرين" : "Training split")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "dumbbell.fill")
            }
            .foregroundColor(themeManager.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array((isArabic ? sampleSplitAR : sampleSplit).enumerated()), id: \.offset) { index, text in
                    HStack(alignment: .top, spacing: 6) {
                        Text("\(index + 1).")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(themeManager.primary)
                        Text(text)
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    }
                }
            }

            Text(
                isArabic
                ? "يتم تعديل الأيام حسب جدولك وإمكانية التمرين في البيت أو النادي."
                : "Your coach will tweak days based on your schedule and whether you train at home or in the gym."
            )
            .font(.caption2)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Meals example card

    private var mealsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isArabic ? "مثال ليوم غذائي" : "Example day of eating")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "fork.knife.circle.fill")
            }
            .foregroundColor(themeManager.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(isArabic ? sampleMealsAR : sampleMealsEN, id: \.self) { line in
                    HStack(alignment: .top, spacing: 6) {
                        Circle()
                            .fill(themeManager.primary.opacity(0.25))
                            .frame(width: 5, height: 5)
                            .padding(.top, 4)
                        Text(line)
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    }
                }
            }

            Text(
                isArabic
                ? "يمكن استبدال الأطعمة بما يناسب عاداتك وثقافتك الغذائية مع الحفاظ على نفس القيم."
                : "Foods can be swapped to match your preferences and culture while keeping similar macros."
            )
            .font(.caption2)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Rules / guidelines

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isArabic ? "قواعد بسيطة للالتزام" : "Simple rules to follow")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "list.bullet.rectangle.portrait")
            }
            .foregroundColor(themeManager.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                ruleRow(
                    ar: "٣–٤ تمرينات رئيسية لكل حصة، مع ترك ١–٢ عدة في الخزان.",
                    en: "3–4 main movements per session, leaving 1–2 reps in the tank."
                )
                ruleRow(
                    ar: "حاول المشي ٦–٨ آلاف خطوة على الأقل أغلب الأيام.",
                    en: "Aim for 6–8k steps on most days."
                )
                ruleRow(
                    ar: "بروتين في أغلب الوجبات، وماء كافي على مدار اليوم.",
                    en: "Protein in most meals and enough water throughout the day."
                )
                ruleRow(
                    ar: "أرسل تحديثك الأسبوعي قبل موعد المتابعة المتفق عليه.",
                    en: "Send your weekly check-in before your agreed review day."
                )
            }
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func ruleRow(ar: String, en: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12))
                .foregroundColor(themeManager.primary)
                .padding(.top, 2)
            Text(isArabic ? ar : en)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        CoachingPlanOverviewView(isArabic: true)
            .environmentObject(ThemeManager.shared)
    }
}
