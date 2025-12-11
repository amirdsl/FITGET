//
//  SocialLoginButtonsView.swift
//  FITGET
//
//  أزرار تسجيل الدخول عبر جوجل / آبل (واجهة فقط)
//

import SwiftUI

struct SocialLoginButtonsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(themeManager.textSecondary.opacity(0.3))
                Text(isArabic ? "أو" : "OR")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(themeManager.textSecondary.opacity(0.3))
            }
            .padding(.vertical, 4)
            
            // Google
            Button {
                Task {
                    await authManager.signInWithOAuth(.google)
                }
            } label: {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title3)
                    Text(isArabic ? "تسجيل الدخول باستخدام جوجل" : "Continue with Google")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(themeManager.cardBackground)
                .cornerRadius(12)
            }
            .foregroundColor(themeManager.textPrimary)
            
            // Apple
            Button {
                Task {
                    await authManager.signInWithOAuth(.apple)
                }
            } label: {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.title3)
                    Text(isArabic ? "تسجيل الدخول باستخدام آبل" : "Continue with Apple")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(themeManager.cardBackground)
                .cornerRadius(12)
            }
            .foregroundColor(themeManager.textPrimary)
        }
    }
}

#Preview {
    SocialLoginButtonsView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(LanguageManager.shared)
}
