//
//  CaloriesView.swift
//  Fitget
//
//  Created on 20/11/2025.
//

import SwiftUI

struct CaloriesView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var age = ""
    @State private var gender = "male"
    @State private var weight = ""
    @State private var height = ""
    @State private var activity = "1.0"
    @State private var result: Int? = nil
    
    var isArabic: Bool { languageManager.currentLanguage == "ar" }
    
    let activityLevels = [
        ("1.0", "Rest"),
        ("1.2", "Sedentary"),
        ("1.4", "Light"),
        ("1.6", "Active"),
        ("1.8", "Very Active")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "1a1a2e").ignoresSafeArea()
            
            VStack(spacing: 22) {
                Text(isArabic ? "حاسبة السعرات الحرارية اليومية" : "Daily Calories Calculator")
                    .font(.title2)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    CustomTextField(icon: "calendar", placeholder: isArabic ? "العمر" : "Age", text: $age)
                        .keyboardType(.numberPad)
                    CustomTextField(icon: "scalemass", placeholder: isArabic ? "الوزن (كجم)" : "Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    CustomTextField(icon: "ruler", placeholder: isArabic ? "الطول (سم)" : "Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                }
                
                HStack(spacing: 25) {
                    Button {
                        gender = "male"
                    } label: {
                        Text(isArabic ? "ذكر" : "Male")
                            .padding()
                            .background(gender == "male" ? Color(hex: "00d4ff") : Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    Button {
                        gender = "female"
                    } label: {
                        Text(isArabic ? "أنثى" : "Female")
                            .padding()
                            .background(gender == "female" ? Color(hex: "00d4ff") : Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
                
                // مستوى النشاط
                Picker(isArabic ? "النشاط" : "Activity", selection: $activity) {
                    ForEach(activityLevels, id: \.0) { value, label in
                        Text(isArabic ? activityArabic(label) : label)
                            .tag(value)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Button {
                    calculate()
                } label: {
                    Text(isArabic ? "احسب السعرات" : "Calculate")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "00d4ff"))
                        .cornerRadius(14)
                }
                .padding(.top, 10)
                
                if let result = result {
                    Text((isArabic ? "سعراتك اليومية = " : "Your daily calories = ") + "\(result) kcal")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .padding()
                }
                
                Spacer()
            }.padding()
        }
        .navigationTitle(isArabic ? "حاسبة السعرات" : "Calories Calc")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func activityArabic(_ label: String) -> String {
        switch label {
        case "Rest": return "راحة"
        case "Sedentary": return "قليل جداً"
        case "Light": return "خفيف"
        case "Active": return "نشط"
        case "Very Active": return "نشط جداً"
        default: return label
        }
    }

    func calculate() {
        guard let ageInt = Int(age),
              let weightKg = Double(weight),
              let heightCm = Double(height),
              let activityFactor = Double(activity) else {
            result = nil
            return
        }
        
        // معادلة ميفلين-سانت جيور
        let bmr: Double
        if gender == "male" {
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(ageInt) + 5
        } else {
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(ageInt) - 161
        }
        self.result = Int(bmr * activityFactor)
    }
}

#Preview {
    CaloriesView()
        .environmentObject(LanguageManager.shared)
}
