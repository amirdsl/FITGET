//
//  RegisterView.swift
//  FITGET
//

import SwiftUI
import Combine

struct RegisterView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?

    private let authManager = AuthenticationManager.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {

                Text("تسجيل حساب جديد")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
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

                if let error = errorMessage ?? authManager.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: handleRegister) {
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

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
    }

    private func handleRegister() {
        errorMessage = nil

        let trimmedName  = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass  = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty,
              !trimmedEmail.isEmpty,
              !trimmedPass.isEmpty else {
            errorMessage = "يرجى إدخال الاسم، البريد الإلكتروني، وكلمة المرور."
            return
        }

        isSubmitting = true

        Task {
            await authManager.signUp(
                name: trimmedName,   // ✅ لاحظ أن name يأتي أولاً
                email: trimmedEmail,
                password: trimmedPass
            )

            await MainActor.run {
                self.isSubmitting = false
                if authManager.isAuthenticated {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
