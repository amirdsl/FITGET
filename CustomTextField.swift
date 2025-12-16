//
//  CustomTextField.swift
//  Fitget
//
//  Created on 22/11/2025.
//

import SwiftUI
import Combine

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryBlue)
                .frame(width: 24)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(themeManager.textSecondary.opacity(0.6)))
                .foregroundColor(themeManager.textPrimary)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.textSecondary.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var isSecure: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryBlue)
                .frame(width: 24)
            
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(themeManager.textSecondary.opacity(0.6)))
                    .foregroundColor(themeManager.textPrimary)
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(themeManager.textSecondary.opacity(0.6)))
                    .foregroundColor(themeManager.textPrimary)
                    .autocapitalization(.none)
            }
            
            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(themeManager.textSecondary)
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.textSecondary.opacity(0.2), lineWidth: 1)
        )
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppColors.primaryGradient)
            .cornerRadius(16)
            .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(AppColors.primaryBlue)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(themeManager.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.primaryBlue.opacity(0.5), lineWidth: 2)
            )
        }
    }
}
