//
//  CalorieCalculatorView.swift
//  FITGET
//

import SwiftUI

struct CalorieCalculatorView: View {

    // المدخلات
    @State private var ageText: String = ""
    @State private var heightText: String = ""   // بالسنتيمتر
    @State private var weightText: String = ""   // بالكيلوجرام
    @State private var selectedGender: Gender = .male
    @State private var selectedActivity: ActivityLevel = .moderate

    // المخرجات
    @State private var bmr: Double?
    @State private var tdee: Double?

    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("البيانات الأساسية")) {
                Picker("الجنس", selection: $selectedGender) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.displayName).tag(gender)
                    }
                }
                .pickerStyle(.segmented)

                TextField("العمر (بالسنوات)", text: $ageText)
                    .keyboardType(.numberPad)

                TextField("الطول (سم)", text: $heightText)
                    .keyboardType(.decimalPad)

                TextField("الوزن (كجم)", text: $weightText)
                    .keyboardType(.decimalPad)
            }

            Section(header: Text("مستوى النشاط")) {
                Picker("النشاط اليومي", selection: $selectedActivity) {
                    ForEach(ActivityLevel.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }

            Section {
                Button(action: calculateCalories) {
                    Text("احسب الاحتياج اليومي")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            if let bmr = bmr, let tdee = tdee {
                Section(header: Text("النتائج")) {
                    HStack {
                        Text("معدل الأيض الأساسي (BMR)")
                        Spacer()
                        Text("\(Int(bmr)) kcal")
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("السعرات اليومية للحفاظ على الوزن (TDEE)")
                        Spacer()
                        Text("\(Int(tdee)) kcal")
                            .fontWeight(.semibold)
                    }

                    Text("يمكنك خفض أو زيادة حوالي 300–500 سعر حراري عن TDEE حسب هدفك (خسارة أو زيادة وزن).")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .navigationTitle("حاسبة السعرات")
    }

    // MARK: - Models

    enum Gender: String, CaseIterable, Identifiable {
        case male
        case female

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .male: return "ذكر"
            case .female: return "أنثى"
            }
        }
    }

    enum ActivityLevel: String, CaseIterable, Identifiable {
        case sedentary        // قليل الحركة
        case light            // نشاط خفيف
        case moderate         // متوسط
        case active           // عالي
        case veryActive       // عالي جداً

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .sedentary:   return "قليل الحركة (بدون تمرين)"
            case .light:       return "نشاط خفيف (1–3 تمارين بالأسبوع)"
            case .moderate:    return "نشاط متوسط (3–5 تمارين بالأسبوع)"
            case .active:      return "نشاط عالي (6–7 تمارين بالأسبوع)"
            case .veryActive:  return "نشاط عالي جداً (عمل بدني + تمرين قوي)"
            }
        }

        /// معامل النشاط لحساب TDEE
        var multiplier: Double {
            switch self {
            case .sedentary:   return 1.2
            case .light:       return 1.375
            case .moderate:    return 1.55
            case .active:      return 1.725
            case .veryActive:  return 1.9
            }
        }
    }

    // MARK: - Logic

    private func calculateCalories() {
        errorMessage = nil
        bmr = nil
        tdee = nil

        guard let age = Int(ageText),
              let height = Double(heightText),
              let weight = Double(weightText),
              age > 0, height > 0, weight > 0
        else {
            errorMessage = "يرجى إدخال عمر وطول ووزن صحيحة."
            return
        }

        // معادلة Mifflin-St Jeor
        let base = 10 * weight + 6.25 * height - 5 * Double(age)
        let bmrValue: Double

        switch selectedGender {
        case .male:
            bmrValue = base + 5
        case .female:
            bmrValue = base - 161
        }

        let tdeeValue = bmrValue * selectedActivity.multiplier

        bmr = bmrValue
        tdee = tdeeValue
    }
}

#Preview {
    NavigationStack {
        CalorieCalculatorView()
    }
}
