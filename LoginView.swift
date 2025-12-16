//
//  LoginView.swift
//  FITGET
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    // @EnvironmentObject var appAuthSession: AuthSession
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
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
                            Text("أهلاً بعودتك! 👋")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                            
                            Text("سجل دخولك للمتابعة من حيث توقفت")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Inputs
                        VStack(spacing: 24) {
                            // Email
                            VStack(alignment: .leading, spacing: 10) {
                                Text("البريد الإلكتروني")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.gray)
                                    TextField("example@email.com", text: $email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 10) {
                                Text("كلمة المرور")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.gray)
                                    
                                    if isPasswordVisible {
                                        TextField("أدخل كلمة المرور", text: $password)
                                            .autocapitalization(.none)
                                    } else {
                                        SecureField("أدخل كلمة المرور", text: $password)
                                            .autocapitalization(.none)
                                    }
                                    
                                    Button(action: { isPasswordVisible.toggle() }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                                
                                // Forgot Password Link
                                HStack {
                                    Spacer()
                                    Button(action: {}) {
                                        Text("نسيت كلمة المرور؟")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(Color(hex: "0091ff"))
                                    }
                                }
                            }
                        }
                        
                        // Login Button
                        Button(action: {
                            performLogin()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("تسجيل الدخول")
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
                    }
                    .padding(24)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func performLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "الرجاء ملء جميع الحقول"
            showingError = true
            return
        }
        
        isLoading = true
        showingError = false
        
        Task {
            await authManager.signIn(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                if let error = authManager.errorMessage {
                    errorMessage = error
                    showingError = true
                } else if authManager.isAuthenticated {
                    // تم تسجيل الدخول بنجاح
                    // appAuthSession.isLoggedIn = true
                }
            }
        }
    }
}
