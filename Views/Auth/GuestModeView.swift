//
//  GuestModeView.swift
//  FITGET
//
//  شاشة بسيطة لشرح وضع الضيف + تبديل الثيم
//

import SwiftUI

struct GuestModeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    /// استدعاءات يربطها الـ Parent لو احتاج (اختيارية)
    var onLogin: (() -> Void)?
    var onSignup: (() -> Void)?
    var onContinueAsGuest: (() -> Void)?

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {

                // MARK: - Header

                VStack(spacing: 10) {
                    Text(isArabic ? "جرّب FITGET كضيف" : "Try FITGET as a guest")
                        .font(.fgTitle)
                        .foregroundColor(themeManager.textPrimary)

                    Text(
                        isArabic
                        ? "تقدر تستكشف التمارين والبرامج وبعض الميزات بدون إنشاء حساب. لاحقًا تقدر تربط تقدمك بحسابك."
                        : "Explore workouts, programs and some tools without creating an account. You can link your progress later."
                    )
                    .font(.fgBody)
                    .foregroundColor(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)

                // MARK: - Illustration card

                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(themeManager.cardBackground)
                        .shadow(color: themeManager.cardShadow, radius: 10, x: 0, y: 6)

                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.mainGradient)
                                .frame(width: 90, height: 90)

                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(isArabic ? "وضع ضيف ذكي" : "Smart guest mode")
                                .font(.fgSectionTitle)
                                .foregroundColor(themeManager.textPrimary)

                            Text(
                                isArabic
                                ? "سنحفظ تقدمك بشكل محلي، ولو سجّلت لاحقًا نربطه بحسابك تلقائيًا."
                                : "We keep your progress locally, and link it to your account later if you sign up."
                            )
                            .font(.fgCaption)
                            .foregroundColor(themeManager.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(16)
                }
                .padding(.horizontal, 16)

                // MARK: - Actions

                VStack(spacing: 12) {

                    Button {
                        onContinueAsGuest?()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isArabic ? "الاستمرار كضيف" : "Continue as guest")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(themeManager.mainGradient)
                        .foregroundColor(.white)
                        .cornerRadius(themeManager.buttonCornerRadius)
                    }

                    HStack(spacing: 12) {
                        Button {
                            onLogin?()
                        } label: {
                            HStack {
                                Spacer()
                                Text(isArabic ? "تسجيل الدخول" : "Log in")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .background(themeManager.cardBackground)
                            .foregroundColor(themeManager.textPrimary)
                            .cornerRadius(themeManager.buttonCornerRadius)
                        }

                        Button {
                            onSignup?()
                        } label: {
                            HStack {
                                Spacer()
                                Text(isArabic ? "إنشاء حساب" : "Create account")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .background(themeManager.cardBackground)
                            .foregroundColor(themeManager.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: themeManager.buttonCornerRadius)
                                    .stroke(themeManager.primary.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)

                // MARK: - Theme toggle

                HStack {
                    Label {
                        Text(
                            isArabic
                            ? (themeManager.isDarkMode ? "الوضع الداكن مفعل" : "الوضع الفاتح مفعل")
                            : (themeManager.isDarkMode ? "Dark mode enabled" : "Light mode enabled")
                        )
                        .font(.fgCaption)
                    } icon: {
                        Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .foregroundColor(themeManager.textSecondary)

                    Spacer()

                    Toggle("", isOn: $themeManager.isDarkMode)
                        .labelsHidden()
                        .tint(themeManager.primary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()
            }
        }
    }
}

#Preview {
    GuestModeView(
        onLogin: {},
        onSignup: {},
        onContinueAsGuest: {}
    )
    .environmentObject(LanguageManager.shared)
    .environmentObject(ThemeManager.shared)
    .environmentObject(FGSubscriptionStore())
    .environmentObject(PlayerProgress())
}
