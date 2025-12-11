//
//  NutritionView.swift
//  FITGET
//

import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var nutritionManager: NutritionManager
    @EnvironmentObject var onboardingManager: OnboardingManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    // MARK: - Calculator State
    
    @State private var gender: Gender = .male
    @State private var age: Int = 25
    @State private var height: Int = 175 // cm
    @State private var weight: Int = 70  // kg
    @State private var activity: ActivityLevel = .moderate
    @State private var goalAdjustment: GoalAdjustment = .maintain
    
    private var suggestedCalories: Int {
        let w = Double(weight)
        let h = Double(height)
        let a = Double(age)
        
        let base: Double
        switch gender {
        case .male:
            base = 10 * w + 6.25 * h - 5 * a + 5
        case .female:
            base = 10 * w + 6.25 * h - 5 * a - 161
        }
        
        let tdee = base * activity.multiplier
        let adjusted = tdee * goalAdjustment.multiplier
        return Int(adjusted.rounded())
    }
    
    // MARK: - Meal / Programs data
    
    private var suggestedPlan: MealPlan {
        let goal = onboardingManager.preferences.goal ?? .improveFitness
        let target = nutritionManager.targetCalories > 0 ? nutritionManager.targetCalories : suggestedCalories
        return MealPlan.planFor(goal: goal, calories: target)
    }
    
    private let healthyMeals: [MealItem] = MealItem.sampleMeals
    private let myPrograms: [NutritionProgramSample] = NutritionProgramSample.samplePrograms
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        summarySection
                        calorieCalculatorSection
                        suggestedPlanSection
                        myProgramsSection
                        healthyMealsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(isArabic ? "التغذية" : "Nutrition")
            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
            .onAppear {
                if let user = authManager.currentUser {
                    if let a = user.age { age = a }
                    if let h = user.height { height = Int(h) }
                    if let w = user.weight { weight = Int(w) }
                    if let g = user.gender {
                        gender = g == "female" ? .female : .male
                    }
                }
            }
        }
    }
    
    // MARK: - Summary
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "ملخص اليوم" : "Today’s summary")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(isArabic ? "السعرات المتناولة" : "Calories consumed")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    
                    let target = nutritionManager.targetCalories
                    Text(
                        target > 0
                        ? "\(nutritionManager.todayCalories) / \(target)"
                        : "\(nutritionManager.todayCalories)"
                    )
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textPrimary)
                    
                    if target > 0 {
                        let remaining = max(target - nutritionManager.todayCalories, 0)
                        Text(
                            isArabic
                            ? "متبقي \(remaining) سعرة لليوم"
                            : "\(remaining) kcal remaining today"
                        )
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                    } else {
                        Text(
                            isArabic
                            ? "حدد هدف السعرات من الحاسبة بالأسفل."
                            : "Set your calorie target using the calculator below."
                        )
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // حلقة الماكروز الحالية
                let macros = MacroBreakdown(
                    protein: nutritionManager.todayProtein,
                    carbs: nutritionManager.todayCarbs,
                    fats: nutritionManager.todayFats,
                    calories: nutritionManager.todayCalories
                )
                
                MacroRingCard(macros: macros, isArabic: isArabic)
                    .frame(width: 110, height: 110)
            }
            .padding(12)
            .background(themeManager.cardBackground)
            .cornerRadius(18)
        }
    }
    
    // MARK: - Calorie Calculator
    
    private var calorieCalculatorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "حاسبة السعرات" : "Calorie calculator")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            Text(
                isArabic
                ? "أدخل بياناتك الأساسية لنحسب لك احتياجك اليومي من السعرات حسب هدفك."
                : "Enter your basic data to estimate your daily calorie needs based on your goal."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    pickerField(
                        titleAR: "الجنس",
                        titleEN: "Gender"
                    ) {
                        Picker("", selection: $gender) {
                            Text(isArabic ? "ذكر" : "Male")
                                .tag(Gender.male)
                            Text(isArabic ? "أنثى" : "Female")
                                .tag(Gender.female)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    stepperField(
                        titleAR: "العمر",
                        titleEN: "Age",
                        value: $age,
                        range: 14...80,
                        unit: isArabic ? "سنة" : "y"
                    )
                }
                
                HStack(spacing: 12) {
                    stepperField(
                        titleAR: "الطول",
                        titleEN: "Height",
                        value: $height,
                        range: 130...220,
                        unit: "cm"
                    )
                    
                    stepperField(
                        titleAR: "الوزن",
                        titleEN: "Weight",
                        value: $weight,
                        range: 40...160,
                        unit: "kg"
                    )
                }
                
                pickerField(
                    titleAR: "النشاط",
                    titleEN: "Activity"
                ) {
                    Picker("", selection: $activity) {
                        ForEach(ActivityLevel.allCases) { level in
                            Text(isArabic ? level.titleAR : level.titleEN)
                                .tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                pickerField(
                    titleAR: "الهدف",
                    titleEN: "Goal"
                ) {
                    Picker("", selection: $goalAdjustment) {
                        ForEach(GoalAdjustment.allCases) { item in
                            Text(isArabic ? item.titleAR : item.titleEN)
                                .tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(isArabic ? "الاحتياج المقدر" : "Estimated need")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text("\(suggestedCalories) kcal")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(
                        isArabic
                        ? "يمكنك استخدام هذا الرقم كهدف أساسي، ثم تعديل البرنامج الغذائي بناءً عليه."
                        : "You can use this as your base target and adjust your meal plan accordingly."
                    )
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    nutritionManager.setTargetCalories(suggestedCalories)
                    authManager.updateUserInfo(
                        age: age,
                        height: Double(height),
                        weight: Double(weight),
                        gender: gender == .female ? "female" : "male"
                    )
                } label: {
                    HStack {
                        Spacer()
                        Text(isArabic ? "تعيين كهدف يومي" : "Set as daily target")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(themeManager.primary)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
            }
            .padding(12)
            .background(themeManager.cardBackground)
            .cornerRadius(18)
        }
    }
    
    // MARK: - Suggested Plan
    
    private var suggestedPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "برنامج غذائي مقترح" : "Suggested meal plan")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            Text(suggestedPlan.description(isArabic: isArabic))
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            
            VStack(spacing: 10) {
                ForEach(suggestedPlan.meals) { meal in
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isArabic ? meal.titleAR : meal.titleEN)
                                .font(.subheadline.bold())
                                .foregroundColor(themeManager.textPrimary)
                            
                            Text(isArabic ? meal.descriptionAR : meal.descriptionEN)
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(meal.calories) kcal")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.textPrimary)
                            
                            Text("P\(meal.protein)/C\(meal.carbs)/F\(meal.fats)")
                                .font(.caption2)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }
                    .padding(10)
                    .background(themeManager.cardBackground)
                    .cornerRadius(14)
                }
            }
            
            NavigationLink {
                MealPlanView(plan: suggestedPlan)
            } label: {
                HStack {
                    Spacer()
                    Text(isArabic ? "عرض الخطة بالتفصيل" : "View full meal plan")
                        .font(.subheadline.bold())
                    Spacer()
                }
                .padding(.vertical, 9)
                .background(themeManager.primary.opacity(0.12))
                .foregroundColor(themeManager.primary)
                .cornerRadius(18)
            }
        }
    }
    
    // MARK: - My purchased / saved nutrition programs
    
    private var myProgramsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "خطط غذائية جاهزة" : "Saved nutrition plans")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            Text(
                isArabic
                ? "بعد شراء أو حفظ أي خطة غذائية من المدربين سيتم عرضها هنا لتتمكن من مراجعتها وإضافة وجباتها إلى يومك."
                : "Any nutrition plans you buy or save from coaches will appear here so you can review them and add their meals to your day."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
            
            ForEach(myPrograms) { program in
                NavigationLink {
                    MealPlanView(plan: program.plan)
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.primary.opacity(0.13))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(themeManager.primary)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isArabic ? program.titleAR : program.titleEN)
                                .font(.subheadline.bold())
                                .foregroundColor(themeManager.textPrimary)
                            
                            Text(isArabic ? program.subtitleAR : program.subtitleEN)
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Text("\(program.caloriesPerDay) kcal")
                            .font(.caption2.bold())
                            .foregroundColor(themeManager.textSecondary)
                    }
                    .padding(10)
                    .background(themeManager.cardBackground)
                    .cornerRadius(16)
                }
            }
        }
    }
    
    // MARK: - Healthy meals
    
    private var healthyMealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "وجبات صحية جاهزة" : "Healthy ready meals")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            Text(
                isArabic
                ? "اختر وجبة وسجّلها في يومك. لاحقًا يمكن ربط هذه القائمة بوجبات حقيقية من الـ backend."
                : "Pick a meal and log it in your day. Later, this can be backed by real meals from the backend."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
            
            ForEach(healthyMeals) { meal in
                Button {
                    nutritionManager.logMeal(
                        calories: meal.calories,
                        protein: meal.protein,
                        carbs: meal.carbs,
                        fats: meal.fats
                    )
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isArabic ? meal.titleAR : meal.titleEN)
                                .font(.subheadline.bold())
                                .foregroundColor(themeManager.textPrimary)
                            
                            Text(isArabic ? meal.descriptionAR : meal.descriptionEN)
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(meal.calories) kcal")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.textPrimary)
                            
                            Text("P\(meal.protein)/C\(meal.carbs)/F\(meal.fats)")
                                .font(.caption2)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    }
                    .padding(10)
                    .background(themeManager.cardBackground)
                    .cornerRadius(14)
                }
            }
        }
    }
    
    // MARK: - Helper fields
    
    private func pickerField<Content: View>(
        titleAR: String,
        titleEN: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isArabic ? titleAR : titleEN)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            
            content()
        }
    }
    
    private func stepperField(
        titleAR: String,
        titleEN: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isArabic ? titleAR : titleEN)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            
            Stepper(value: value, in: range) {
                Text("\(value.wrappedValue) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(themeManager.textPrimary)
            }
        }
    }
}

