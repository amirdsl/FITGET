//
//  SplashView.swift
//  Fitget
//
//  شاشة ترحيب متحركة مع خلفية متدرجة
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var animateLogo = false
    @State private var animateBG = false
    
    var isArabic: Bool { languageManager.currentLanguage == "ar" }
    
    var body: some View {
        ZStack {
            // خلفية متدرجة متحركة
            LinearGradient(
                colors: [
                    AppColors.primaryBlue,
                    Color.purple,
                    Color.orange
                ],
                startPoint: animateBG ? .topLeading : .bottomTrailing,
                endPoint: animateBG ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true),
                       value: animateBG)
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .scaleEffect(animateLogo ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                   value: animateLogo)
                    
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                        .scaleEffect(animateLogo ? 1.0 : 0.6)
                        .opacity(animateLogo ? 1 : 0)
                        .animation(.spring(response: 0.9, dampingFraction: 0.7),
                                   value: animateLogo)
                }
                
                VStack(spacing: 8) {
                    Text(isArabic ? "FITGET" : "FITGET")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                    
                    Text(isArabic ? "رحلتك نحو لياقة أفضل تبدأ هنا" :
                            "Your fitness journey starts here")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .onAppear {
            animateBG = true
            animateLogo = true
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
}
