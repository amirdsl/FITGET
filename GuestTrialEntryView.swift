//
//  GuestTrialEntryView.swift
//  FITGET
//

import SwiftUI

struct GuestTrialEntryView: View {
    var onLoginSelected: () -> Void
    var onSignupSelected: () -> Void
    var onGuestStarted: () -> Void
    
    @State private var selectedGoal: GuestGoal = .weightLoss
    
    enum GuestGoal: String, CaseIterable {
        case weightLoss = "خسارة الوزن"
        case muscleGain = "بناء العضلات"
        case fitness = "اللياقة العامة"
        
        var icon: String {
            switch self {
            case .weightLoss: return "flame.fill"
            case .muscleGain: return "dumbbell.fill"
            case .fitness: return "figure.run"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text("إعداد تجربة الزائر")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Section
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles.rectangle.stack.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "0091ff"), Color(hex: "00d4ff")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding()
                                .background(Color(hex: "0091ff").opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("تجربة شاملة لمدة 7 أيام")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("استمتع بكامل ميزات التطبيق دون الحاجة لإنشاء حساب الآن. سيتم حفظ بياناتك محلياً.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 30)
                        
                        // Goal Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ما هو هدفك الأساسي؟")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(GuestGoal.allCases, id: \.self) { goal in
                                        GuestGoalCard(goal: goal, isSelected: selectedGoal == goal)
                                            .onTapGesture {
                                                withAnimation {
                                                    selectedGoal = goal
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Features List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ماذا تتضمن التجربة؟")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                // استخدام الاسم الجديد GuestFeatureRow وتحديد الألوان بدقة
                                GuestFeatureRow(icon: "play.circle.fill", title: "برامج تدريبية كاملة", iconColor: Color.blue)
                                GuestFeatureRow(icon: "fork.knife", title: "خطط تغذية ذكية", iconColor: Color.green)
                                GuestFeatureRow(icon: "chart.bar.fill", title: "تتبع التقدم والقياسات", iconColor: Color.orange)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // Warning
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            Text("تنبيه: عند حذف التطبيق ستفقد بيانات الزائر. يفضل إنشاء حساب لحفظ تقدمك.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                    }
                    .padding(.bottom, 100)
                }
            }
            
            // Bottom Button
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    Button(action: {
                        onGuestStarted()
                    }) {
                        Text("ابدأ التجربة الآن")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "0091ff"), Color(hex: "00d4ff")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "0091ff").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    HStack {
                        Text("تريد حفظ تقدمك؟")
                            .foregroundColor(.gray)
                        Button("إنشاء حساب") {
                            onSignupSelected()
                        }
                        .foregroundColor(Color(hex: "0091ff"))
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: -5)
                )
            }
        }
    }
}

// تغيير الاسم لتجنب التعارض (GuestGoalCard)
struct GuestGoalCard: View {
    let goal: GuestTrialEntryView.GuestGoal
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: goal.icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .gray)
            
            Text(goal.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
        }
        .frame(width: 120, height: 120)
        .background(
            isSelected ?
            Color(hex: "0091ff") :
            Color.white
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: isSelected ? Color(hex: "0091ff").opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
    }
}

// تغيير الاسم لتجنب التعارض (GuestFeatureRow)
struct GuestFeatureRow: View {
    let icon: String
    let title: String
    let iconColor: Color // تغيير الاسم ليكون واضحاً
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "0091ff"))
        }
        .padding(.vertical, 4)
    }
}
