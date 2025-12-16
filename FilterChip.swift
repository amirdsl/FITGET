//
//  FilterChip.swift
//  Fitget
//
//  Created on 21/11/2025.
//

import SwiftUI
import Combine

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : themeManager.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.primaryBlue : themeManager.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : themeManager.textSecondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
