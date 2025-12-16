//
//  WeeklyCheckInFormView.swift
//  FITGET
//
//  فورم المتابعة الأسبوعية مع المدرب
//

import SwiftUI

struct WeeklyCheckInFormView: View {
    let isArabic: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var currentWeek: Int = 3
    @State private var weight: Double = 80
    @State private var waist: Double = 90
    @State private var trainingAdherence: Int = 80
    @State private var nutritionAdherence: Int = 75
    @State private var averageSleep: Double = 7
    @State private var energyLevel: Int = 3
    @State private var notes: String = ""

    @State private var showSentAlert = false

    var body: some View {
        Form {
            Section(header: Text(isArabic ? "أرقام الأسبوع" : "This week numbers")) {
                Stepper(
                    isArabic ? "الأسبوع \(currentWeek)" : "Week \(currentWeek)",
                    value: $currentWeek,
                    in: 1...52
                )

                HStack {
                    Text(isArabic ? "الوزن (كجم)" : "Weight (kg)")
                    Spacer()
                    TextField("", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }

                HStack {
                    Text(isArabic ? "محيط الخصر (سم)" : "Waist (cm)")
                    Spacer()
                    TextField("", value: $waist, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }

            Section(header: Text(isArabic ? "الالتزام" : "Adherence")) {
                adherenceSlider(
                    titleAR: "الالتزام بالتمرين",
                    titleEN: "Training adherence",
                    value: $trainingAdherence
                )
                adherenceSlider(
                    titleAR: "الالتزام بالتغذية",
                    titleEN: "Nutrition adherence",
                    value: $nutritionAdherence
                )

                HStack {
                    Text(isArabic ? "متوسط ساعات النوم" : "Average sleep (h)")
                    Spacer()
                    Text(String(format: "%.1f", averageSleep))
                }
                Slider(value: $averageSleep, in: 4...10, step: 0.5)

                Picker(isArabic ? "مستوى الطاقة العام" : "Overall energy", selection: $energyLevel) {
                    Text(isArabic ? "ضعيف" : "Low").tag(1)
                    Text(isArabic ? "متوسط" : "Medium").tag(2)
                    Text(isArabic ? "جيد" : "Good").tag(3)
                    Text(isArabic ? "ممتاز" : "Great").tag(4)
                }
            }

            Section(header: Text(isArabic ? "ملاحظاتك للمدرب" : "Notes to your coach")) {
                TextField(
                    isArabic ? "اكتب بإيجاز كيف كان أسبوعك، وما الصعوبات التي واجهتها." :
                    "Briefly describe how your week went and any struggles.",
                    text: $notes,
                    axis: .vertical
                )
                .lineLimit(3...6)
            }

            Section {
                Button {
                    showSentAlert = true
                } label: {
                    Text(isArabic ? "إرسال تقرير الأسبوع" : "Send weekly report")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(isArabic ? "متابعة أسبوعية" : "Weekly check-in")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showSentAlert) {
            Alert(
                title: Text(isArabic ? "تم حفظ التقرير" : "Report sent"),
                message: Text(
                    isArabic
                    ? "في النسخة الكاملة سيتم إرسال هذا التقرير للمدرب ليحدث خطتك."
                    : "In the full version this report will be sent to your coach to update your plan."
                ),
                dismissButton: .default(Text(isArabic ? "تم" : "OK")) {
                    dismiss()
                }
            )
        }
    }

    private func adherenceSlider(titleAR: String,
                                 titleEN: String,
                                 value: Binding<Int>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(isArabic ? titleAR : titleEN)
                Spacer()
                Text("\(value.wrappedValue)%")
            }
            Slider(
                value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = Int($0.rounded()) }
                ),
                in: 0...100
            )
        }
    }
}

#Preview {
    NavigationStack {
        WeeklyCheckInFormView(isArabic: true)
            .environmentObject(ThemeManager.shared)
    }
}
