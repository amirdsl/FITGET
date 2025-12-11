//
//  LoginView.swift
//  FITGET
//

import SwiftUI
import Combine

struct LoginView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var authSession: AuthSession
    @EnvironmentObject var supabaseAuth: SupabaseAuthService

    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isSubmitting: Bool = false
    @State private var localError: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {

                Text("تسجيل الدخول")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 16) {
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

                if let error = localError ?? supabaseAuth.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: handleLogin) {
                    if isSubmitting || supabaseAuth.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("تسجيل الدخول")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.accentColor)
                .cornerRadius(14)
                .disabled(isSubmitting || supabaseAuth.isLoading)

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

    private func handleLogin() {
        localError = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass  = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPass.isEmpty else {
            localError = "يرجى إدخال البريد الإلكتروني وكلمة المرور."
            return
        }

        isSubmitting = true

        Task {
            do {
                try await supabaseAuth.signIn(email: trimmedEmail, password: trimmedPass)
                if supabaseAuth.isAuthenticated {
                    authSession.isLoggedIn = true
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    self.localError = error.localizedDescription
                }
            }

            await MainActor.run {
                self.isSubmitting = false
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthSession())
        .environmentObject(SupabaseAuthService.shared)
}
