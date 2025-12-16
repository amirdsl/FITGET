//
//  TipDetailView.swift
//  FITGET
//
//  Created on 25/11/2025.
//

import SwiftUI

struct TipDetailView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    let tip: Tip
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(tip.title(isArabic: isArabic))
                    .font(.title2.bold())
                    .foregroundColor(themeManager.textPrimary)
                
                Text(isArabic ? tip.category.titleAR : tip.category.titleEN)
                    .font(.subheadline)
                    .foregroundColor(themeManager.textSecondary)
                
                Divider()
                
                Text(tip.body(isArabic: isArabic))
                    .font(.body)
                    .foregroundColor(themeManager.textPrimary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "نصيحة" : "Tip")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }
}

#Preview {
    NavigationStack {
        TipDetailView(
            tip: Tip(
                titleAR: "اشرب الماء",
                titleEN: "Drink water",
                bodyAR: "الماء مهم لكل وظائف الجسم تقريبًا، حاول شربه بانتظام خلال اليوم.",
                bodyEN: "Water is essential for almost every body function. Drink it regularly throughout the day.",
                category: .hydration
            )
        )
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
    }
}
