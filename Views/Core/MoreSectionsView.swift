//
//  MoreSectionsView.swift
//  FITGET
//

import SwiftUI

/// شاشة "المزيد" التي تجمع كل الأقسام الثانوية + إعدادات Health
struct MoreSectionsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    /// نستخدم الـ Singleton بدل إنشاء كائن جديد
    @ObservedObject private var healthKitManager = HealthKitManager.shared

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        List {
            mainSections
            healthSection
            settingsSection
        }
        .listStyle(.insetGrouped)
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle(isArabic ? "المزيد" : "More")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - الأقسام الرئيسية

    private var mainSections: some View {
        Section {
            NavigationLink {
                StepsTrackerView()
            } label: {
                row(icon: "figure.walk", titleAR: "متتبع الخطوات", titleEN: "Steps tracker")
            }

            NavigationLink {
                HabitsTrackerView()
            } label: {
                row(icon: "checklist", titleAR: "متتبع العادات", titleEN: "Habits tracker")
            }

            NavigationLink {
                ChallengesView()
            } label: {
                row(icon: "trophy.fill", titleAR: "التحديات", titleEN: "Challenges")
            }

            NavigationLink {
                NutritionView()
            } label: {
                row(icon: "fork.knife", titleAR: "التغذية", titleEN: "Nutrition")
            }

            NavigationLink {
                ProgramsView()
            } label: {
                row(icon: "list.bullet.rectangle", titleAR: "البرامج", titleEN: "Programs")
            }

            NavigationLink {
                StoreView()   // ✅ بدل CoinsShopView
            } label: {
                row(icon: "cart.fill", titleAR: "المتجر / العملات", titleEN: "Shop & Coins")
            }
        } header: {
            Text(isArabic ? "الأقسام" : "Sections")
        }
    }

    // MARK: - Health / Activity

    private var healthSection: some View {
        Section {
            Button {
                Task {
                    await healthKitManager.requestAuthorization()
                }
            } label: {
                HStack {
                    Image(systemName: "heart.text.square")
                        .foregroundColor(.red)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isArabic ? "مزامنة مع Apple Health" : "Sync with Apple Health")
                            .foregroundColor(themeManager.textPrimary)

                        if !healthKitManager.isHealthAvailable {
                            Text(isArabic ? "غير متوفر على هذا الجهاز" : "Not available on this device")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if healthKitManager.isAuthorized {
                            Text(isArabic ? "مفعل – يتم التحديث تلقائيًا" : "Enabled – updates automatically")
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                        } else {
                            Text(isArabic ? "اضغط لمنح الصلاحيات" : "Tap to grant permissions")
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }
                }
            }
        } header: {
            Text(isArabic ? "الصحة والنشاط" : "Health & Activity")
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        Section {
            NavigationLink {
                SettingsView()
            } label: {
                row(icon: "gearshape.fill", titleAR: "الإعدادات", titleEN: "Settings")
            }

            NavigationLink {
                LanguageSettingsView()
            } label: {
                row(icon: "globe", titleAR: "اللغة", titleEN: "Language")
            }
        } header: {
            Text(isArabic ? "الإعدادات" : "Settings")
        }
    }

    // MARK: - Row helper

    private func row(icon: String, titleAR: String, titleEN: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(themeManager.primary)

            Text(isArabic ? titleAR : titleEN)
                .foregroundColor(themeManager.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        MoreSectionsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
