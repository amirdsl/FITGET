//
//  ProfileView.swift
//  FITGET
//

import SwiftUI
import Combine

// MARK: - Safe Wrappers (Mock Managers)
// (تم الإبقاء عليها كما طلبت لضمان عمل الكود)

class SafePlayerProgress: ObservableObject {
    @Published var currentLevel: Int = 1
    @Published var currentXP: Int = 350
    @Published var totalCoins: Int = 120
    
    static let shared = SafePlayerProgress()
    private init() {}
}

class SafeSubscriptionStore: ObservableObject {
    struct State {
        var isSubscriptionActive: Bool = false
        var role: UserRole = .free
        var activePlan: Plan? = nil
    }
    struct Plan { var tier: Tier = Tier(localizedName: "Premium") }
    struct Tier { var localizedName: String }
    enum UserRole { case guest, free, premium }
    
    @Published var state = State()
    
    static let shared = SafeSubscriptionStore()
    private init() {}
}

// MARK: - Main View

struct ProfileView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var authManager = AuthenticationManager.shared
    
    // Managers
    @StateObject var playerProgress = SafePlayerProgress.shared
    @StateObject var subscriptionStore = SafeSubscriptionStore.shared
    @ObservedObject var progressManager = ProgressManager.shared
    @ObservedObject var challengesManager = ChallengesManager.shared
    @ObservedObject var nutritionManager = NutritionManager.shared

    // Animation States
    @State private var animateEntrance = false
    @State private var animateXP = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var displayName: String {
        isArabic ? "مستخدم FITGET" : "FITGET user"
    }
    
    // Helper Data
    private func getUserAge() -> Int { 25 }
    private func getUserHeight() -> Double { 175.0 }
    private func getUserWeight() -> Double { 75.0 }

    private var subscriptionTitle: String {
        let state = subscriptionStore.state
        if state.isSubscriptionActive { return isArabic ? "مشترك بريميوم" : "Premium member" }
        switch state.role {
        case .guest: return isArabic ? "وضع الضيف" : "Guest mode"
        case .free: return isArabic ? "خطة مجانية" : "Free plan"
        default: return isArabic ? "مستخدم" : "User"
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // خلفية متدرجة خفيفة
            LinearGradient(
                colors: [themeManager.backgroundColor, themeManager.backgroundColor.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. Header
                    headerSection
                        .offset(y: animateEntrance ? 0 : -20)
                        .opacity(animateEntrance ? 1 : 0)
                    
                    // 2. Level & XP
                    levelAndXPSection
                        .offset(y: animateEntrance ? 0 : 20)
                        .opacity(animateEntrance ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateEntrance)
                    
                    // 3. Activity
                    activitySection
                        .offset(y: animateEntrance ? 0 : 30)
                        .opacity(animateEntrance ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateEntrance)
                    
                    // 4. Nutrition
                    nutritionQuickSection
                        .offset(y: animateEntrance ? 0 : 40)
                        .opacity(animateEntrance ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: animateEntrance)
                    
                    // 5. Coach
                    coachSection
                        .offset(y: animateEntrance ? 0 : 50)
                        .opacity(animateEntrance ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: animateEntrance)
                    
                    // 6. Account & App
                    Group {
                        accountSection
                        appSection
                    }
                    .offset(y: animateEntrance ? 0 : 60)
                    .opacity(animateEntrance ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: animateEntrance)
                   
                    // Sign Out
                    Button(action: {
                        withAnimation(.spring()) {
                            authManager.signOut()
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text(isArabic ? "تسجيل الخروج" : "Sign Out")
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.red.opacity(0.8), Color.pink.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.top, 10)
                    .opacity(animateEntrance ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: animateEntrance)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(isArabic ? "حسابي" : "My account")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateEntrance = true
            }
            // تأخير بسيط لملء شريط الخبرة
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animateXP = true
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                // Outer Glow Ring
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [themeManager.primary, themeManager.accent, themeManager.primary]),
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 78, height: 78)
                    .rotationEffect(.degrees(animateEntrance ? 360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateEntrance)

                // Avatar Background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [themeManager.primary.opacity(0.2), themeManager.accent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                // Initials
                Text(initialsFromName(displayName))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primary)

                // Edit/Camera Icon
                Circle()
                    .fill(themeManager.cardBackground)
                    .frame(width: 26, height: 26)
                    .shadow(radius: 2)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(themeManager.textSecondary)
                    )
                    .offset(x: 2, y: 2)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(displayName)
                    .font(.title3.bold())
                    .foregroundColor(themeManager.textPrimary)
                    .lineLimit(1)

                // Subscription Badge
                Text(subscriptionTitle)
                    .font(.caption2.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(colors: [themeManager.primary, themeManager.accent], startPoint: .leading, endPoint: .trailing)
                            .opacity(0.1)
                    )
                    .foregroundColor(themeManager.primary)
                    .clipShape(Capsule())

                // Streak & Coins
                HStack(spacing: 12) {
                    Label {
                        Text(isArabic ? "\(progressManager.currentStreak) يوم" : "\(progressManager.currentStreak)d streak")
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)

                    Label {
                        Text("\(playerProgress.totalCoins)")
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(24)
        .shadow(color: themeManager.primary.opacity(0.08), radius: 10, x: 0, y: 5)
    }

    // MARK: - Level & XP

    private var levelAndXPSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? "المستوى الحالي" : "Current Level")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                    Text("Lv \(playerProgress.currentLevel)")
                        .font(.title.bold())
                        .foregroundColor(themeManager.primary)
                }
                
                Spacer()
                
                // Rank Badge
                Text(levelLabel)
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.primary.opacity(0.1))
                    .foregroundColor(themeManager.primary)
                    .clipShape(Capsule())
            }

            // Stats Grid
            HStack(spacing: 12) {
                miniStat(icon: "sparkles", titleAR: "الخبرة", titleEN: "XP", value: "\(playerProgress.currentXP)", color: .purple)
                miniStat(icon: "bitcoinsign.circle.fill", titleAR: "العملات", titleEN: "Coins", value: "\(playerProgress.totalCoins)", color: .yellow)
                miniStat(icon: "trophy.fill", titleAR: "التقييم", titleEN: "Rank", value: "Top 10%", color: .orange)
            }

            // XP Bar
            VStack(alignment: .leading, spacing: 8) {
                let nextXP = 1000
                let current = min(playerProgress.currentXP, nextXP)
                let progress = Double(current) / Double(nextXP)

                HStack {
                    Text(isArabic ? "التقدم للمستوى التالي" : "Next Level Progress")
                        .font(.caption2.bold())
                        .foregroundColor(themeManager.textSecondary)
                    Spacer()
                    Text("\(current)/\(nextXP) XP")
                        .font(.caption2.bold())
                        .foregroundColor(themeManager.primary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(
                                LinearGradient(colors: [themeManager.primary, themeManager.accent], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: animateXP ? geo.size.width * progress : 0, height: 10)
                            .shadow(color: themeManager.primary.opacity(0.5), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(18)
        .background(themeManager.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private var levelLabel: String {
        let level = playerProgress.currentLevel
        if isArabic {
            switch level {
            case 1..<5:   return "مبتدئ"
            case 5..<10:  return "متقدم"
            default:      return "محترف"
            }
        } else {
            switch level {
            case 1..<5:   return "Beginner"
            case 5..<10:  return "Intermediate"
            default:      return "Advanced"
            }
        }
    }

    // MARK: - Activity

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isArabic ? "نشاطك اليوم" : "Today’s Activity")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            HStack(spacing: 12) {
                activityCard(
                    icon: "flame.fill",
                    value: "\(progressManager.currentStreak)",
                    unit: isArabic ? "يوم" : "Day",
                    color: .orange
                )
                
                activityCard(
                    icon: "figure.walk",
                    value: "\(progressManager.todaySteps)",
                    unit: "",
                    color: .blue
                )
                
                activityCard(
                    icon: "flag.2.crossed.fill",
                    value: "\(challengesManager.activeChallengesCount)",
                    unit: isArabic ? "تحدي" : "Chall.",
                    color: .pink
                )
            }
        }
        .padding(18)
        .background(themeManager.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private func activityCard(icon: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.caption.bold())
                        .foregroundColor(color)
                )
            
            Text(value)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(themeManager.backgroundColor)
        .cornerRadius(16)
    }

    // MARK: - Nutrition

    private var nutritionQuickSection: some View {
        let target = nutritionManager.targetCalories
        let today = nutritionManager.todayCalories
        let total = max(target, 1)
        let progress = min(Double(today) / Double(total), 1.0)

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: animateXP ? progress : 0)
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [.orange, .red]), center: .center),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? "السعرات الحرارية" : "Calories")
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.textPrimary)
                
                HStack(spacing: 4) {
                    Text("\(today)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text("/ \(target) kcal")
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                let remaining = max(target - today, 0)
                Text(isArabic ? "متبقي \(remaining)" : "\(remaining) left")
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            }
            Spacer()
            
            Image(systemName: "chevron.left") // أو Right حسب اللغة
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(18)
        .background(themeManager.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - Coach

    private var coachSection: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.fill.badge.plus") // استبدلها بصورة المدرب
                .font(.largeTitle)
                .padding()
                .background(themeManager.primary.opacity(0.1))
                .foregroundColor(themeManager.primary)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? "مدربك الشخصي" : "Personal Coach")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Text(isArabic ? "تواصل مع مدربك للحصول على خطة مخصصة" : "Connect for a custom plan")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(18)
        .background(themeManager.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - Account & App

    private var accountSection: some View {
        VStack(spacing: 0) {
            sectionHeader(title: isArabic ? "بيانات الجسم" : "Body Data")
            
            HStack(spacing: 12) {
                bodyDataPill(title: isArabic ? "الوزن" : "Weight", value: "\(Int(getUserWeight())) kg")
                bodyDataPill(title: isArabic ? "الطول" : "Height", value: "\(Int(getUserHeight())) cm")
                bodyDataPill(title: isArabic ? "العمر" : "Age", value: "\(getUserAge())")
            }
            .padding(.bottom, 16)
        }
        .padding(18)
        .background(themeManager.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var appSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: SettingsView()) {
                settingsRow(icon: "gearshape.fill", title: isArabic ? "الإعدادات" : "Settings", color: .gray)
            }
            
            Divider().padding(.leading, 50)
            
            NavigationLink(destination: LanguageSettingsView()) {
                settingsRow(icon: "globe", title: isArabic ? "اللغة" : "Language", color: .blue)
            }
        }
        .padding(.vertical, 8)
        .background(themeManager.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - Helpers

    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(themeManager.textPrimary)
            Spacer()
        }
        .padding(.bottom, 12)
    }

    private func miniStat(icon: String, titleAR: String, titleEN: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            Text(isArabic ? titleAR : titleEN)
                .font(.caption2)
                .foregroundColor(themeManager.textSecondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(themeManager.backgroundColor)
        .cornerRadius(14)
    }
    
    private func bodyDataPill(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(themeManager.primary)
            Text(title)
                .font(.caption2)
                .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(themeManager.primary.opacity(0.05))
        .cornerRadius(12)
    }

    private func settingsRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.body)
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
            
            Image(systemName: isArabic ? "chevron.left" : "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(12)
        .contentShape(Rectangle()) // لجعل الصف قابلاً للنقر بالكامل
    }

    private func initialsFromName(_ name: String) -> String {
        let comps = name.split(separator: " ")
        let letters = comps.prefix(2).compactMap { $0.first }
        return letters.map { String($0) }.joined().uppercased()
    }
}

// Button Style for Animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(AuthenticationManager.shared)
    }
}
