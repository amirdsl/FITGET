//
//  BMIView.swift
//  Fitget
//
//  Created on 20/11/2025.
//

import SwiftUI

struct BMIView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var height = ""
    @State private var weight = ""
    @State private var bmi: Double? = nil
    @State private var status: String? = nil
    
    var isArabic: Bool { languageManager.currentLanguage == "ar" }
    
    var body: some View {
        ZStack {
            Color(hex: "1a1a2e").ignoresSafeArea()
            VStack(spacing: 24) {
                Text(isArabic ? "حاسبة مؤشر كتلة الجسم (BMI)" : "BMI Calculator")
                    .font(.title2)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    CustomTextField(icon: "scalemass", placeholder: isArabic ? "الوزن (كجم)" : "Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    CustomTextField(icon: "ruler", placeholder: isArabic ? "الطول (سم)" : "Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                }
                
                Button {
                    calculate()
                } label: {
                    Text(isArabic ? "احسب BMI" : "Calculate BMI")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "00d4ff"))
                        .cornerRadius(14)
                }
                .padding(.top, 10)
                
                if let bmi = bmi {
                    VStack(spacing: 7) {
                        Text(String(format: "BMI = %.1f", bmi))
                            .font(.title).fontWeight(.bold)
                            .foregroundColor(Color(hex: "FFA500"))
                        Text(status ?? "")
                            .font(.headline)
                            .foregroundColor(bmiColor(bmi))
                    }
                    .padding()
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle(isArabic ? "كتلة الجسم" : "BMI")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func calculate() {
        guard let weightDouble = Double(weight),
              let heightDouble = Double(height), heightDouble > 0 else {
            bmi = nil
            return
        }
        let meter = heightDouble / 100
        let res = weightDouble / (meter * meter)
        self.bmi = res
        if res < 18.5 {
            status = isArabic ? "نحافة" : "Underweight"
        } else if res < 25 {
            status = isArabic ? "وزن طبيعي" : "Normal"
        } else if res < 30 {
            status = isArabic ? "وزن زائد" : "Overweight"
        } else {
            status = isArabic ? "سمنة" : "Obese"
        }
    }
    
    func bmiColor(_ value: Double) -> Color {
        if value < 18.5 { return Color.blue }
        if value < 25 { return Color.green }
        if value < 30 { return Color.yellow }
        return Color.red
    }
}

#Preview {
    BMIView()
        .environmentObject(LanguageManager.shared)
}
