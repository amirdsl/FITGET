//
//  ProgressTrackingView.swift
//  Fitget
//
//  Created on 20/11/2025.
//

import SwiftUI

struct ProgressTrackingView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var measurements: [BodyMeasurement] = []
    @State private var selectedRange = "3m"
    
    var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    let ranges = ["1m", "3m", "6m", "12m"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1a1a2e").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // نطاق الزمن
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ranges, id: \.self) { range in
                                    FilterChip(
                                        title: rangeTitle(range),
                                        isSelected: selectedRange == range
                                    ) {
                                        selectedRange = range
                                        loadMeasurements()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        // الوزن
                        weightSection
                        
                        // قياسات الجسم
                        bodyMeasurementsSection
                        
                        // صور التقدم
                        progressPhotosSection
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(isArabic ? "قياس التقدم" : "Progress Tracking")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: إضافة قياس
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "00d4ff"))
                    }
                }
            }
            .onAppear {
                loadMeasurements()
            }
        }
    }
    
    var weightSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(isArabic ? "تطور الوزن" : "Weight Progress")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            // رسم تخيلي بسيط (أعمدة)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(measurements) { m in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "00d4ff"), Color(hex: "0091ff")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 22, height: getBarHeight(for: m.weight ?? 0))
                            
                            Text(shortDate(m.measuredAt))
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            
            if let last = measurements.last, let w = last.weight {
                Text((isArabic ? "آخر وزن مسجل: " : "Last recorded weight: ") + "\(String(format: "%.1f", w)) kg")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
        }
    }
    
    var bodyMeasurementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(isArabic ? "قياسات الجسم" : "Body Measurements")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if let last = measurements.last {
                VStack(spacing: 10) {
                    MeasurementRow(
                        title: isArabic ? "الصدر" : "Chest",
                        value: last.chest
                    )
                    MeasurementRow(
                        title: isArabic ? "الخصر" : "Waist",
                        value: last.waist
                    )
                    MeasurementRow(
                        title: isArabic ? "الذراع" : "Biceps",
                        value: last.biceps
                    )
                    MeasurementRow(
                        title: isArabic ? "الفخذ" : "Thighs",
                        value: last.thighs
                    )
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(15)
                .padding(.horizontal)
            } else {
                Text(isArabic ? "لا توجد قياسات بعد" : "No measurements yet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
    }
    
    var progressPhotosSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(isArabic ? "صور التقدم" : "Progress Photos")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                ProgressPhotoPlaceholder(title: isArabic ? "أمامي" : "Front")
                ProgressPhotoPlaceholder(title: isArabic ? "جانبي" : "Side")
                ProgressPhotoPlaceholder(title: isArabic ? "خلفي" : "Back")
            }
            .padding(.horizontal)
        }
    }
    
    func loadMeasurements() {
        // TODO: جلب من Supabase حسب المدى الزمني
        measurements = [
            BodyMeasurement(
                id: UUID(),
                userId: UUID(),
                weight: 80.0,
                bodyFatPercentage: 18.0,
                chest: 105,
                waist: 88,
                hips: 100,
                biceps: 36,
                thighs: 55,
                calves: 38,
                shoulders: 120,
                neck: 38,
                measuredAt: Date().addingTimeInterval(-7 * 24 * 3600)
            ),
            BodyMeasurement(
                id: UUID(),
                userId: UUID(),
                weight: 78.5,
                bodyFatPercentage: 17.0,
                chest: 106,
                waist: 86,
                hips: 100,
                biceps: 37,
                thighs: 56,
                calves: 38,
                shoulders: 121,
                neck: 38,
                measuredAt: Date()
            )
        ]
    }
    
    func rangeTitle(_ range: String) -> String {
        if !isArabic { return range }
        switch range {
        case "1m": return "شهر"
        case "3m": return "3 أشهر"
        case "6m": return "6 أشهر"
        case "12m": return "سنة"
        default: return range
        }
    }
    
    func getBarHeight(for weight: Double) -> CGFloat {
        // تبسيط: كل 1 كجم = 3 نقطة ارتفاع
        return CGFloat(weight) * 3
    }
    
    func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d/M"
        return f.string(from: date)
    }
}

struct BodyMeasurement: Identifiable {
    let id: UUID
    let userId: UUID
    let weight: Double?
    let bodyFatPercentage: Double?
    let chest: Double?
    let waist: Double?
    let hips: Double?
    let biceps: Double?
    let thighs: Double?
    let calves: Double?
    let shoulders: Double?
    let neck: Double?
    let measuredAt: Date
}

struct MeasurementRow: View {
    let title: String
    let value: Double?
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(valueText)
                .foregroundColor(.white)
        }
    }
    
    var valueText: String {
        if let v = value {
            return String(format: "%.1f cm", v)
        }
        return "--"
    }
}

struct ProgressPhotoPlaceholder: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 90, height: 120)
                
                Image(systemName: "camera.fill")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

#Preview {
    ProgressTrackingView()
        .environmentObject(LanguageManager.shared)
}
