//
//  LanguageSettingsView.swift
//  Fitget
//
//  Created on 22/11/2025.
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                List {
                    Section(header: Text(isArabic ? "اختر اللغة" : "Choose Language")) {
                        LanguageOption(
                            flag: "🇺🇸",
                            title: "English",
                            subtitle: "English",
                            isSelected: languageManager.currentLanguage == "en"
                        ) {
                            languageManager.changeLanguage(to: "en")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                dismiss()
                            }
                        }
                        
                        LanguageOption(
                            flag: "🇸🇦",
                            title: "العربية",
                            subtitle: "Arabic",
                            isSelected: languageManager.currentLanguage == "ar"
                        ) {
                            languageManager.changeLanguage(to: "ar")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                dismiss()
                            }
                        }
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(AppColors.info)
                            
                            Text(isArabic ? "سيتم تطبيق اللغة على كامل التطبيق" : "Language will be applied to the entire app")
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(isArabic ? "اللغة" : "Language")
    }
}

struct LanguageOption: View {
    let flag: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(flag)
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primaryBlue)
                        .font(.title3)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    LanguageSettingsView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
}
