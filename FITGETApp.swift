//
//  FITGETApp.swift
//  FITGET
//

import SwiftUI

@main
struct FITGETApp: App {
    // MARK: - Shared Managers (Singleton-style)

    @StateObject var languageManager = LanguageManager.shared
    @StateObject var themeManager = ThemeManager.shared
    @StateObject var authManager = AuthenticationManager.shared
    @StateObject var cartManager = CartManager.shared
    @StateObject var tipsManager = TipsManager.shared
    @StateObject var notificationsManager = NotificationsManager.shared
    @StateObject var onboardingManager = OnboardingManager.shared
    @StateObject var gamificationManager = GamificationManager.shared
    @StateObject var nutritionManager = NutritionManager.shared

    var body: some Scene {
        WindowGroup {
            RootDirectionView {
                RootWithSplashView {
                    // الجذر الفعلي للتطبيق: يدير تسجيل الدخول + التبويبات الرئيسية
                    AppRootView()
                }
            }
            // MARK: - Environment Objects (متاحة في كل الواجهات)
            .environmentObject(languageManager)
            .environmentObject(themeManager)
            .environmentObject(authManager)
            .environmentObject(cartManager)
            .environmentObject(tipsManager)
            .environmentObject(notificationsManager)
            .environmentObject(onboardingManager)
            .environmentObject(gamificationManager)
            .environmentObject(nutritionManager)
        }
    }
}
