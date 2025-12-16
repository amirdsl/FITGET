//
//  DesignSystem.swift
//  FITGET
//
//  Created on 26/11/2025.
//
import Combine
import SwiftUI

// MARK: - Gradients

enum AppGradients {
    /// البنفسجي الرئيسي (مثالي للهيدر والبطاقات الهيرو)
    static let royalPower = LinearGradient(
        colors: [
            Color(red: 0.27, green: 0.18, blue: 0.63),
            Color(red: 0.40, green: 0.22, blue: 0.85)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// برتقالي حاد – لتحذيرات / السعرات
    static let moltenOrange = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.49, blue: 0.17),
            Color(red: 0.98, green: 0.33, blue: 0.18)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// أزرق كهربائي – معلومات / خطوات
    static let electricBlue = LinearGradient(
        colors: [
            Color(red: 0.12, green: 0.47, blue: 0.98),
            Color(red: 0.20, green: 0.72, blue: 1.00)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// جرين للنجاح / التحديات
    static let greenSuccess = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.40, blue: 0.21),
            Color(red: 0.07, green: 0.70, blue: 0.39)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// بنفسجي Prestige (لإنجازات/XP)
    static let prestigePurple = LinearGradient(
        colors: [
            Color(red: 0.34, green: 0.20, blue: 0.85),
            Color(red: 0.58, green: 0.26, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// أزرق ملكي (للكروت العامة)
    static let royalBlue = LinearGradient(
        colors: [
            Color(red: 0.09, green: 0.30, blue: 0.75),
            Color(red: 0.17, green: 0.50, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Gradient لآيقونات التحديات / التمارين
    static let challengeFlare = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.38, blue: 0.33),
            Color(red: 0.98, green: 0.17, blue: 0.50)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// alias لأسماء استخدمناها سابقاً
    static let workoutAccent = challengeFlare
    static let orangeBurn = moltenOrange
}

// MARK: - Shadows

struct AppShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum AppShadows {
    static let subtleCard = AppShadow(
        color: Color.black.opacity(0.18),
        radius: 10,
        x: 0,
        y: 6
    )

    static let softElevated = AppShadow(
        color: Color.black.opacity(0.25),
        radius: 18,
        x: 0,
        y: 10
    )
}

// MARK: - View modifiers

extension View {
    /// Corner radius موحد للكروت
    func appCardCornerRadius(_ radius: CGFloat = 24) -> some View {
        self.clipShape(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
        )
    }

    /// ظل موحد للكروت
    func appShadow(_ style: AppShadow = AppShadows.subtleCard) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}
