//
//  TrainingPlanView.swift
//  Fitget
//
//  Path: Fitget/Views/Training/TrainingPlanView.swift
//
//  Created on 23/11/2025.
//

import SwiftUI

struct TrainingPlanView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var goal = "bulk"
    @State private var level = "beginner"
    @State private var daysPerWeek = 3
    
    @State private var plan: TrainingPlan?
    
    var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    controlsSection
                    
                    if let plan = plan {
                        planList(plan: plan)
                    } else {
                        Text(
                            isArabic
                            ? "اختر هدفك ومستواك ثم اضغط على توليد الخطة."
                            : "Choose your goal and level then tap Generate Plan."
                        )
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                        .frame(
                            maxWidth: .infinity,
                            alignment: isArabic ? .trailing : .leading
                        )
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(isArabic ? "خطة التمرين" : "Training Plan")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header (هوية جديدة)

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primary, themeManager.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 8)
            
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 64, height: 64)
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(isArabic ? "خطة التمرين" : "Training plan")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text(
                        isArabic
                        ? "سننشئ خطة أوتوماتيكية حسب هدفك ومستوى لياقتك."
                        : "We’ll generate an automatic plan based on your goal and level."
                    )
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
    
    // MARK: - Controls
    
    private var controlsSection: some View {
        VStack(spacing: 16) {
            // Goal
            VStack(alignment: .leading, spacing: 8) {
                Text(isArabic ? "الهدف" : "Goal")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        goalChip(title: isArabic ? "تضخيم" : "Bulk", value: "bulk")
                        goalChip(title: isArabic ? "تنشيف" : "Cut", value: "cut")
                        goalChip(title: isArabic ? "قوة" : "Strength", value: "strength")
                        goalChip(title: isArabic ? "صيانة" : "Maintain", value: "maintain")
                    }
                }
            }
            
            // Level
            VStack(alignment: .leading, spacing: 8) {
                Text(isArabic ? "المستوى" : "Level")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)
                
                HStack(spacing: 10) {
                    levelChip(title: isArabic ? "مبتدئ" : "Beginner", value: "beginner")
                    levelChip(title: isArabic ? "متوسط" : "Intermediate", value: "intermediate")
                    levelChip(title: isArabic ? "متقدم" : "Advanced", value: "advanced")
                }
            }
            
            // Days per week
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(isArabic ? "أيام التمرين بالأسبوع" : "Days per week")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.textPrimary)
                    Spacer()
                    Text("\(daysPerWeek)")
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Slider(
                    value: Binding(
                        get: { Double(daysPerWeek) },
                        set: { daysPerWeek = Int($0) }
                    ),
                    in: 2...6,
                    step: 1
                )
            }
            
            PrimaryButton(
                title: isArabic ? "توليد الخطة" : "Generate Plan",
                action: generatePlan
            )
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
    }
    
    private func goalChip(title: String, value: String) -> some View {
        Button {
            goal = value
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        goal == value
                        ? Color(hex: "0091ff")
                        : themeManager.cardBackground
                    )
            )
            .foregroundColor(.white)
        }
    }
    
    private func levelChip(title: String, value: String) -> some View {
        Button {
            level = value
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        level == value
                        ? Color(hex: "4ECDC4")
                        : themeManager.cardBackground
                    )
            )
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Plan List (نفس المنطق، عرض بشكل كروت)

    private func planList(plan: TrainingPlan) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(plan.days) { day in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("\(isArabic ? "اليوم" : "Day") \(day.dayIndex)")
                            .font(.headline)
                            .foregroundColor(themeManager.textPrimary)
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(day.exercises) { ex in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isArabic ? ex.nameAr : ex.nameEn)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white)
                                    Text("\(ex.sets) x \(ex.reps)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.04))
                )
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Actions
    
    private func generatePlan() {
        let manager = TrainingPlanManager.shared
        plan = manager.generatePlan(goal: goal, fitnessLevel: level, daysPerWeek: daysPerWeek)
    }
}

#Preview {
    NavigationStack {
        TrainingPlanView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
