//
//  PhysioHubView.swift
//  FITGET
//

import SwiftUI

struct PhysioHubView: View {
    // نستخدم الـ Singleton
    @StateObject private var physioService = PhysioRemoteService.shared

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    @State private var selectedBodyArea: String? = nil   // "knee" / "shoulder" / nil
    @State private var isShowingFilterSheet = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                headerCard

                if physioService.isLoading && physioService.programs.isEmpty {
                    ProgressView()
                        .padding()
                    Spacer()
                } else if physioService.programs.isEmpty {
                    emptyState
                } else {
                    programList
                }
            }
        }
        .navigationTitle(isArabic ? "التأهيل والعلاج الطبيعي" : "Physio & Rehab")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // أول تحميل من الـ backend
            await physioService.loadPrograms(bodyArea: selectedBodyArea)
        }
        .sheet(isPresented: $isShowingFilterSheet) {
            PhysioBodyAreaFilterSheet(
                selectedBodyArea: $selectedBodyArea,
                onApply: {
                    Task {
                        await physioService.loadPrograms(bodyArea: selectedBodyArea)
                    }
                }
            )
            .environmentObject(languageManager)
            .environmentObject(themeManager)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primary, themeManager.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)

            VStack(alignment: isArabic ? .trailing : .leading, spacing: 10) {
                HStack {
                    VStack(alignment: isArabic ? .trailing : .leading, spacing: 6) {
                        Text(isArabic ? "برامج التأهيل" : "Rehab programs")
                            .font(.headline.bold())
                            .foregroundColor(.white)

                        Text(
                            isArabic
                            ? "اختر برنامجاً تأهيلياً مناسباً لمشكلتك أو منطقة الجسم المصابة."
                            : "Pick a rehab program that matches your pain or body area."
                        )
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Image(systemName: "cross.case.fill")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)

                        Text("\(physioService.programs.count)")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.95))

                        Text(isArabic ? "برنامج متاح" : "programs")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                HStack {
                    Button {
                        isShowingFilterSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(
                                selectedBodyArea == nil
                                ? (isArabic ? "كل المناطق" : "All areas")
                                : areaLabel(selectedBodyArea ?? "")
                            )
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.16))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                    }

                    Spacer()

                    if physioService.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(0.7)
                    }
                }
            }
            .padding(16)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func areaLabel(_ area: String) -> String {
        switch area {
        case "knee":     return isArabic ? "الركبة" : "Knee"
        case "shoulder": return isArabic ? "الكتف" : "Shoulder"
        case "back":     return isArabic ? "أسفل الظهر" : "Low back"
        default:         return area
        }
    }

    // MARK: - List

    private var programList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(physioService.programs) { program in
                    NavigationLink {
                        PhysioProgramDetailView(
                            program: program,
                            physioService: physioService
                        )
                    } label: {
                        PhysioProgramRow(
                            program: program,
                            isArabic: isArabic,
                            themeManager: themeManager
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 16)
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 40))
                .foregroundColor(themeManager.primary.opacity(0.8))

            Text(isArabic ? "لا توجد برامج متاحة حالياً" : "No programs available yet")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "سيتم إضافة المزيد من برامج التأهيل قريباً. جرّب تغيير منطقة الجسم أو تحديث الصفحة."
                : "More rehab programs will be added soon. Try changing the body area or refreshing."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Row view

struct PhysioProgramRow: View {
    let program: PhysioProgram
    let isArabic: Bool
    let themeManager: ThemeManager

    private var titleText: String {
        let nameAr = (program.nameAr).trimmingCharacters(in: .whitespacesAndNewlines)
        let nameEn = (program.nameEn).trimmingCharacters(in: .whitespacesAndNewlines)

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

    private var difficultyText: String {
        let difficultyRaw = (program.difficulty ?? "")
        return difficultyRaw.localized(isArabic: isArabic)
    }

    private var durationWeeks: Int {
        program.durationWeeks
    }

    private var sessionsPerWeek: Int {
        program.sessionsPerWeek
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.primary.opacity(0.35),
                                themeManager.accent.opacity(0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(titleText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)
                    .lineLimit(2)

                if !descriptionText.isEmpty {
                    Text(descriptionText)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    pill("\(durationWeeks)w", systemImage: "calendar")
                    pill("\(sessionsPerWeek)x", systemImage: "figure.walk")

                    if !difficultyText.isEmpty {
                        pill(difficultyText, systemImage: "speedometer")
                    }
                }
                .font(.caption2)
            }

            Spacer()
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }

    private func pill(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(themeManager.primary.opacity(0.06))
        .cornerRadius(10)
        .foregroundColor(themeManager.textSecondary)
    }
}

// MARK: - Filter Sheet

struct PhysioBodyAreaFilterSheet: View {
    @Binding var selectedBodyArea: String?
    var onApply: () -> Void

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private let areas: [(id: String?, labelAr: String, labelEn: String)] = [
        (nil, "كل المناطق", "All areas"),
        ("knee", "الركبة", "Knee"),
        ("shoulder", "الكتف", "Shoulder"),
        ("back", "أسفل الظهر", "Low back")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(areas, id: \.id) { area in
                    Button {
                        selectedBodyArea = area.id
                        onApply()
                    } label: {
                        HStack {
                            Text(isArabic ? area.labelAr : area.labelEn)
                            Spacer()
                            if area.id == selectedBodyArea {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeManager.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isArabic ? "منطقة الجسم" : "Body area")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Difficulty localization helper

extension String {
    /// تحويل مستوى الصعوبة إلى نص مناسب للغة الحالية
    func localized(isArabic: Bool) -> String {
        switch self.lowercased() {
        case "easy":
            return isArabic ? "سهل" : "Easy"
        case "medium":
            return isArabic ? "متوسط" : "Medium"
        case "hard":
            return isArabic ? "صعب" : "Hard"
        default:
            return self
        }
    }
}
