//
//  TermsOfServiceView.swift
//  Fitget
//
//  Created on 24/11/2025.
//

import SwiftUI

struct TermsOfServiceView: View {
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
                    Text(isArabic ? "الشروط والأحكام" : "Terms of Service")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Group {
                        Text(isArabic ?
                             "باستخدامك لتطبيق FITGET فإنك توافق على هذه الشروط. يرجى قراءة البنود بعناية قبل البدء في استخدام التطبيق."
                             :
                                "By using FITGET you agree to these terms. Please read them carefully before using the app."
                        )
                        
                        section(
                            isArabic ? "استخدام التطبيق" : "Use of the App",
                            isArabic ?
                            "يُسمح لك باستخدام التطبيق لأغراض شخصية وغير تجارية فقط. لا يجوز إساءة استخدام الخدمات أو محاولة الوصول غير المصرح به إلى أنظمتنا."
                            :
                            "You may use the app for personal, non-commercial purposes only. You must not misuse the services or attempt unauthorized access."
                        )
                        
                        section(
                            isArabic ? "الحساب والمسؤولية" : "Account & Responsibility",
                            isArabic ?
                            "أنت مسؤول عن سرية بيانات تسجيل الدخول الخاصة بك وعن جميع الأنشطة التي تتم من خلال حسابك."
                            :
                            "You are responsible for maintaining the confidentiality of your login details and for all activity under your account."
                        )
                        
                        section(
                            isArabic ? "المحتوى الصحي" : "Health Content",
                            isArabic ?
                            "جميع التمارين والنصائح الغذائية في التطبيق لأغراض معلوماتية فقط ولا تُعد بديلاً عن استشارة طبيب أو مختص."
                            :
                            "All workouts and nutrition tips are for informational purposes only and are not a substitute for professional medical advice."
                        )
                        
                        section(
                            isArabic ? "الاشتراكات والمدفوعات" : "Subscriptions & Payments",
                            isArabic ?
                            "قد يقدم التطبيق خطط اشتراك مدفوعة. يتم تجديد الاشتراكات تلقائياً ما لم يتم إلغاؤها قبل نهاية الفترة الحالية من خلال إعدادات متجر التطبيقات."
                            :
                            "The app may offer paid subscription plans. Subscriptions renew automatically unless cancelled before the end of the current period in your app-store settings."
                        )
                        
                        section(
                            isArabic ? "إنهاء الاستخدام" : "Termination",
                            isArabic ?
                            "يحق لنا إيقاف أو تقييد الوصول إلى التطبيق في حال مخالفة الشروط أو إساءة الاستخدام."
                            :
                            "We may suspend or terminate access to the app if you violate these terms or misuse the service."
                        )
                    }
                    .foregroundColor(themeManager.textSecondary)
                    .font(.subheadline)
                }
                .padding()
            }
        }
        .navigationTitle(isArabic ? "الشروط والأحكام" : "Terms of Service")
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
        TermsOfServiceView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
