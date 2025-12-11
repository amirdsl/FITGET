//
//  CoachingQuestionnaireView.swift
//  FITGET
//
//  نموذج الهدف والحالة الصحية للمدرب الشخصي
//

import SwiftUI

struct CoachingQuestionnaireView: View {
    let isArabic: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var mainGoal: String = ""
    @State private var trainingPlace: Int = 0  // 0 بيت – 1 نادي
    @State private var trainingExperience: Int = 1 // 0 مبتدئ – 1 متوسط – 2 متقدم
    @State private var workoutsPerWeek: Int = 3
    @State private var hasInjuries: Bool = false
    @State private var injuriesDescription: String = ""
    @State private var sleepHours: Double = 7
    @State private var stressLevel: Int = 2
    @State private var notes: String = ""

    @State private var showSentAlert = false

    private var goalPlaceholder: String {
        isArabic ? "مثال: إنقاص ٨ كجم مع الحفاظ على العضل" : "Example: Lose 8kg while keeping muscle"
    }

    var body: some View {
        Form {
            Section(header: Text(isArabic ? "الهدف الرئيسي" : "Main goal")) {
                TextField(goalPlaceholder, text: $mainGoal, axis: .vertical)
                    .lineLimit(1...4)
            }

            Section(header: Text(isArabic ? "مستوى ونوع التمرين" : "Training level & type")) {
                Picker(isArabic ? "مكان التمرين" : "Training place", selection: $trainingPlace) {
                    Text(isArabic ? "البيت" : "Home").tag(0)
                    Text(isArabic ? "النادي" : "Gym").tag(1)
                }

                Picker(isArabic ? "الخبرة" : "Experience", selection: $trainingExperience) {
                    Text(isArabic ? "مبتدئ" : "Beginner").tag(0)
                    Text(isArabic ? "متوسط" : "Intermediate").tag(1)
                    Text(isArabic ? "متقدم" : "Advanced").tag(2)
                }

                Stepper(
                    value: $workoutsPerWeek,
                    in: 1...7
                ) {
                    Text(
                        isArabic
                        ? "أيام التمرين في الأسبوع: \(workoutsPerWeek)"
                        : "Workouts per week: \(workoutsPerWeek)"
                    )
                }
            }

            Section(header: Text(isArabic ? "الحالة الصحية" : "Health status")) {
                Toggle(isArabic ? "هل لديك إصابات / مشاكل صحية؟" : "Any injuries / health issues?", isOn: $hasInjuries)

                if hasInjuries {
                    TextField(
                        isArabic ? "اكتب تفاصيل مختصرة عن الإصابة" : "Write a short description",
                        text: $injuriesDescription,
                        axis: .vertical
                    )
                    .lineLimit(1...4)
                }

                HStack {
                    Text(isArabic ? "عدد ساعات النوم" : "Sleep hours")
                    Spacer()
                    Text(String(format: "%.1f", sleepHours))
                }

                Slider(value: $sleepHours, in: 4...10, step: 0.5)

                Picker(isArabic ? "مستوى الضغط اليومي" : "Daily stress level", selection: $stressLevel) {
                    Text(isArabic ? "منخفض" : "Low").tag(0)
                    Text(isArabic ? "متوسط" : "Medium").tag(1)
                    Text(isArabic ? "مرتفع" : "High").tag(2)
                }
            }

            Section(header: Text(isArabic ? "ملاحظات إضافية" : "Extra notes")) {
                TextField(
                    isArabic ? "أي ملاحظة تحب يعرفها المدرب" : "Anything else your coach should know",
                    text: $notes,
                    axis: .vertical
                )
                .lineLimit(2...6)
            }

            Section {
                Button {
                    showSentAlert = true
                } label: {
                    Text(isArabic ? "إرسال النموذج للمدرب" : "Send form to coach")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(isArabic ? "نموذج المعلومات" : "Coaching form")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showSentAlert) {
            Alert(
                title: Text(isArabic ? "تم حفظ النموذج" : "Form saved"),
                message: Text(
                    isArabic
                    ? "في النسخة الكاملة سيتم إرسال هذه البيانات للمدرب لبدء تصميم الخطة."
                    : "In the full version this data will be sent to your coach to build your plan."
                ),
                dismissButton: .default(Text(isArabic ? "تم" : "OK")) {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        CoachingQuestionnaireView(isArabic: true)
            .environmentObject(ThemeManager.shared)
    }
}
