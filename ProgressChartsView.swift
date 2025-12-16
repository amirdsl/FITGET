//
//  ProgressChartsView.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import SwiftUI
import Charts

struct ProgressChartsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    // Placeholder بيانات تجريبية – لاحقًا نربطها بـ Supabase user_daily_activity
    private let days: [String] = ["Sat","Sun","Mon","Tue","Wed","Thu","Fri"]
    
    private var xpData: [ChartPoint] {
        days.enumerated().map { idx, d in
            ChartPoint(label: d, value: Double((idx + 1) * 30))
        }
    }
    
    private var stepsData: [ChartPoint] {
        days.enumerated().map { idx, d in
            ChartPoint(label: d, value: Double(3000 + idx * 800))
        }
    }
    
    private var caloriesData: [ChartPoint] {
        days.enumerated().map { idx, d in
            ChartPoint(label: d, value: Double(400 + idx * 60))
        }
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    chartCard(
                        title: isArabic ? "XP آخر ٧ أيام" : "XP – last 7 days",
                        data: xpData
                    )
                    
                    chartCard(
                        title: isArabic ? "الخطوات آخر ٧ أيام" : "Steps – last 7 days",
                        data: stepsData
                    )
                    
                    chartCard(
                        title: isArabic ? "السعرات المحروقة" : "Calories burned",
                        data: caloriesData
                    )
                }
                .padding()
            }
        }
        .navigationTitle(isArabic ? "مخططات التقدّم" : "Progress charts")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    private func chartCard(title: String, data: [ChartPoint]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            Chart(data) { point in
                LineMark(
                    x: .value("Day", point.label),
                    y: .value("Value", point.value)
                )
                PointMark(
                    x: .value("Day", point.label),
                    y: .value("Value", point.value)
                )
            }
            .frame(height: 180)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
    }
    
    struct ChartPoint: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
    }
}

#Preview {
    NavigationStack {
        ProgressChartsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
