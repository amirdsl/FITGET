//
//  TipsView.swift
//  FITGET
//
//  Created on 25/11/2025.
//

import SwiftUI
import Combine

struct TipsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var tipsManager: TipsManager
    @EnvironmentObject var notificationsManager: NotificationsManager
    
    @AppStorage("daily_tip_notifications_enabled") private var dailyTipNotificationsEnabled = false
    @State private var selectedCategory: TipCategory? = nil
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    private var filteredTips: [Tip] {
        tipsManager.tips(for: selectedCategory)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    dailyTipCard
                    categoryChips
                    tipsList
                }
                .padding()
            }
            .navigationTitle(isArabic ? "نصائح" : "Tips")
            .onAppear {
                notificationsManager.refreshAuthorizationStatus()
            }
        }
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    // MARK: - بطاقة نصيحة اليوم
    
    private var dailyTipCard: some View {
        let tip = tipsManager.randomTip()
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? "نصيحة اليوم" : "Tip of the Day")
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    if let tip {
                        Text(tip.title(isArabic: isArabic))
                            .font(.subheadline)
                            .foregroundColor(themeManager.textSecondary)
                            .lineLimit(2)
                    } else {
                        Text(isArabic ? "سيتم إضافة نصائح قريبًا." : "Tips will be added soon.")
                            .font(.subheadline)
                            .foregroundColor(themeManager.textSecondary)
                    }
                }
                
                Spacer()
                
                Button {
                    toggleDailyNotification()
                } label: {
                    Image(systemName: dailyTipNotificationsEnabled ? "bell.fill" : "bell.slash")
                        .foregroundColor(dailyTipNotificationsEnabled ? .green : .secondary)
                        .padding(10)
                        .background(themeManager.cardBackground)
                        .clipShape(Circle())
                }
            }
            
            if let tip {
                Text(tip.body(isArabic: isArabic))
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - فلاتر التصنيفات
    
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipView(
                    title: isArabic ? "الكل" : "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(TipCategory.allCases) { category in
                    chipView(
                        title: isArabic ? category.titleAR : category.titleEN,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func chipView(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.primaryBlue : themeManager.cardBackground)
                .foregroundColor(isSelected ? .white : themeManager.textPrimary)
                .cornerRadius(20)
        }
    }
    
    // MARK: - قائمة النصائح
    
    private var tipsList: some View {
        Group {
            if filteredTips.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "lightbulb")
                        .font(.largeTitle)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text(isArabic ? "لا توجد نصائح في هذا القسم" : "No tips in this category yet")
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(isArabic ? "سيتم إضافة المزيد من النصائح قريبًا." : "More tips will be added soon.")
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredTips) { tip in
                        NavigationLink {
                            TipDetailView(tip: tip)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(tip.title(isArabic: isArabic))
                                    .font(.headline)
                                    .foregroundColor(themeManager.textPrimary)
                                
                                Text(tip.body(isArabic: isArabic))
                                    .font(.subheadline)
                                    .foregroundColor(themeManager.textSecondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.plain)
                .background(themeManager.backgroundColor)
            }
        }
    }
    
    // MARK: - الإشعارات
    
    private func toggleDailyNotification() {
        if dailyTipNotificationsEnabled {
            notificationsManager.cancelDailyTipNotification()
            dailyTipNotificationsEnabled = false
        } else {
            notificationsManager.requestAuthorization()
            notificationsManager.scheduleRandomDailyTipNotification(
                hour: 9,
                minute: 0,
                tipsManager: tipsManager
            )
            dailyTipNotificationsEnabled = true
        }
    }
}

#Preview {
    TipsView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(TipsManager.shared)
        .environmentObject(NotificationsManager.shared)
}
