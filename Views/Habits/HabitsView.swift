//
//  HabitsView.swift
//  Fitget
//
//  شاشة العادات اليومية + تتبع الإنجاز
//

import SwiftUI
import Combine

struct Habit: Identifiable {
    let id = UUID()
    let code: String
    let icon: String
    let titleAR: String
    let titleEN: String
    let targetPerWeek: Int
}

final class HabitsManager: ObservableObject {
    static let shared = HabitsManager()
    
    @Published var completedToday: Set<String> = []
    
    private init() { }
    
    func toggleToday(code: String) {
        if completedToday.contains(code) {
            completedToday.remove(code)
        } else {
            completedToday.insert(code)
        }
    }
    
    func isCompletedToday(_ code: String) -> Bool {
        completedToday.contains(code)
    }
}

struct HabitsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var habitsManager = HabitsManager.shared
    
    var isArabic: Bool { languageManager.currentLanguage == "ar" }
    
    // عادات افتراضية (لاحقًا ممكن تيجي من Supabase)
    private let habits: [Habit] = [
        Habit(code: "water",   icon: "drop.fill",        titleAR: "شرب الماء",      titleEN: "Drink water",      targetPerWeek: 7),
        Habit(code: "steps",   icon: "figure.walk",      titleAR: "10,000 خطوة",    titleEN: "10,000 steps",     targetPerWeek: 5),
        Habit(code: "sleep",   icon: "bed.double.fill",  titleAR: "نوم كافٍ",       titleEN: "Sleep enough",     targetPerWeek: 6),
        Habit(code: "stretch", icon: "figure.cooldown",  titleAR: "تمطيط سريع",     titleEN: "Quick stretch",    targetPerWeek: 4),
        Habit(code: "food",    icon: "fork.knife",       titleAR: "وجبة صحية",      titleEN: "Healthy meal",     targetPerWeek: 5)
    ]
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    habitsSection
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(isArabic ? "العادات" : "Habits")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header (محدث مع الهوية)

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primary, themeManager.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.14), radius: 14, x: 0, y: 8)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 60, height: 60)
                        Image(systemName: "checkmark.circle.badge.clock")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isArabic ? "حافظ على استمراريتك" : "Stay consistent")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                        
                        Text(
                            isArabic
                            ? "إكمال العادات اليومية يزيد من نقاط الخبرة ويدعم سلسلة الأيام (Streak)."
                            : "Completing daily habits gives you XP and boosts your streak."
                        )
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    streakChip(
                        title: isArabic ? "السلسلة الحالية" : "Current streak",
                        value: "\(progressManager.currentStreak)"
                    )
                    
                    streakChip(
                        title: isArabic ? "أفضل سلسلة" : "Best streak",
                        value: "\(progressManager.longestStreak)"
                    )
                }
            }
            .padding(16)
        }
    }
    
    private func streakChip(title: String, value: String) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.85))
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                    Text(isArabic ? "يوم" : "days")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Habits List
    
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "عادات اليوم" : "Today’s habits")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(themeManager.textPrimary)
            
            VStack(spacing: 10) {
                ForEach(habits) { habit in
                    HabitRow(
                        habit: habit,
                        isArabic: isArabic,
                        isCompleted: habitsManager.isCompletedToday(habit.code),
                        toggle: {
                            habitsManager.toggleToday(code: habit.code)
                            if habitsManager.isCompletedToday(habit.code) {
                                // مكافأة بسيطة لكل عادة يتم إنهاؤها
                                ProgressManager.shared.addRewardXP(50)
                            }
                        }
                    )
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(themeManager.cardBackground)
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
            )
        }
    }
}

struct HabitRow: View {
    let habit: Habit
    let isArabic: Bool
    let isCompleted: Bool
    let toggle: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button {
            toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: habit.icon)
                    .font(.headline)
                    .foregroundColor(isCompleted ? .white : AppColors.primaryBlue)
                    .padding(10)
                    .background(
                        isCompleted
                        ? AppColors.primaryBlue
                        : AppColors.primaryBlue.opacity(0.12)
                    )
                    .cornerRadius(14)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? habit.titleAR : habit.titleEN)
                        .font(.subheadline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(
                        isArabic
                        ? "الهدف \(habit.targetPerWeek)x في الأسبوع"
                        : "Target \(habit.targetPerWeek)x per week"
                    )
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? AppColors.success : themeManager.textSecondary)
            }
            .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
        )
    }
}

#Preview {
    NavigationStack {
        HabitsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
