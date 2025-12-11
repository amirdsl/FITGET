//
//  StepsTrackerView.swift
//  FITGET
//

import SwiftUI

struct StepsTrackerView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    @ObservedObject private var healthManager = HealthKitManager.shared
    private let progressManager = ProgressManager.shared   // للربط مع لوحة الرئيسية

    // هدف افتراضي للخطوات (لاحقًا يمكن ربطه من الإعدادات)
    private let dailyStepsGoal: Int = 8000

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var distanceKmText: String {
        let km = healthManager.todayDistance / 1000.0
        return String(format: "%.2f", km)
    }

    private var caloriesText: String {
        String(format: "%.0f", healthManager.todayActiveCalories)
    }

    private var stepsProgress: Double {
        guard dailyStepsGoal > 0 else { return 0 }
        return min(Double(healthManager.todaySteps) / Double(dailyStepsGoal), 1.0)
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    goalSection
                    metricsSection
                    heartRateSection
                    statusSection
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(isArabic ? "الخطوات" : "Steps")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // طلب الصلاحيات والمزامنة بشكل أوتوماتيكي عند فتح الشاشة
            await healthManager.requestAuthorization()
        }
        // ربط تلقائي مع ProgressManager حتى تظهر نفس الأرقام في HomeDashboard
        .onChange(of: healthManager.todaySteps) { newValue in
            progressManager.todaySteps = newValue
        }
        .onChange(of: healthManager.todayActiveCalories) { newValue in
            progressManager.todayCalories = Int(newValue.rounded())
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.primary.opacity(0.95),
                                themeManager.accent.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                    .shadow(color: themeManager.primary.opacity(0.45), radius: 10, x: 0, y: 4)

                Image(systemName: "figure.walk")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? "نشاطك اليوم" : "Your activity today")
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.textPrimary)

                Text(
                    isArabic
                    ? "الخطوات والمسافة والسعرات يتم قراءتها تلقائيًا من Apple Health."
                    : "Steps, distance and calories are synced automatically from Apple Health."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    // MARK: - Goal section (progress ring)

    private var goalSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(themeManager.cardBackground, lineWidth: 12)

                Circle()
                    .trim(from: 0, to: stepsProgress)
                    .stroke(
                        AngularGradient(
                            colors: [
                                themeManager.primary,
                                themeManager.accent,
                                themeManager.primary
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(healthManager.todaySteps)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.textPrimary)
                    Text(isArabic ? "خطوة" : "steps")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
            .frame(width: 110, height: 110)

            VStack(alignment: .leading, spacing: 8) {
                Text(isArabic ? "هدف اليوم" : "Today's goal")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)

                Text(
                    isArabic
                    ? "هدفك اليومي هو \(dailyStepsGoal) خطوة. حاول الوصول لـ ٧٠٪ على الأقل للمحافظة على صحتك."
                    : "Your daily goal is \(dailyStepsGoal) steps. Aim for at least 70% to maintain a healthy activity level."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

                ProgressView(
                    value: stepsProgress,
                    total: 1.0
                ) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(Int(stepsProgress * 100))%")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                }
                .tint(themeManager.primary)
            }

            Spacer()
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    // MARK: - Metrics

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "إحصائيات اليوم" : "Today's stats")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            HStack(spacing: 12) {
                metricCard(
                    titleAR: "الخطوات",
                    titleEN: "Steps",
                    value: "\(healthManager.todaySteps)",
                    subtitleAR: "إجمالي خطوات اليوم",
                    subtitleEN: "Total steps today",
                    systemIcon: "figure.walk"
                )

                metricCard(
                    titleAR: "السعرات الفعّالة",
                    titleEN: "Active kcal",
                    value: caloriesText,
                    subtitleAR: "السعرات المحروقة في النشاط",
                    subtitleEN: "Active calories burned",
                    systemIcon: "flame.fill"
                )
            }

            HStack(spacing: 12) {
                metricCard(
                    titleAR: "المسافة",
                    titleEN: "Distance",
                    value: distanceKmText + " km",
                    subtitleAR: "المسافة المقطوعة اليوم",
                    subtitleEN: "Distance walked/run today",
                    systemIcon: "ruler"
                )

                Spacer()
            }
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private func metricCard(
        titleAR: String,
        titleEN: String,
        value: String,
        subtitleAR: String,
        subtitleEN: String,
        systemIcon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: systemIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primary)
                Spacer()
            }

            Text(isArabic ? titleAR : titleEN)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.textSecondary)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.textPrimary)

            Text(isArabic ? subtitleAR : subtitleEN)
                .font(.system(size: 11))
                .foregroundColor(themeManager.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Heart Rate

    private var heartRateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "معدل النبض" : "Heart rate")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            if let hr = healthManager.currentHeartRate {
                HStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.red)

                    Text(String(format: "%.0f", hr))
                        .font(.title2.bold())
                        .foregroundColor(themeManager.textPrimary)

                    Text("BPM")
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)

                    Spacer()
                }
                .padding(12)
                .background(themeManager.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            } else {
                Text(
                    isArabic
                    ? "لم يتم استقبال قراءة نبض اليوم بعد. تأكد من ارتداء الساعة أثناء الحركة."
                    : "No heart rate reading yet today. Make sure you wear your watch during activity."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            }
        }
    }

    // MARK: - Status / errors

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "حالة المزامنة" : "Sync status")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            if !healthManager.isHealthAvailable {
                Text(isArabic ? "HealthKit غير متوفر على هذا الجهاز." : "HealthKit is not available on this device.")
                    .font(.caption)
                    .foregroundColor(.red)
            } else if !healthManager.isAuthorized {
                Text(
                    isArabic
                    ? "لم يتم منح صلاحيات الوصول إلى بيانات الصحة بعد. تأكد من تفعيل الصلاحيات في تطبيق Health."
                    : "Health data access is not authorized yet. Please enable permissions in the Health app."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            } else {
                Text(
                    isArabic
                    ? "المزامنة تعمل تلقائيًا من هاتفك/ساعتك. سيتم تحديث الأرقام عند وصول بيانات جديدة."
                    : "Sync runs automatically from your phone/watch. Values update when new data arrives."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            }

            if let error = healthManager.lastError {
                Text(error.localizedDescription)
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        StepsTrackerView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
