//
//  SocialLoginButtonsView.swift
//  FITGET
//
//  Path: FITGET/Views/Auth/SocialLoginButtonsView.swift
//

import SwiftUI

struct SocialLoginButtonsView: View {

    var body: some View {
        VStack(spacing: 12) {

            Button(action: {
                // OAuth غير مفعّل حالياً
            }) {
                buttonContent(
                    title: "Continue with Apple",
                    systemImage: "apple.logo"
                )
            }
            .disabled(true)
            .opacity(0.6)

            Button(action: {
                // OAuth غير مفعّل حالياً
            }) {
                buttonContent(
                    title: "Continue with Google",
                    systemImage: "globe"
                )
            }
            .disabled(true)
            .opacity(0.6)
        }
    }

    // MARK: - UI

    private func buttonContent(
        title: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            Text(title)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    SocialLoginButtonsView()
}