// MARK: - Models

enum Gender: String, CaseIterable, Identifiable {
    case male
    case female
    
    var id: String { rawValue }
}

enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary
    case light
    case moderate
    case active
    case veryActive
    
    var id: String { rawValue }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
    
    var titleAR: String {
        switch self {
        case .sedentary: return "خامل"
        case .light: return "نشاط خفيف"
        case .moderate: return "نشاط متوسط"
        case .active: return "نشاط عالي"
        case .veryActive: return "نشاط عالي جدًا"
        }
    }
    
    var titleEN: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        case .veryActive: return "Very active"
        }
    }
}

enum GoalAdjustment: String, CaseIterable, Identifiable {
    case loseFast
    case loseSlow
    case maintain
    case gainSlow
    case gainFast
    
    var id: String { rawValue }
    
    var multiplier: Double {
        switch self {
        case .loseFast: return 0.75
        case .loseSlow: return 0.85
        case .maintain: return 1.0
        case .gainSlow: return 1.10
        case .gainFast: return 1.20
        }
    }
    
    var titleAR: String {
        switch self {
        case .loseFast: return "نزول سريع"
        case .loseSlow: return "نزول تدريجي"
        case .maintain: return "ثبات"
        case .gainSlow: return "زيادة تدريجية"
        case .gainFast: return "زيادة أسرع"
        }
    }
    
