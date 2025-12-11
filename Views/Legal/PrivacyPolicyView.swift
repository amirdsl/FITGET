//
//  PrivacyPolicyView.swift
//  Fitget
//
//  Created on 24/11/2025.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(isArabic ? "سياسة الخصوصية" : "Privacy Policy")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Group {
                        Text(isArabic ?
                             "نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة نوعية البيانات التي نجمعها وكيفية استخدامها."
                             :
                                "We respect your privacy and are committed to protecting your personal data. This policy explains what we collect and how we use it."
                        )
                        
                        section(
                            isArabic ? "البيانات التي نجمعها" : "Data We Collect",
                            isArabic ?
                            "قد نقوم بجمع معلومات الحساب (مثل الاسم والبريد الإلكتروني)، ومعلومات اللياقة (مثل الوزن والطول والأهداف)، وبيانات الاستخدام الأساسية للتطبيق."
                            :
                            "We may collect account information (such as name and email), fitness information (such as weight, height and goals), and basic app usage data."
                        )
                        
                        section(
                            isArabic ? "كيفية استخدام البيانات" : "How We Use Data",
                            isArabic ?
                            "نستخدم البيانات لتخصيص تجربتك داخل التطبيق، اقتراح برامج تدريبية وتغذوية، وتحسين جودة الخدمة."
                            :
                            "We use your data to personalize your experience, suggest workouts and nutrition plans, and improve the service."
                        )
                        
                        section(
                            isArabic ? "مشاركة البيانات" : "Data Sharing",
                            isArabic ?
                            "لا نقوم ببيع بياناتك الشخصية. قد نشارك جزءاً محدوداً من البيانات مع مزودي خدمات طرف ثالث عند الحاجة لتشغيل التطبيق."
                            :
                            "We do not sell your personal data. We may share limited data with third-party service providers only as needed to operate the app."
                        )
                        
                        section(
                            isArabic ? "حقوقك" : "Your Rights",
                            isArabic ?
                            "يمكنك طلب الوصول إلى بياناتك أو تحديثها أو حذفها في أي وقت من خلال التواصل معنا."
                            :
                            "You can request access, correction or deletion of your data at any time by contacting us."
                        )
                        
                        section(
                            isArabic ? "التخزين والأمان" : "Storage & Security",
                            isArabic ?
                            "نستخدم وسائل تقنية مناسبة لحماية بياناتك، مع العلم بأنه لا توجد وسيلة نقل بيانات عبر الإنترنت آمنة بنسبة 100٪."
                            :
                            "We use appropriate technical measures to protect your data, but no method of transmission over the internet is 100% secure."
                        )
                    }
                    .foregroundColor(themeManager.textSecondary)
                    .font(.subheadline)
                }
                .padding()
            }
        }
        .navigationTitle(isArabic ? "سياسة الخصوصية" : "Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            Text(body)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
