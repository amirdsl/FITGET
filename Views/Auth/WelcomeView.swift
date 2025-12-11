//
//  WelcomeView.swift
//  Fitget
//
//  Path: Fitget/Views/Auth/WelcomeView.swift
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var showLogin = false
    @State private var showRegister = false
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "0091ff"), Color(hex: "00d4ff")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }
                        
                        Text("FITGET")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundColor(themeManager.textPrimary)
                        
                        Text(isArabic ? "رحلتك نحو جسم أفضل تبدأ من هنا" : "Your journey to a better body starts here")
                            .font(.subheadline)
                            .foregroundColor(themeManager.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        PrimaryButton(
                            title: isArabic ? "تسجيل الدخول" : "Sign In",
                            action: { showLogin = true }
                        )
                        
                        Button {
                            showRegister = true
                        } label: {
                            Text(isArabic ? "إنشاء حساب جديد" : "Create a new account")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 30)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(AuthenticationManager.shared)
}
