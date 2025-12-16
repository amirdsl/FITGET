//
//  RegisterView.swift
//  FITGET
//

import SwiftUI
import Combine

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    @State private var isSecure: Bool = true
    @State private var acceptTerms: Bool = false
    
    private let authManager = AuthenticationManager.shared
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        acceptTerms
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "0091ff").opacity(0.1),
                        Color(hex: "00d4ff").opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("إنشاء حساب جديد")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                            
                            Text("انضم إلى مجتمع FITGET")
                                .font(.subheadline)
                                .foregroundColor(themeManager.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 16)
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 16) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("الاسم الكامل", systemImage: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(themeManager.textSecondary)
                                
                                TextField("أحمد محمد", text: $name)
                                    .textInputAutocapitalization(.words)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                !name.isEmpty ? Color(hex: "0091ff") : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("البريد الإلكتروني", systemImage: "envelope.fill")
                                    .font(.caption)
                                    .foregroundColor(themeManager.textSecondary)
                                
                                TextField("example@email.com", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                !email.isEmpty ? Color(hex: "0091ff") : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("كلمة المرور", systemImage: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(themeManager.textSecondary)
                                
                                HStack(spacing: 12) {
                                    if isSecure {
                                        SecureField("••••••••", text: $password)
                                    } else {
                                        TextField("••••••••", text: $password)
                                    }
                                    
                                    Button(action: { isSecure.toggle() }) {
                                        Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(themeManager.textSecondary)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            !password.isEmpty ? Color(hex: "0091ff") : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                
                                if !password.isEmpty && password.count < 6 {
                                    Text("كلمة المرور يجب أن تكون 6 أحرف على الأقل")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("تأكيد كلمة المرور", systemImage: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(themeManager.textSecondary)
                                
                                SecureField("••••••••", text: $confirmPassword)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                !confirmPassword.isEmpty && password != confirmPassword ? Color.red : (password == confirmPassword && !confirmPassword.isEmpty ? Color.green : Color.clear),
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                        
                        // Error Message
                        if let error = errorMessage ?? authManager.errorMessage {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                            .transition(.scale)
                        }
                        
                        // Terms Checkbox
                        HStack(spacing: 12) {
                            Button(action: { acceptTerms.toggle() }) {
                                Image(systemName: acceptTerms ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 18))
                                    .foregroundColor(acceptTerms ? Color(hex: "0091ff") : Color.gray)
                            }
                            
                            HStack(spacing: 4) {
                                Text("أوافق على")
                                    .font(.caption)
                                Button(action: {}) {
                                    Text("الشروط والأحكام")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "0091ff"))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        Spacer()
                            .frame(height: 16)
                        
                        // Sign Up Button
                        Button(action: handleRegister) {
                            if isSubmitting {
                                HStack(spacing: 12) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                    Text("جاري...")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            } else {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.badge.plus")
                                    Text("إنشاء الحساب")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "0091ff"),
                                    Color(hex: "00d4ff")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "0091ff").opacity(0.4), radius: 10, x: 0, y: 5)
                        .disabled(isSubmitting || !isFormValid)
                        .opacity(isFormValid ? 1 : 0.6)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("رجوع")
                        }
                        .foregroundColor(Color(hex: "0091ff"))
                    }
                }
            }
        }
    }
    
    private func handleRegister() {
        errorMessage = nil
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty, !trimmedPass.isEmpty else {
            errorMessage = "يرجى إدخال جميع الحقول"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "كلمات المرور غير متطابقة"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
            return
        }
        
        isSubmitting = true
        
        Task {
            await authManager.signUp(
                name: trimmedName,
                email: trimmedEmail,
                password: trimmedPass
            )
            
            await MainActor.run {
                self.isSubmitting = false
                if authManager.isAuthenticated {
                    dismiss()
                } else if let msg = authManager.errorMessage {
                    self.errorMessage = msg
                }
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(ThemeManager.shared)
}
