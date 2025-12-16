//
//  FITGETApp.swift
//  FITGET
//

import SwiftUI

@main
struct FITGETApp: App {

    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var cartManager = CartManager.shared
    @StateObject private var tipsManager = TipsManager.shared
    @StateObject private var notificationsManager = NotificationsManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var gamificationManager = GamificationManager.shared
    @StateObject private var nutritionManager = NutritionManager.shared

    // ✅ لا shared
    @StateObject private var playerProgress = PlayerProgress()

    var body: some Scene {
        WindowGroup {
            RootDirectionView {
                RootWithSplashView {
                    AppRootView()
                }
            }
            .environmentObject(languageManager)
            .environmentObject(themeManager)
            .environmentObject(authManager)
            .environmentObject(cartManager)
            .environmentObject(tipsManager)
            .environmentObject(notificationsManager)
            .environmentObject(onboardingManager)
            .environmentObject(gamificationManager)
            .environmentObject(nutritionManager)
            .environmentObject(playerProgress) // ✅
        }
    }
}
