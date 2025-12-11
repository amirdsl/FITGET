//
//  BodyMetricsView.swift
//  FITGET
//

import SwiftUI

struct BodyMetricsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // MARK: - Models

    struct BodyMeasurements {
        var chest: String = ""
        var rightArm: String = ""
        var leftArm: String = ""
        var waist: String = ""
        var hips: String = ""
        var rightThigh: String = ""
        var leftThigh: String = ""
        var weight: String = ""
    }

    @State private var before = BodyMeasurements()
    @State private var after = BodyMeasurements()
    @State private var showingBefore = true

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header

                    toggleSegment

                    bodySilhouetteCard

                    measurementsForm

                    notesSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(isArabic ? "قياسات الجسم" : "Body measurements")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 6) {
            Text(
                isArabic
                ? "سجّل القياسات قبل وبعد البرنامج"
                : "Track your body before & after your program"
            )
            .font(.headline)
            .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "استخدم شريط القياس وسجّل القياسات بالسنتيمتر والوزن بالكيلوجرام. حاول القياس في نفس الظروف كل مرة."
                : "Use a tape measure for cm values and log weight in kg. Try to measure under similar conditions each time."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }

    // MARK: - Toggle (Before / After)

    private var toggleSegment: some View {
        HStack(spacing: 0) {
            segmentButton(
                title: isArabic ? "قبل" : "Before",
                isSelected: showingBefore
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingBefore = true
                }
            }

            segmentButton(
                title: isArabic ? "بعد" : "After",
                isSelected: !showingBefore
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingBefore = false
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(themeManager.cardBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func segmentButton(title: String,
                               isSelected: Bool,
                               action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : themeManager.textSecondary)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(themeManager.primary)
                                .padding(3)
                        } else {
                            Color.clear
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Body silhouette

    private var bodySilhouetteCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)

            HStack(spacing: 16) {
                // "رسم" الجسم
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [6, 4]))
                            .foregroundColor(themeManager.textSecondary.opacity(0.4))
                            .frame(width: 120, height: 200)

                        Image(systemName: "figure.stand")
                            .font(.system(size: 80, weight: .regular))
                            .foregroundColor(themeManager.textSecondary.opacity(0.6))
                    }

                    Text(showingBefore ? (isArabic ? "قبل" : "Before")
                                       : (isArabic ? "بعد" : "After"))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(themeManager.textSecondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    legendRow(label: "Chest", ar: "الصدر")
                    legendRow(label: "Upper arm", ar: "الذراع العلوية")
                    legendRow(label: "Waist", ar: "الخصر")
                    legendRow(label: "Hips", ar: "الحوض")
                    legendRow(label: "Thigh", ar: "الفخذ")
                    legendRow(label: "Weight", ar: "الوزن")
                }
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)

                Spacer()
            }
            .padding(14)
        }
    }

    private func legendRow(label: String, ar: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(themeManager.primary.opacity(0.18))
                .frame(width: 6, height: 6)
            Text(isArabic ? ar : label)
        }
    }

    // MARK: - Form (fields)

    private var measurementsForm: some View {
        let binding = showingBefore ? $before : $after

        return VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "القياسات (سم / كجم)" : "Measurements (cm / kg)")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(spacing: 10) {
                HStack {
                    measurementField(
                        titleAR: "الصدر",
                        titleEN: "Chest",
                        text: binding.chest,
                        unit: "cm"
                    )
                    measurementField(
                        titleAR: "الذراع اليمنى",
                        titleEN: "Right arm",
                        text: binding.rightArm,
                        unit: "cm"
                    )
                }

                HStack {
                    measurementField(
                        titleAR: "الذراع اليسرى",
                        titleEN: "Left arm",
                        text: binding.leftArm,
                        unit: "cm"
                    )
                    measurementField(
                        titleAR: "الخصر",
                        titleEN: "Waist",
                        text: binding.waist,
                        unit: "cm"
                    )
                }

                HStack {
                    measurementField(
                        titleAR: "الحوض",
                        titleEN: "Hips",
                        text: binding.hips,
                        unit: "cm"
                    )
                    measurementField(
                        titleAR: "الفخذ اليمنى",
                        titleEN: "Right thigh",
                        text: binding.rightThigh,
                        unit: "cm"
                    )
                }

                HStack {
                    measurementField(
                        titleAR: "الفخذ اليسرى",
                        titleEN: "Left thigh",
                        text: binding.leftThigh,
                        unit: "cm"
                    )
                    measurementField(
                        titleAR: "الوزن",
                        titleEN: "Weight",
                        text: binding.weight,
                        unit: "kg"
                    )
                }
            }
        }
    }

    private func measurementField(
        titleAR: String,
        titleEN: String,
        text: Binding<String>,
        unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isArabic ? titleAR : titleEN)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)

            HStack {
                TextField("0", text: text)
                    .keyboardType(.decimalPad)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(themeManager.textPrimary)

                Text(unit)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            .padding(8)
            .background(themeManager.secondaryBackground.opacity(0.9))
            .cornerRadius(10)
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? "ملاحظات" : "Notes")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "يمكنك إضافة صور قبل/بعد من شاشة التقدم لاحقاً لربطها بهذه القياسات."
                : "You can later attach before/after photos from the progress screen and link them to these measurements."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }
}

#Preview {
    NavigationStack {
        BodyMetricsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
