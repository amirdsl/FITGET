//
//  BadgesView.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import SwiftUI

struct BadgesView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var challengesManager = ChallengesManager.shared
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    private var badges: [Badge] {
        let pm = progressManager
        let cm = challengesManager
        
        return [
            Badge(
                icon: "medal.fill",
                color: .yellow,
                titleAR: "أول تمرين",
                titleEN: "First workout",
                descriptionAR: "أكملت أول جلسة تمرين.",
                descriptionEN: "You’ve completed your first workout.",
                unlocked: pm.todayWorkouts > 0
            ),
            Badge(
                icon: "flame.fill",
                color: .orange,
                titleAR: "سلسلة ٧ أيام",
                titleEN: "7-day streak",
                descriptionAR: "حافظت على نشاطك لمدة أسبوع كامل.",
                descriptionEN: "Stayed active for 7 days in a row.",
                unlocked: pm.longestStreak >= 7
            ),
            Badge(
                icon: "bolt.fill",
                color: .purple,
                titleAR: "1000 XP",
                titleEN: "1000 XP",
                descriptionAR: "جمعت 1000 نقطة خبرة أو أكثر.",
                descriptionEN: "You’ve accumulated at least 1000 XP.",
                unlocked: pm.totalXP >= 1000
            ),
            Badge(
                icon: "trophy.fill",
                color: .green,
                titleAR: "تحدي مكتمل",
                titleEN: "Challenge finisher",
                descriptionAR: "أكملت أول تحدي لك.",
                descriptionEN: "You’ve completed your first challenge.",
                unlocked: !cm.completedChallenges.isEmpty
            )
        ]
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(isArabic ? "شاراتك" : "Your badges")
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                        .padding(.top, 12)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                              spacing: 16) {
                        ForEach(badges) { badge in
                            badgeCard(badge)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(isArabic ? "شارات الإنجاز" : "Achievement badges")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    private func badgeCard(_ badge: Badge) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        badge.unlocked
                        ? Color.purple.opacity(0.7)
                        : Color.gray.opacity(0.25)
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: badge.icon)
                    .font(.system(size: 30))
                    .foregroundColor(
                        badge.unlocked ? badge.color : Color.gray.opacity(0.7)
                    )
            }
            
            Text(isArabic ? badge.titleAR : badge.titleEN)
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.textPrimary)
            
            Text(isArabic ? badge.descriptionAR : badge.descriptionEN)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.textSecondary)
                .lineLimit(3)
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    badge.unlocked ? AppColors.primaryBlue : Color.clear,
                    lineWidth: 1
                )
        )
        .opacity(badge.unlocked ? 1.0 : 0.55)
    }
    
    struct Badge: Identifiable {
        let id = UUID()
        let icon: String
        let color: Color
        let titleAR: String
        let titleEN: String
        let descriptionAR: String
        let descriptionEN: String
        let unlocked: Bool
    }
}

#Preview {
    NavigationStack {
        BadgesView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
