//
//  OnboardingFlowView.swift
//  FITGET
//
//

import SwiftUI

struct OnboardingFlowView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var onboardingManager: OnboardingManager
    
    // MARK: - State
    @State private var step: Int = 0
    
    // MARK: - Constants
    private let totalSteps: Int = 4
    
    // MARK: - Computed Helpers
    
    /// هل اللغة الحالية عربية؟
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    /// اتجاه الواجهة حسب اللغة
    private var layoutDirection: LayoutDirection {
        languageManager.isRTL ? .rightToLeft : .leftToRight
    }
    
    /// هل نحن في آخر خطوة؟
    private var isLastStep: Bool {
        step == totalSteps - 1
    }
    
    /// عنوان الخطوة الحالية
    private var stepTitle: String {
        switch step {
        case 0:
            return isArabic ? "ابدأ" : "Get Started"
        case 1:
            return isArabic ? "هدفك" : "Your Goal"
        case 2:
            return isArabic ? "مستواك" : "Your Level"
        case 3:
            return isArabic ? "ملخص" : "Summary"
        default:
            return "FITGET"
        }
    }
    
    /// يمكن المتابعة للخطوة التالية؟
    private var canContinue: Bool {
        switch step {
        case 1:
            return onboardingManager.preferences.goal != nil
        case 2:
            return onboardingManager.preferences.level != nil
        default:
            return true
        }
    }
    
    /// نص زر المتابعة الرئيسي
    private var primaryButtonTitle: String {
        if isLastStep {
            return isArabic ? "ابدأ رحلتك" : "Start Your Journey"
        } else {
            return isArabic ? "التالي" : "Next"
        }
    }
    
    /// نص زر التخطي
    private var skipButtonTitle: String {
        isArabic ? "تخطي الآن" : "Skip for now"
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                header
                
                TabView(selection: $step) {
                    introStep
                        .tag(0)
                    goalStep
                        .tag(1)
                    levelStep
                        .tag(2)
                    summaryStep
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)
                
                stepIndicators
                
                primaryActionButton
                
                skipButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .environment(\.layoutDirection, layoutDirection)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            // زر الرجوع
            if step > 0 {
                Button(action: handleBack) {
                    Image(systemName: layoutDirection == .rightToLeft ? "chevron.forward" : "chevron.backward")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.textPrimary)
                        .padding(8)
                        .background(themeManager.cardBackground.opacity(0.6))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            } else {
                // مساحة لتعويض زر الرجوع في أول خطوة
                Circle()
                    .fill(Color.clear)
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(stepTitle)
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("\(step + 1) / \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            // زر تخطي في الأعلى (اختياري)
            if step < totalSteps - 1 {
                Button(action: completeOnboarding) {
                    Text(isArabic ? "تخطي" : "Skip")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                .buttonStyle(.plain)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 32, height: 32)
            }
        }
    }
    
    // MARK: - Step Indicators
    
    private var stepIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index == step ? AppColors.primaryBlue : themeManager.cardBackground)
                    .frame(width: index == step ? 28 : 10, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: step)
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Primary Action Button
    
    private var primaryActionButton: some View {
        Button(action: handlePrimaryAction) {
            HStack {
                Spacer()
                Text(primaryButtonTitle)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                
                Image(systemName: layoutDirection == .rightToLeft ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(canContinue ? AppColors.primaryBlue : themeManager.cardBackground)
            .foregroundColor(.white)
            .cornerRadius(22)
            .shadow(radius: 8, y: 4)
        }
        .disabled(!canContinue)
        .padding(.top, 4)
    }
    
    // MARK: - Skip Button (bottom)
    
    private var skipButton: some View {
        Button(action: completeOnboarding) {
            Text(skipButtonTitle)
                .font(.footnote)
                .underline()
                .foregroundColor(themeManager.textSecondary)
        }
        .padding(.top, 2)
    }
    
    // MARK: - Intro Step
    
    private var introStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            
            Text(isArabic ? "مرحبًا في FITGET" : "Welcome to FITGET")
                .font(.largeTitle.bold())
                .foregroundColor(themeManager.textPrimary)
                .multilineTextAlignment(.leading)
            
            Text(isArabic
                 ? "أنشئ أفاتار يشبهك، تتبع تدريباتك، تغذيتك، وتقدمك خطوة بخطوة في مكان واحد."
                 : "Create an avatar that looks like you, track your workouts, nutrition, and progress—all in one place.")
                .font(.body)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.leading)
            
            VStack(alignment: .leading, spacing: 12) {
                introBullet(
                    icon: "figure.strengthtraining.traditional",
                    titleAR: "برامج تدريب مخصصة",
                    titleEN: "Personalized workouts"
                )
                introBullet(
                    icon: "chart.line.uptrend.xyaxis",
                    titleAR: "متابعة تقدمك",
                    titleEN: "Track your progress"
                )
                introBullet(
                    icon: "fork.knife",
                    titleAR: "تغذية ذكية",
                    titleEN: "Smart nutrition"
                )
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding()
    }
    
    private func introBullet(icon: String, titleAR: String, titleEN: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.cardBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.primaryBlue)
            }
            
            Text(isArabic ? titleAR : titleEN)
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary)
        }
    }
    
    // MARK: - Goal Step
    
    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isArabic ? "ما هو هدفك الرئيسي؟" : "What is your main goal?")
                .font(.title2.bold())
                .foregroundColor(themeManager.textPrimary)
            
            Text(isArabic
                 ? "يساعدنا هذا على تخصيص تجربة التدريب والتغذية المناسبة لك."
                 : "This helps us tailor your training and nutrition experience.")
                .font(.body)
                .foregroundColor(themeManager.textSecondary)
                .padding(.bottom, 8)
            
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(OnboardingGoal.allCases) { goal in
                        goalCard(goal)
                    }
                }
            }
        }
        .padding()
    }
    
    private func goalCard(_ goal: OnboardingGoal) -> some View {
        let isSelected = onboardingManager.preferences.goal == goal
        
        return Button {
            // ✅ استخدام دالة المدير عشان نحفظ في UserDefaults
            onboardingManager.setGoal(goal)
        } label: {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primaryBlue.opacity(0.2) : themeManager.cardBackground)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: goalIcon(for: goal))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? AppColors.primaryBlue : themeManager.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? goal.titleAR : goal.titleEN)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(isArabic ? goal.descriptionAR : goal.descriptionEN)
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primaryBlue : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func goalIcon(for goal: OnboardingGoal) -> String {
        switch goal {
        case .loseFat:
            return "flame.fill"
        case .buildMuscle:
            return "dumbbell.fill"
        case .improveFitness:
            return "heart.fill"
        }
    }
    
    // MARK: - Level Step
    
    private var levelStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isArabic ? "ما هو مستواك الحالي؟" : "What is your current level?")
                .font(.title2.bold())
                .foregroundColor(themeManager.textPrimary)
            
            Text(isArabic
                 ? "اختر المستوى الذي يصف خبرتك التدريبية بشكل أفضل."
                 : "Choose the option that best describes your training experience.")
                .font(.body)
                .foregroundColor(themeManager.textSecondary)
                .padding(.bottom, 8)
            
            VStack(spacing: 14) {
                ForEach(FitnessLevel.allCases) { level in
                    levelCard(level)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func levelCard(_ level: FitnessLevel) -> some View {
        let isSelected = onboardingManager.preferences.level == level
        
        return Button {
            // ✅ استخدام دالة المدير للحفظ
            onboardingManager.setLevel(level)
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? level.titleAR : level.titleEN)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(isArabic ? level.descriptionAR : level.descriptionEN)
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? AppColors.primaryBlue : themeManager.textSecondary.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(AppColors.primaryBlue)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Summary Step
    
    private var summaryStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isArabic ? "جاهز للانطلاق!" : "Ready to go!")
                .font(.title2.bold())
                .foregroundColor(themeManager.textPrimary)
            
            Text(isArabic
                 ? "راجع ملخص إعداداتك قبل أن نبدأ رحلتك مع FITGET."
                 : "Review your setup summary before we start your FITGET journey.")
                .font(.body)
                .foregroundColor(themeManager.textSecondary)
                .padding(.bottom, 12)
            
            VStack(spacing: 12) {
                summaryRow(
                    titleAR: "الهدف",
                    titleEN: "Goal",
                    value: goalSummaryText
                )
                
                summaryRow(
                    titleAR: "المستوى",
                    titleEN: "Level",
                    value: levelSummaryText
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(themeManager.cardBackground)
            )
            
            Text(isArabic
                 ? "يمكنك دائمًا تعديل هذه الإعدادات لاحقًا من صفحة الإعدادات."
                 : "You can always change these later from Settings.")
                .font(.footnote)
                .foregroundColor(themeManager.textSecondary)
                .padding(.top, 4)
            
            Spacer()
        }
        .padding()
    }
    
    private var goalSummaryText: String {
        if let goal = onboardingManager.preferences.goal {
            return isArabic ? goal.titleAR : goal.titleEN
        } else {
            return isArabic ? "لم يتم التحديد" : "Not selected"
        }
    }
    
    private var levelSummaryText: String {
        if let level = onboardingManager.preferences.level {
            return isArabic ? level.titleAR : level.titleEN
        } else {
            return isArabic ? "لم يتم التحديد" : "Not selected"
        }
    }
    
    private func summaryRow(titleAR: String, titleEN: String, value: String) -> some View {
        HStack {
            Text(isArabic ? titleAR : titleEN)
                .font(.subheadline.weight(.medium))
                .foregroundColor(themeManager.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary)
        }
    }
    
    // MARK: - Actions
    
    private func handleBack() {
        guard step > 0 else { return }
        withAnimation(.easeInOut) {
            step -= 1
        }
    }
    
    private func handlePrimaryAction() {
        guard canContinue else { return }
        
        if isLastStep {
            completeOnboarding()
        } else {
            withAnimation(.easeInOut) {
                step += 1
            }
        }
    }
    
    private func completeOnboarding() {
        onboardingManager.completeOnboarding()
    }
}

// MARK: - Preview

#Preview {
    OnboardingFlowView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(OnboardingManager.shared)
}
