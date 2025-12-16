//
//  AchievementsView.swift
//  FITGET
//
//  Created on 25/11/2025.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var challengesManager = ChallengesManager.shared
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Banner للمستوى + XP
                    LevelBannerView()
                        .environmentObject(themeManager)
                        .environmentObject(languageManager)
                    
                    // إنجازات نشاط اليوم (تمارين)
                    achievementsSection(
                        titleAR: "إنجازات النشاط",
                        titleEN: "Activity achievements",
                        items: activityRows
                    )
                    
                    // إنجازات السلسلة (Streak)
                    achievementsSection(
                        titleAR: "إنجازات السلاسل",
                        titleEN: "Streak achievements",
                        items: streakRows
                    )
                    
                    // زر الإنتقال إلى شارات الإنجاز
                    NavigationLink {
                        BadgesView()
                    } label: {
                        badgesPreviewCard
                    }
                }
                .padding()
            }
        }
        .navigationTitle(isArabic ? "الإنجازات والمستويات" : "Achievements & Levels")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    // MARK: - Data
    
    private var activityRows: [AchievementRowData] {
        [
            AchievementRowData(
                icon: "dumbbell",
                titleAR: "إنهاء تمرين واحد اليوم",
                titleEN: "Complete 1 workout today",
                descriptionAR: "ابدأ يومك بإنهاء جلسة تمرين واحدة.",
                descriptionEN: "Kick off your day with one workout session.",
                current: progressManager.todayWorkouts,
                target: 1,
                xpReward: 50
            ),
            AchievementRowData(
                icon: "dumbbell.fill",
                titleAR: "3 تمارين في اليوم",
                titleEN: "3 workouts in a day",
                descriptionAR: "ادفع نفسك أكثر وأنهِ ثلاث جلسات في يوم واحد.",
                descriptionEN: "Push harder and complete 3 workouts in a day.",
                current: progressManager.todayWorkouts,
                target: 3,
                xpReward: 120
            )
        ]
    }
    
    private var streakRows: [AchievementRowData] {
        [
            AchievementRowData(
                icon: "flame",
                titleAR: "سلسلة 3 أيام",
                titleEN: "3-day streak",
                descriptionAR: "حافظ على نشاطك 3 أيام متتالية.",
                descriptionEN: "Stay active 3 days in a row.",
                current: progressManager.longestStreak,
                target: 3,
                xpReward: 80
            ),
            AchievementRowData(
                icon: "flame.fill",
                titleAR: "سلسلة 7 أيام",
                titleEN: "7-day streak",
                descriptionAR: "أسبوع كامل من الالتزام بدون انقطاع.",
                descriptionEN: "A full week of consistency.",
                current: progressManager.longestStreak,
                target: 7,
                xpReward: 200
            )
        ]
    }
    
    // MARK: - Sections
    
    private func achievementsSection(
        titleAR: String,
        titleEN: String,
        items: [AchievementRowData]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? titleAR : titleEN)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(items) { item in
                    AchievementRowView(data: item, isArabic: isArabic)
                        .environmentObject(themeManager)
                }
            }
        }
    }
    
    private var badgesPreviewCard: some View {
        HStack(spacing: 12) {
            ZStack {
                AppGradients.prestigePurple
                    .appCardCornerRadius()
                Image(systemName: "medal.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? "شارات الإنجاز" : "Achievement badges")
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.textPrimary)
                
                Text(isArabic ?
                     "شاهد الميداليات التي حصلت عليها من التحديات والتمارين والسلاسل."
                     :
                     "See the medals you’ve earned from challenges, workouts, and streaks."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: isArabic ? "chevron.left" : "chevron.right")
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
    }
}

// MARK: - Row models

struct AchievementRowData: Identifiable {
    let id = UUID()
    let icon: String
    let titleAR: String
    let titleEN: String
    let descriptionAR: String
    let descriptionEN: String
    let current: Int
    let target: Int
    let xpReward: Int
    
    var isCompleted: Bool {
        current >= target
    }
}

struct AchievementRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let data: AchievementRowData
    let isArabic: Bool
    
    private var progress: Double {
        guard data.target > 0 else { return 0 }
        return min(Double(data.current) / Double(data.target), 1.0)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(themeManager.cardBackground)
                    .frame(width: 44, height: 44)
                
                Image(systemName: data.icon)
                    .font(.title3)
                    .foregroundColor(
                        data.isCompleted ? .green : AppColors.primaryBlue
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(isArabic ? data.titleAR : data.titleEN)
                        .font(.subheadline.bold())
                        .foregroundColor(themeManager.textPrimary)
                    
                    Spacer()
                    
                    if data.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Text(isArabic ? data.descriptionAR : data.descriptionEN)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                ProgressView(value: progress)
                    .tint(AppColors.primaryBlue)
                
                HStack {
                    Text("\(min(data.current, data.target)) / \(data.target)")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Spacer()
                    
                    if data.xpReward > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                            Text("+\(data.xpReward) XP")
                        }
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                    }
                }
            }
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }
}
