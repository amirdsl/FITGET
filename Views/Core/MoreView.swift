//
//  MoreView.swift
//  FITGET
//
//  Path: Fitget/Views/Core/MoreView.swift
//

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        NavigationStack {
            MoreSectionsScreen()
                .navigationTitle(isArabic ? "المزيد" : "More")
                .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
}

#Preview {
    MoreView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(NutritionManager.shared)
        .environmentObject(OnboardingManager.shared)
}
