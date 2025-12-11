//
//  SettingsView.swift
//  Fitget
//
//  Created on 21/11/2025.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("supabase_url") private var supabaseURLString: String = ""
    @AppStorage("supabase_key") private var supabaseKeyString: String = ""
    
    var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                List {
                    appearanceSection
                    supabaseSection
                    accountSection
                    supportSection
                }
                .listStyle(.insetGrouped)
                .listRowBackground(themeManager.cardBackground)      // ✅ الكروت تمشي مع الثيم
                .scrollContentBackground(.hidden)
            }
            // ✅ نخلي الـ List تتبع وضع الثيم (داكن / فاتح)
            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
            .navigationTitle(isArabic ? "الإعدادات" : "Settings")
        }
    }
    
    // MARK: - Sections
    
    private var appearanceSection: some View {
        Section(
            header: Text(isArabic ? "المظهر" : "Appearance")
                .foregroundColor(themeManager.textSecondary)
        ) {
            HStack {
                Image(systemName: "moon.fill")
                    .foregroundColor(.purple)
                
                Text(isArabic ? "الوضع الليلي" : "Dark Mode")
                    .foregroundColor(themeManager.textPrimary)
                
                Spacer()
                
                Toggle(
                    "",
                    isOn: Binding(
                        get: { themeManager.isDarkMode },
                        set: { newValue in themeManager.isDarkMode = newValue }
                    )
                )
                .labelsHidden()
                .tint(AppColors.primaryBlue)
            }
        }
    }
    
    private var supabaseSection: some View {
        Section(
            header: Text("Supabase")
                .foregroundColor(themeManager.textSecondary)
        ) {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Supabase URL", text: $supabaseURLString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                SecureField("Supabase Key", text: $supabaseKeyString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                Text(isArabic
                     ? "لن يتم حفظ هذه القيم في الكود أو Git، فقط على هذا الجهاز."
                     : "These values are stored only on this device, not in code or Git.")
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
    }
    
    private var accountSection: some View {
        Section(
            header: Text(isArabic ? "الحساب" : "Account")
                .foregroundColor(themeManager.textSecondary)
        ) {
            Button {
                // TODO: Edit profile screen
            } label: {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(AppColors.primaryBlue)
                    Text(isArabic ? "تعديل الملف الشخصي" : "Edit Profile")
                        .foregroundColor(themeManager.textPrimary)
                }
            }
            
            Button {
                // TODO: Change password screen
            } label: {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                    Text(isArabic ? "تغيير كلمة المرور" : "Change Password")
                        .foregroundColor(themeManager.textPrimary)
                }
            }
        }
    }
    
    private var supportSection: some View {
        Section(
            header: Text(isArabic ? "الدعم" : "Support")
                .foregroundColor(themeManager.textSecondary)
        ) {
            Button {
                // TODO: Help Center
            } label: {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text(isArabic ? "مركز المساعدة" : "Help Center")
                        .foregroundColor(themeManager.textPrimary)
                }
            }
            
            // الشروط والأحكام
            NavigationLink {
                TermsOfServiceView()
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.orange)
                    Text(isArabic ? "الشروط والأحكام" : "Terms of Service")
                        .foregroundColor(themeManager.textPrimary)
                }
            }
            
            // سياسة الخصوصية
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                    Text(isArabic ? "سياسة الخصوصية" : "Privacy Policy")
                        .foregroundColor(themeManager.textPrimary)
                }
            }
            
            Button {
                // TODO: Contact us flow
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.cyan)
                    Text(isArabic ? "تواصل معنا" : "Contact Us")
                        .foregroundColor(themeManager.textPrimary)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
}
