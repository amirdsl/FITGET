//
//  ExercisesLibraryView.swift
//  FITGET
//

import SwiftUI

/// شاشة مكتبة التمارين القديمة – نربطها الآن مباشرة بـ ExercisesView
struct ExercisesLibraryView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ExercisesView()
            .environmentObject(languageManager)
            .environmentObject(themeManager)
    }
}

#Preview {
    ExercisesLibraryView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
}
