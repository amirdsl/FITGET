//
//  StatCardView.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import SwiftUI

struct StatCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    let icon: String
    let titleAR: String
    let titleEN: String
    let valueText: String
    let subtitleAR: String?
    let subtitleEN: String?
    
    enum Style {
        case primary
        case success
        case warning
        case info
        
        var gradient: LinearGradient {
            switch self {
            case .primary:
                return AppGradients.royalPower
            case .success:
                return LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.35, blue: 0.23),
                        Color(red: 0.05, green: 0.55, blue: 0.36),
                        Color(red: 0.20, green: 0.78, blue: 0.47)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .warning:
                return AppGradients.moltenOrange
            case .info:
                return AppGradients.electricBlue
            }
        }
    }
    
    let style: Style
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ZStack {
            style.gradient
                .appCardCornerRadius()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
                
                Text(valueText)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Text(isArabic ? titleAR : titleEN)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                if let subtitleAR, let subtitleEN {
                    Text(isArabic ? subtitleAR : subtitleEN)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .appShadow(AppShadows.subtleCard)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        StatCardView(
            icon: "flame.fill",
            titleAR: "سعرات اليوم",
            titleEN: "Calories today",
            valueText: "530",
            subtitleAR: "من 2000 سعرة مستهدفة",
            subtitleEN: "of 2000 kcal goal",
            style: .primary
        )
        .environmentObject(ThemeManager.shared)
        .environmentObject(LanguageManager.shared)
        .padding()
    }
}
