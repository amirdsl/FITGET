//
//  SignupView.swift
//  FITGET
//

import SwiftUI
import Combine

struct SignupView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var authSession: AuthSession
    @EnvironmentObject var supabaseAuth: SupabaseAuthService

    // نستخدم AuthenticationManager لإنشاء البروفايل وربطه بالـ Supabase
    private let authManager = AuthenticationManager.shared

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isSubmitting: Bool = false
    @State private var localError: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    Text("إنشاء حساب جديد")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 16) {
                        TextField("الاسم الكامل", text: $name)
                            .textInputAutocapitalization(.words)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)

                        TextField("البريد الإلكتروني", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)

                        SecureField("كلمة المرور", text: $password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }

                    if let error = localError ?? authManager.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: handleSignup) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("إنشاء الحساب")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.accentColor)
                    .cornerRadius(14)
                    .disabled(isSubmitting)

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
    }

    private func handleSignup() {
        localError = nil

        let trimmedName  = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass  = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty,
              !trimmedEmail.isEmpty,
              !trimmedPass.isEmpty else {
            localError = "يرجى إدخال الاسم، البريد الإلكتروني، وكلمة المرور."
            return
        }

        isSubmitting = true

        Task {
            // كل منطق التسجيل من خلال AuthenticationManager فقط
            await authManager.signUp(
                name: trimmedName,
                email: trimmedEmail,
                password: trimmedPass
            )

            await MainActor.run {
                // لو التطبيق فعلاً عمل تسجيل دخول بعد signUp
                if authManager.isAuthenticated {
                    authSession.isLoggedIn = true
                    // SupabaseAuthService يقدر يلتقط الجلسة في onAppear عن طريق loadSession()
                    dismiss()
                } else if let msg = authManager.errorMessage {
                    // مثال: "Check your email to confirm your account."
                    self.localError = msg
                }
                self.isSubmitting = false
            }
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthSession())
        .environmentObject(SupabaseAuthService.shared)
}
