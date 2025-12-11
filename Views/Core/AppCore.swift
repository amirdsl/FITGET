//
//  AppCore.swift
//  Fitget
//
//  Created on 21/11/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Legacy Theme Manager Compatibility

/// لو في أي كود قديم لسه بيستخدم LegacyThemeManager هيشتغل عادي
typealias LegacyThemeManager = ThemeManager

// MARK: - Language Manager

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "app_language")
        }
    }
    
    var isRTL: Bool {
        currentLanguage == "ar"
    }
    
    private init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: "app_language") ?? "en"
    }
    
    func changeLanguage(to language: String) {
        currentLanguage = language
    }
}

// MARK: - App Colors

struct AppColors {
    // MARK: - New Palette (Light / Dark)
    
    // Primary
    static let primaryLight = Color(hex: "1E88E5") // أزرق حيوي
    static let primaryDark  = Color(hex: "2F9BFF") // أزرق أقوى يناسب الخلفية الداكنة
    
    // Secondary
    static let secondaryLight = Color(hex: "FF6F00") // برتقالي
    static let secondaryDark  = Color(hex: "FF8F24")
    
    // Accent (أخضر)
    static let accentLight = Color(hex: "43A047")
    static let accentDark  = Color(hex: "22C55E")
    
    // Backgrounds
    static let backgroundLight          = Color(hex: "F5F7FA")  // أوف وايت
    static let backgroundSecondaryLight = Color(hex: "FFFFFF")
    
    static let backgroundDark           = Color(hex: "0A0E27")  // كحلي داكن
    static let backgroundSecondaryDark  = Color(hex: "151B3D")
    
    // Surfaces / Cards
    static let surfaceLight = Color(hex: "FFFFFF")
    static let surfaceDark  = Color(hex: "151B3D")
    
    static let cardLight = Color(hex: "FFFFFF")
    static let cardDark  = Color(hex: "1E2749")
    
    // Text
    static let textPrimaryLight   = Color(hex: "1A1A2E")
    static let textSecondaryLight = Color(hex: "6B7280")
    
    static let textPrimaryDark    = Color(hex: "FFFFFF")
    static let textSecondaryDark  = Color(hex: "B0B8C8")
    
    // Borders
    static let borderLight = Color.black.opacity(0.06)
    static let borderDark  = Color.white.opacity(0.15)
    
    // MARK: - Semantic / Status
    
    static let successLight = Color(hex: "10B981")
    static let successDark  = Color(hex: "22C55E")
    
    static let warningLight = Color(hex: "F59E0B")
    static let warningDark  = Color(hex: "FBBF24")
    
    static let errorLight   = Color(hex: "EF4444")
    static let errorDark    = Color(hex: "F87171")
    
    static let infoLight    = Color(hex: "3B82F6")
    static let infoDark     = Color(hex: "60A5FA")
    
    // MARK: - Backwards Compatibility (أسماء قديمة مستخدمة في المشروع)
    
    // Primary Colors (قديمة)
    static let primaryBlue   = AppColors.primaryLight
    static let primaryOrange = AppColors.secondaryLight
    static let primaryGreen  = AppColors.accentLight
    static let accentGold    = Color(hex: "FFB300")
    
    // Backgrounds - Dark Mode (قديمة)
    static let darkBackground = AppColors.backgroundDark
    static let darkSecondary  = AppColors.backgroundSecondaryDark
    static let darkCard       = AppColors.cardDark
    
    // Backgrounds - Light Mode (قديمة)
    static let lightBackground = AppColors.backgroundLight
    static let lightSecondary  = AppColors.backgroundSecondaryLight
    static let lightCard       = AppColors.cardLight
    
    // Text Colors - Dark Mode (قديمة)
    static let darkText          = AppColors.textPrimaryDark
    static let darkTextSecondary = AppColors.textSecondaryDark
    
    // Text Colors - Light Mode (قديمة)
    static let lightText          = AppColors.textPrimaryLight
    static let lightTextSecondary = AppColors.textSecondaryLight
    
    // Status Colors (قديمة)
    static let success = AppColors.successLight
    static let error   = AppColors.errorLight
    static let warning = AppColors.warningLight
    static let info    = AppColors.infoLight
    
    // MARK: - Gradients (ثابتة لا تعتمد على الثيم)
    
    static let primaryGradient = LinearGradient(
        colors: [primaryLight, Color(hex: "1565C0")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [secondaryLight, Color(hex: "E65100")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [accentLight, Color(hex: "1B5E20")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [accentGold, Color(hex: "F57F17")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Muscle Group Colors
    
    static let chestColor     = Color(hex: "E53935")
    static let backColor      = Color(hex: "43A047")
    static let legsColor      = Color(hex: "FB8C00")
    static let shouldersColor = Color(hex: "1E88E5")
    static let armsColor      = Color(hex: "8E24AA")
    static let coreColor      = Color(hex: "00ACC1")
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6: // RGB (24-bit)
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
