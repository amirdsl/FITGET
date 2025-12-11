//
//  ThemeManager.swift
//  FITGET
//
//  هوية الألوان + نمط الداكن/الفاتح للتطبيق
//

import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {

    static let shared = ThemeManager()

    /// يتحكم في وضع داكن / فاتح
    @Published var isDarkMode: Bool = false {
        didSet {
            // لو حاب تحفظه في UserDefaults لاحقًا تضيف الكود هنا
        }
    }

    private init() {}

    // MARK: - Helpers

    private var isDark: Bool { isDarkMode }

    // MARK: - الألوان الأساسية

    /// اللون الأساسي (أزرق بنفسجي حديث)
    var primary: Color {
        Color(red: 0.23, green: 0.35, blue: 0.98) // #3B59FA تقريبًا
    }

    /// لون ثانوي (بنفسجي لطيف)
    var accent: Color {
        Color(red: 0.48, green: 0.30, blue: 0.92) // #7A4DEA تقريبًا
    }

    /// خلفية عامة للتطبيق
    var backgroundColor: Color {
        if isDark {
            return Color(red: 0.04, green: 0.05, blue: 0.10)
        } else {
            return Color(red: 0.96, green: 0.97, blue: 0.99)
        }
    }

    /// خلفية ثانوية للأقسام / القوائم
    var secondaryBackground: Color {
        if isDark {
            return Color(red: 0.09, green: 0.10, blue: 0.18)
        } else {
            return Color(red: 0.93, green: 0.95, blue: 0.98)
        }
    }

    /// خلفية الكروت
    var cardBackground: Color {
        if isDark {
            return Color(red: 0.12, green: 0.13, blue: 0.22)
        } else {
            return Color.white
        }
    }

    /// نص أساسي
    var textPrimary: Color {
        isDark ? Color.white : Color(red: 0.08, green: 0.10, blue: 0.18)
    }

    /// نص ثانوي
    var textSecondary: Color {
        isDark
        ? Color.white.opacity(0.7)
        : Color.black.opacity(0.6)
    }

    /// تدرج عام يمكن استخدامه في الهيدر / الأزرار الكبيرة
    var mainGradient: LinearGradient {
        LinearGradient(
            colors: [primary, accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// ظل ناعم للكروت
    var cardShadow: Color {
        isDark ? Color.black.opacity(0.55) : Color.black.opacity(0.06)
    }

    // MARK: - Corners / Spacing

    let cardCornerRadius: CGFloat = 22
    let smallCornerRadius: CGFloat = 12
    let buttonCornerRadius: CGFloat = 18

    let verticalPadding: CGFloat = 16
    let horizontalPadding: CGFloat = 16
}

// MARK: - Typography

extension Font {
    static var fgTitle: Font {
        .system(size: 24, weight: .bold, design: .rounded)
    }

    static var fgSectionTitle: Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }

    static var fgBody: Font {
        .system(size: 15, weight: .regular, design: .rounded)
    }

    static var fgCaption: Font {
        .system(size: 12, weight: .regular, design: .rounded)
    }
}
