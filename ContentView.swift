//
//  ContentView.swift
//  Fitget
//
//  Path: Fitget/Views/Core/ContentView.swift
//

import SwiftUI

struct ContentView: View {
    // نترك الـ EnvironmentObjects لو احتجناها لاحقاً
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var onboardingManager: OnboardingManager
    
    var body: some View {
        // دخول مباشر للتابات الرئيسية مؤقتاً للتجربة
        MainTabEntryView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(OnboardingManager.shared)
}
