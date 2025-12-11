//
//  HomeView.swift
//  Fitget
//
//  Created on 22/11/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            HomeDashboardView()
                .environmentObject(languageManager)
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
}