    var titleEN: String {
        switch self {
        case .loseFast: return "Lose fast"
        case .loseSlow: return "Lose slowly"
        case .maintain: return "Maintain"
        case .gainSlow: return "Gain slowly"
        case .gainFast: return "Gain faster"
        }
    }
}

struct MealItem: Identifiable {
    let id = UUID()
    let titleAR: String
    let titleEN: String
    let descriptionAR: String
    let descriptionEN: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
}

extension MealItem {
    static let sampleMeals: [MealItem] = [
        MealItem(
            titleAR: "شوفان بالحليب والبروتين",
            titleEN: "Oats with milk & protein",
            descriptionAR: "شوفان، حليب قليل الدسم، سكوب بروتين، وموز.",
            descriptionEN: "Oats, low-fat milk, whey scoop, and banana.",
            calories: 450,
            protein: 35,
            carbs: 55,
            fats: 9
        ),
        MealItem(
            titleAR: "صدر دجاج مع أرز وبروكلي",
            titleEN: "Chicken breast with rice & broccoli",
            descriptionAR: "صدر دجاج مشوي، أرز أبيض أو بني، وخضار.",
            descriptionEN: "Grilled chicken breast, white/brown rice, and veggies.",
            calories: 550,
            protein: 45,
            carbs: 60,
            fats: 12
        ),
        MealItem(
            titleAR: "سلطة تونة",
            titleEN: "Tuna salad",
            descriptionAR: "تونة بالماء، خضار مشكّلة، زيت زيتون، وخبز كامل.",
            descriptionEN: "Tuna in water, mixed veggies, olive oil, whole-grain bread.",
            calories: 380,
            protein: 32,
            carbs: 25,
            fats: 14
        ),
        MealItem(
            titleAR: "زبادي يوناني بالمكسرات",
            titleEN: "Greek yogurt with nuts",
            descriptionAR: "زبادي عالي البروتين، مكسرات، وتوت.",
            descriptionEN: "High-protein yogurt, nuts, and berries.",
            calories: 300,
            protein: 24,
            carbs: 22,
            fats: 12
        )
    ]
}

