//
//  MealLogView.swift
//  Fitget
//
//  Created on 20/11/2025.
//

import SwiftUI

struct MealLogView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedDate = Date()
    @State private var mealLogs: [MealLog] = []
    
    var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var totalCalories: Int {
        mealLogs.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        mealLogs.reduce(0) { $0 + ($1.protein ?? 0) }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "1a1a2e").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ملخص اليوم
                VStack(spacing: 15) {
                    // منتقي التاريخ
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    
                    // إجمالي السعرات
                    HStack(spacing: 20) {
                        StatItem(
                            title: isArabic ? "سعرات" : "Calories",
                            value: "\(totalCalories)",
                            icon: "flame.fill",
                            color: Color(hex: "FF6B6B")
                        )
                        
                        StatItem(
                            title: isArabic ? "بروتين" : "Protein",
                            value: "\(Int(totalProtein))g",
                            icon: "drop.fill",
                            color: Color(hex: "4ECDC4")
                        )
                    }
                }
                .padding()
                .background(Color(hex: "00d4ff").opacity(0.1))
                
                // قائمة الوجبات
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            MealSection(
                                mealType: mealType,
                                logs: mealLogs.filter { $0.mealType == mealType.rawValue },
                                isArabic: isArabic
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(isArabic ? "سجل الوجبات" : "Meal Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO: إضافة وجبة
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "00d4ff"))
                }
            }
        }
        .onAppear {
            loadMealLogs()
        }
    }
    
    func loadMealLogs() {
        // TODO: جلب من قاعدة البيانات
        mealLogs = []
    }
}

enum MealType: String, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    
    func localizedName(isArabic: Bool) -> String {
        if !isArabic {
            return self.rawValue.capitalized
        }
        
        switch self {
        case .breakfast: return "إفطار"
        case .lunch: return "غداء"
        case .dinner: return "عشاء"
        case .snack: return "وجبة خفيفة"
        }
    }
    
    func icon() -> String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "star.fill"
        }
    }
}

struct MealSection: View {
    let mealType: MealType
    let logs: [MealLog]
    let isArabic: Bool
    
    var totalCalories: Int {
        logs.reduce(0) { $0 + $1.calories }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: mealType.icon())
                    .foregroundColor(Color(hex: "00d4ff"))
                
                Text(mealType.localizedName(isArabic: isArabic))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(totalCalories) " + (isArabic ? "سعرة" : "cal"))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Button {
                    // TODO: إضافة وجبة لهذا النوع
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "00d4ff"))
                }
            }
            
            if logs.isEmpty {
                Text(isArabic ? "لم تسجل وجبات بعد" : "No meals logged yet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
            } else {
                ForEach(logs) { log in
                    MealLogRow(log: log)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

struct MealLogRow: View {
    let log: MealLog
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(log.customName ?? "Meal")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    Label("\(log.calories) cal", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    if let protein = log.protein {
                        Label("\(Int(protein))g", systemImage: "drop.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            Spacer()
            
            Button {
                // TODO: حذف
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct MealLog: Identifiable {
    let id: UUID
    let userId: UUID
    let recipeId: UUID?
    let mealType: String
    let customName: String?
    let calories: Int
    let protein: Double?
    let carbs: Double?
    let fats: Double?
    let loggedAt: Date
}

#Preview {
    MealLogView()
        .environmentObject(LanguageManager.shared)
}
