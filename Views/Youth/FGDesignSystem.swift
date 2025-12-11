//
//  FGDesignSystem.swift
//  FITGET
//
//  مكوّنات UI مشتركة لهوية FITGET
//

import SwiftUI

// MARK: - زر أساسي

struct FGPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isFullWidth: Bool = true
    var action: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = systemImage, !isArabic {
                    Image(systemName: icon)
                }

                Text(title)
                    .font(.subheadline.bold())

                if let icon = systemImage, isArabic {
                    Image(systemName: icon)
                }
            }
            .padding(.vertical, 11)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .foregroundColor(.white)
            .background(
                themeManager.mainGradient
                    .cornerRadius(themeManager.buttonCornerRadius)
            )
            .shadow(color: themeManager.cardShadow, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - كارت عام

struct FGCard<Content: View>: View {
    @EnvironmentObject var themeManager: ThemeManager

    let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: themeManager.cardCornerRadius)
                    .fill(themeManager.cardBackground)
                    .shadow(color: themeManager.cardShadow,
                            radius: 10, x: 0, y: 6)
            )
    }
}

// MARK: - ترويسة قسم

struct FGSectionHeader: View {
    let titleAR: String
    let titleEN: String
    var systemImage: String? = nil

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        HStack(spacing: 8) {
            if let icon = systemImage {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primary)
            }

            Text(isArabic ? titleAR : titleEN)
                .font(.fgSectionTitle)
                .foregroundColor(themeManager.textPrimary)

            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, 2)
    }
}

// MARK: - Tag / شارة صغيرة

struct FGTag: View {
    let text: String
    var systemImage: String? = nil
    var style: Style = .neutral

    enum Style {
        case success
        case warning
        case neutral
    }

    @EnvironmentObject var themeManager: ThemeManager

    private var colors: (bg: Color, fg: Color) {
        switch style {
        case .success:
            return (.green.opacity(0.14), .green)
        case .warning:
            return (.orange.opacity(0.14), .orange)
        case .neutral:
            return (themeManager.secondaryBackground.opacity(0.9),
                    themeManager.textSecondary)
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon = systemImage {
                Image(systemName: icon)
            }
            Text(text)
        }
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colors.bg)
        .foregroundColor(colors.fg)
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            FGSectionHeader(titleAR: "عنوان قسم", titleEN: "Section title", systemImage: "bolt.fill")

            FGCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("FGCard Example")
                        .font(.fgBody)
                    Text("نص توضيحي بسيط يظهر داخل الكارت.")
                        .font(.fgCaption)
                        .foregroundColor(ThemeManager.shared.textSecondary)
                }
            }

            FGPrimaryButton(title: "زر أساسي", systemImage: "arrow.right") {}

            HStack {
                FGTag(text: "مجاني", systemImage: "checkmark.seal.fill", style: .success)
                FGTag(text: "بريميوم", systemImage: "crown.fill", style: .warning)
                FGTag(text: "معلومة", systemImage: "info.circle")
            }
        }
        .padding()
        .environmentObject(ThemeManager.shared)
        .environmentObject(LanguageManager.shared)
    }
}