struct MealPlan {
    let titleAR: String
    let titleEN: String
    let goal: OnboardingGoal
    let meals: [MealItem]
    
    func description(isArabic: Bool) -> String {
        switch goal {
        case .loseFat:
            return isArabic
            ? "خطة محسوبة على عجز سعري خفيف، موزعة على ٣–٤ وجبات."
            : "Plan designed around a slight calorie deficit, split into 3–4 meals."
        case .buildMuscle:
            return isArabic
            ? "خطة بزيادة سعرية بسيطة مع بروتين عالي لدعم بناء العضلات."
            : "Plan with a small surplus and high protein to support muscle gain."
        case .improveFitness:
            return isArabic
            ? "خطة متوازنة للحفاظ على الوزن وتحسين الأداء."
            : "Balanced plan to maintain weight and improve performance."
        }
    }
    
    static func planFor(goal: OnboardingGoal, calories: Int) -> MealPlan {
        let baseMeals = MealItem.sampleMeals
        
        switch goal {
        case .loseFat:
            return MealPlan(
                titleAR: "نزول دهون",
                titleEN: "Fat loss",
                goal: goal,
                meals: baseMeals
            )
        case .buildMuscle:
            return MealPlan(
                titleAR: "بناء عضل",
                titleEN: "Muscle gain",
                goal: goal,
                meals: baseMeals
            )
        case .improveFitness:
            return MealPlan(
                titleAR: "تحسين اللياقة",
                titleEN: "Fitness focus",
                goal: goal,
                meals: baseMeals
            )
        }
    }
}

// MARK: - Nutrition Programs samples (مؤقتة حتى ربط الـ backend)

struct NutritionProgramSample: Identifiable {
    let id = UUID()
    let titleAR: String
    let titleEN: String
    let subtitleAR: String
    let subtitleEN: String
    let caloriesPerDay: Int
    let plan: MealPlan
}

extension NutritionProgramSample {
    static let samplePrograms: [NutritionProgramSample] = [
        NutritionProgramSample(
            titleAR: "خطة نزول دهون ٢٠٠٠ سعره",
            titleEN: "2000 kcal fat-loss plan",
            subtitleAR: "مناسبة للنشاط المتوسط مع بروتين عالي.",
            subtitleEN: "Great for moderate activity with high protein.",
            caloriesPerDay: 2000,
            plan: MealPlan.planFor(goal: .loseFat, calories: 2000)
        ),
        NutritionProgramSample(
            titleAR: "خطة بناء عضل ٢٤٠٠ سعره",
            titleEN: "2400 kcal muscle-gain plan",
            subtitleAR: "زيادة سعرية بسيطة لبناء العضل بدون دهون عالية.",
            subtitleEN: "Light surplus to build muscle with limited fat gain.",
            caloriesPerDay: 2400,
            plan: MealPlan.planFor(goal: .buildMuscle, calories: 2400)
        )
    ]
}

#Preview {
    NutritionView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
        .environmentObject(NutritionManager.shared)
        .environmentObject(OnboardingManager.shared)
        .environmentObject(AuthenticationManager.shared)
}
