//
//  LevelBannerView.swift
//  FITGET
//
//  Created on 25/11/2025.
//

import SwiftUI

struct LevelBannerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    // نعتمد على ProgressManager بدل GamificationManager
    @ObservedObject private var progressManager = ProgressManager.shared
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? "مستواك الحالي" : "Your current level")
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text("Lv. \(progressManager.level)")
                        .font(.title2.bold())
                        .foregroundColor(themeManager.textPrimary)
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .foregroundColor(AppColors.primaryBlue)
                    .font(.title2)
            }
            
            let xp = Double(progressManager.totalXP)
            let total = Double(progressManager.xpForNextLevel)
            let progress = total > 0 ? xp / total : 0
            
            ProgressView(value: progress)
                .tint(AppColors.primaryBlue)
            
            HStack {
                Text(isArabic ? "الخبرة" : "XP")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                Spacer()
                Text("\(progressManager.totalXP) / \(progressManager.xpForNextLevel)")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(18)
    }
}

#Preview {
    LevelBannerView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(LanguageManager.shared)
}
