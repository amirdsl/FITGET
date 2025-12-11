//
//  StepsOverviewView.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import SwiftUI

struct StepsOverviewView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var progressManager = ProgressManager.shared
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    private let dailyStepsTarget = 10_000
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    header
                    summaryCards
                    weekSummaryCard
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                .padding(.top, 12)
            }
        }
        .navigationTitle(isArabic ? "الخطوات" : "Steps")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    // MARK: - Header
    
    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            AppGradients.electricBlue
                .appCardCornerRadius()
                .appShadow(AppShadows.softElevated)
                .frame(height: 180)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "figure.walk.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
                
                Text(isArabic ? "نشاط اليوم" : "Today’s Activity")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(progressManager.todaySteps)")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(isArabic ? "خطوة" : "steps")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                let ratio = min(
                    CGFloat(progressManager.todaySteps) /
                    CGFloat(max(dailyStepsTarget, 1)),
                    1
                )
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.18))
                        .frame(height: 10)
                    
                    GeometryReader { geo in
                        Capsule()
                            .fill(Color.white)
                            .frame(width: ratio * geo.size.width, height: 10)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Text(isArabic ? "هدفك" : "Your goal")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Text("\(dailyStepsTarget) \(isArabic ? "خطوة" : "steps")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(18)
        }
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(isArabic ? "السعرات التقديرية" : "Estimated calories")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                Text("\(progressManager.todayCalories)")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Text(isArabic ? "من الحركة اليوم." : "from today’s movement.")
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            }
            .padding()
            .background(themeManager.cardBackground)
            .cornerRadius(18)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(isArabic ? "سلسلة الأيام" : "Streak")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                Text("\(progressManager.currentStreak)")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Text(isArabic ? "أيام متتالية نشطة." : "active days in a row.")
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            }
            .padding()
            .background(themeManager.cardBackground)
            .cornerRadius(18)
        }
    }
    
    // MARK: - Weekly summary (Placeholder)
    
    private var weekSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "إجمالي الأسبوع" : "This week total")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            Text(isArabic ?
                 "لاحقًا نعرض مخطط لآخر ٧ أيام من جدول user_daily_activity في Supabase."
                 :
                    "Later we’ll show a 7-day chart from user_daily_activity in Supabase."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
    }
}

#Preview {
    NavigationStack {
        StepsOverviewView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
