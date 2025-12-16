//
//  PremiumLockOverlay.swift
//  FITGET
//
//  Overlay عام لاستخدامه مع الميزات المقفولة بالبريميوم
//

import SwiftUI

struct PremiumLockOverlay: View {
    let title: String
    let message: String
    let onUpgradeTapped: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        ZStack {
            // طبقة شفافة فوق المحتوى
            Rectangle()
                .fill(Color.black.opacity(0.35))
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [themeManager.primary, themeManager.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    onUpgradeTapped()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                        Text(isArabic ? "الترقية إلى بريميوم" : "Upgrade to Premium")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .foregroundColor(themeManager.primary)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 6)

                Button {
                    // إغلاق بسيط: لا شيء هنا، الـ overlay يتحكم فيه الـ Modifier
                    // نتركه كـ "رجوع" بصري فقط
                } label: {
                    Text(isArabic ? "لاحقاً" : "Maybe later")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.65))
            )
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    PremiumLockOverlay(
        title: "متاح مع بريميوم",
        message: "هذه الميزة متاحة لمشتركي FITGET Premium. احصل على برامج أكثر، تتبع مفصّل، وتجربة كاملة بدون قيود."
    ) { }
    .environmentObject(ThemeManager.shared)
    .environmentObject(LanguageManager.shared)
}
