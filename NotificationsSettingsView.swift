//
//  NotificationsSettingsView.swift
//  Fitget
//
//  Created on 21/11/2025.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @AppStorage("notif_workouts") private var workoutsNotif = true
    @AppStorage("notif_meals") private var mealsNotif = true
    @AppStorage("notif_water") private var waterNotif = true
    @AppStorage("notif_challenges") private var challengesNotif = true
    @AppStorage("notif_achievements") private var achievementsNotif = true
    @AppStorage("notif_social") private var socialNotif = false
    @AppStorage("notif_marketing") private var marketingNotif = false
    
    var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            List {
                Section(header: Text(isArabic ? "التذكيرات" : "Reminders")) {
                    NotificationToggle(
                        icon: "dumbbell.fill",
                        title: isArabic ? "تذكير التمارين" : "Workout Reminders",
                        description: isArabic ? "تذكيرك بوقت التمرين" : "Remind you of workout time",
                        isOn: $workoutsNotif,
                        color: AppColors.primaryBlue
                    )
                    
                    NotificationToggle(
                        icon: "fork.knife",
                        title: isArabic ? "تذكير الوجبات" : "Meal Reminders",
                        description: isArabic ? "تذكيرك بأوقات الوجبات" : "Remind you of meal times",
                        isOn: $mealsNotif,
                        color: AppColors.primaryGreen
                    )
                    
                    NotificationToggle(
                        icon: "drop.fill",
                        title: isArabic ? "تذكير شرب الماء" : "Water Reminders",
                        description: isArabic ? "تذكيرك بشرب الماء" : "Remind you to drink water",
                        isOn: $waterNotif,
                        color: AppColors.info
                    )
                }
                
                Section(header: Text(isArabic ? "الأنشطة" : "Activities")) {
                    NotificationToggle(
                        icon: "trophy.fill",
                        title: isArabic ? "التحديات" : "Challenges",
                        description: isArabic ? "تحديات جديدة ونتائج" : "New challenges and results",
                        isOn: $challengesNotif,
                        color: AppColors.accentGold
                    )
                    
                    NotificationToggle(
                        icon: "star.fill",
                        title: isArabic ? "الإنجازات" : "Achievements",
                        description: isArabic ? "إنجازات جديدة وشارات" : "New achievements and badges",
                        isOn: $achievementsNotif,
                        color: AppColors.primaryOrange
                    )
                }
                
                Section(header: Text(isArabic ? "اجتماعي" : "Social")) {
                    NotificationToggle(
                        icon: "person.3.fill",
                        title: isArabic ? "النشاط الاجتماعي" : "Social Activity",
                        description: isArabic ? "تعليقات وإعجابات الأصدقاء" : "Friend comments and likes",
                        isOn: $socialNotif,
                        color: .purple
                    )
                }
                
                Section(header: Text(isArabic ? "أخرى" : "Other")) {
                    NotificationToggle(
                        icon: "megaphone.fill",
                        title: isArabic ? "العروض والأخبار" : "Offers & News",
                        description: isArabic ? "عروض خاصة وأخبار التطبيق" : "Special offers and app news",
                        isOn: $marketingNotif,
                        color: .pink
                    )
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(isArabic ? "الإشعارات" : "Notifications")
    }
}

struct NotificationToggle: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    let color: Color
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotificationsSettingsView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
}
