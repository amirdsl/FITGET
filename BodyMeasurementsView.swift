//
//  BodyMeasurementsView.swift
//  FITGET
//
//  شاشة قياسات الجسم (قبل / بعد + مقاسات تفصيلية)
//

import SwiftUI

struct BodyMeasurementsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // MARK: - حقول قابلة للتعديل (لاحقًا تُربط بقاعدة البيانات)

    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var chest: String = ""
    @State private var waist: String = ""
    @State private var hips: String = ""
    @State private var arm: String = ""
    @State private var thigh: String = ""

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    silhouetteSection
                    currentMeasurementsSection
                    photosSection
                    noteSection
                }
                .padding(16)
            }
        }
        .navigationTitle(isArabic ? "قياسات الجسم" : "Body measurements")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 6) {
            Text(isArabic ? "تابع تغير جسمك بالأرقام" : "Track your body changes in numbers")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "سجّل الوزن والطول والمقاسات الرئيسية قبل بدء البرنامج، ثم أعد القياسات بعد ٤–٨ أسابيع لمتابعة التقدم."
                : "Record your weight, height and key circumferences before starting, then re-measure after 4–8 weeks to see progress."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }

    // MARK: - Silhouette + quick summary

    private var silhouetteSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)

            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.primary.opacity(0.18),
                                    themeManager.accent.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 160)

                    Image(systemName: "figure.stand")
                        .font(.system(size: 60, weight: .regular))
                        .foregroundColor(themeManager.primary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(isArabic ? "القياسات الأساسية" : "Key measurements")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.textPrimary)

                    VStack(alignment: .leading, spacing: 6) {
                        summaryLine(
                            labelAR: "الوزن",
                            labelEN: "Weight",
                            value: weight,
                            unit: "kg"
                        )
                        summaryLine(
                            labelAR: "الطول",
                            labelEN: "Height",
                            value: height,
                            unit: "cm"
                        )
                        summaryLine(
                            labelAR: "محيط الخصر",
                            labelEN: "Waist",
                            value: waist,
                            unit: "cm"
                        )
                    }

                    Text(
                        isArabic
                        ? "يمكنك تعديل الأرقام من الأسفل، وسيتم تحديث هذه البطاقة تلقائياً."
                        : "You can edit the numbers below and this card will update automatically."
                    )
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
    }

    private func summaryLine(labelAR: String,
                             labelEN: String,
                             value: String,
                             unit: String) -> some View {
        HStack(spacing: 4) {
            Text(isArabic ? labelAR : labelEN)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)

            Spacer()

            if value.isEmpty {
                Text(isArabic ? "—" : "—")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary.opacity(0.6))
            } else {
                Text("\(value) \(unit)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)
            }
        }
    }

    // MARK: - Detailed measurements (البيانات التفصيلية)

    private var currentMeasurementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "سجّل قياساتك الحالية" : "Enter your current measurements")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(spacing: 10) {
                measurementRow(
                    labelAR: "الوزن",
                    labelEN: "Weight",
                    binding: $weight,
                    unit: "kg"
                )
                measurementRow(
                    labelAR: "الطول",
                    labelEN: "Height",
                    binding: $height,
                    unit: "cm"
                )
                Divider()
                measurementRow(
                    labelAR: "محيط الصدر",
                    labelEN: "Chest",
                    binding: $chest,
                    unit: "cm"
                )
                measurementRow(
                    labelAR: "محيط الخصر",
                    labelEN: "Waist",
                    binding: $waist,
                    unit: "cm"
                )
                measurementRow(
                    labelAR: "محيط الحوض",
                    labelEN: "Hips",
                    binding: $hips,
                    unit: "cm"
                )
                Divider()
                measurementRow(
                    labelAR: "محيط الذراع",
                    labelEN: "Arm",
                    binding: $arm,
                    unit: "cm"
                )
                measurementRow(
                    labelAR: "محيط الفخذ",
                    labelEN: "Thigh",
                    binding: $thigh,
                    unit: "cm"
                )
            }
            .padding(12)
            .background(themeManager.cardBackground)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }

    private func measurementRow(labelAR: String,
                                labelEN: String,
                                binding: Binding<String>,
                                unit: String) -> some View {
        HStack(spacing: 10) {
            Text(isArabic ? labelAR : labelEN)
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary)

            Spacer()

            HStack(spacing: 4) {
                TextField("0", text: binding)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(themeManager.secondaryBackground.opacity(0.95))
                    .cornerRadius(10)
                    .frame(width: 70)

                Text(unit)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
    }

    // MARK: - Photos (before / after)

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "صور قبل / بعد" : "Before / after photos")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "يمكنك لاحقاً إضافة صورك من الأمام والجانب لمقارنة التغير بشكل بصري بجانب الأرقام."
                : "Later you’ll be able to add front / side photos to visually compare progress along with the numbers."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)

            HStack(spacing: 12) {
                photoPlaceholder(
                    titleAR: "صورة قبل",
                    titleEN: "Before",
                    systemImage: "photo"
                )
                photoPlaceholder(
                    titleAR: "صورة بعد",
                    titleEN: "After",
                    systemImage: "photo.on.rectangle"
                )
            }
        }
    }

    private func photoPlaceholder(titleAR: String,
                                  titleEN: String,
                                  systemImage: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(themeManager.secondaryBackground.opacity(0.95))

                VStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 30, weight: .regular))
                        .foregroundColor(themeManager.textSecondary)

                    Text(isArabic ? "إضافة صورة" : "Add photo")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
            .frame(height: 140)

            Text(isArabic ? titleAR : titleEN)
                .font(.caption.weight(.semibold))
                .foregroundColor(themeManager.textPrimary)
        }
    }

    // MARK: - Note / hint

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? "تلميح مهم" : "Important note")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "لا تركز على الرقم فقط؛ قياس الخصر، الصور، والأداء في التمرين تعطي صورة أوضح عن تطور جسمك من الميزان وحده."
                : "Don’t focus only on the scale number; waist size, photos and performance in workouts tell a better story than weight alone."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BodyMeasurementsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
