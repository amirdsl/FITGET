//
//  SignupView.swift
//  FITGET
//

import SwiftUI

struct SignupView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // حالة للتحكم في ظهور كلمة المرور
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false // متغير جديد لتأكيد كلمة المرور

    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showLoginView = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Titles
                        VStack(alignment: .leading, spacing: 12) {
                            Text("إنشاء حساب جديد 🚀")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                            
                            Text("ابدأ رحلتك الصحية معنا اليوم")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Inputs
                        VStack(spacing: 24) {
                            // Name
                            inputField(title: "الاسم الكامل", icon: "person", text: $name)
                            
                            // Email
                            inputField(title: "البريد الإلكتروني", icon: "envelope", text: $email, isEmail: true)
                            
                            // Password
                            passwordField(title: "كلمة المرور", text: $password, isVisible: $isPasswordVisible)
                            
                            // Confirm Password (تم التعديل لإضافة زر العين)
                            passwordField(title: "تأكيد كلمة المرور", text: $confirmPassword, isVisible: $isConfirmPasswordVisible)
                        }
                        
                        // Signup Button
                        Button(action: {
                            performSignup()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("إنشاء الحساب")
                                        .fontWeight(.bold)
                                    Image(systemName: "arrow.left")
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "0091ff"), Color(hex: "00d4ff")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "0091ff").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLoading)
                        
                        // Error Message
                        if showingError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(errorMessage)
                            }
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // زر الانتقال لتسجيل الدخول
                        HStack {
                            Spacer()
                            Text("لديك حساب بالفعل؟")
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showLoginView = true
                            }) {
                                Text("تسجيل الدخول")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "0091ff"))
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showLoginView) {
            LoginView()
        }
    }
    
    // مكون حقل نصي عادي
    private func inputField(title: String, icon: String, text: Binding<String>, isEmail: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "1A1A1A"))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                TextField("أدخل \(title)", text: text)
                    .keyboardType(isEmail ? .emailAddress : .default)
                    .autocapitalization(isEmail ? .none : .words)
                    .disableAutocorrection(true)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        }
    }
    
    // مكون حقل كلمة المرور (مع زر العين)
    private func passwordField(title: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "1A1A1A"))
            
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                
                if isVisible.wrappedValue {
                    TextField(title, text: text)
                        .autocapitalization(.none)
                } else {
                    SecureField(title, text: text)
                        .autocapitalization(.none)
                }
                
                Button(action: { isVisible.wrappedValue.toggle() }) {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        }
    }
    
    private func performSignup() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "جميع الحقول مطلوبة"
            showingError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "كلمات المرور غير متطابقة"
            showingError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
            showingError = true
            return
        }
        
        isLoading = true
        showingError = false
        
        Task {
            await authManager.signUp(name: name, email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                if let error = authManager.errorMessage {
                    errorMessage = error
                    showingError = true
                }
            }
        }
    }
}
