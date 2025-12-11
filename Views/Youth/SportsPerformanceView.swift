//
//  SportsPerformanceView.swift
//  FITGET
//
//  شاشة بسيطة تفتح مركز تطوير أداء الرياضيين الجديد
//

import SwiftUI

struct SportsPerformanceView: View {
    var body: some View {
        SportsPerformanceHubView()
    }
}

#Preview {
    NavigationStack {
        SportsPerformanceView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
