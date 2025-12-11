//
//  ChallengeCard.swift
//  Fitget
//
//  Created on 21/11/2025.
//

import SwiftUI
import Combine

struct ChallengeCard: View {
    let challenge: Challenge
    let isArabic: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? challenge.nameAr : challenge.nameEn)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    if let description = isArabic ? challenge.descriptionAr : challenge.descriptionEn {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(themeManager.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    if let icon = challenge.badgeIcon {
                        Image(systemName: icon)
                            .foregroundColor(AppColors.accentGold)
                            .font(.title2)
                    }
                    Text("\(challenge.xpReward) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
            
            HStack {
                Text("\(challenge.currentProgress)/\(challenge.goalValue)")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                
                Spacer()
                
                Text(String(format: "%.0f%%", challenge.progressPercentage * 100))
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.textSecondary.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.primaryBlue)
                        .frame(width: geometry.size.width * challenge.progressPercentage, height: 6)
                }
            }
            .frame(height: 6)
            
            HStack {
                Label(
                    goalTypeLabel(challenge.goalType),
                    systemImage: goalTypeIcon(challenge.goalType)
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                
                Spacer()
                
                if challenge.isCompleted {
                    Label(isArabic ? "مكتمل" : "Completed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.success)
                } else if challenge.daysRemaining > 0 {
                    Text("\(challenge.daysRemaining) " + (isArabic ? "يوم متبقي" : "days left"))
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(challenge.isCompleted ? AppColors.success : themeManager.textSecondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    func goalTypeLabel(_ type: String) -> String {
        if !isArabic {
            return type.capitalized.replacingOccurrences(of: "_", with: " ")
        }
        switch type {
        case "steps": return "خطوات"
        case "workouts": return "تمارين"
        case "calories": return "سعرات"
        case "exercise_count": return "عدد التمارين"
        case "water": return "ماء"
        case "meals": return "وجبات"
        default: return type
        }
    }
    
    func goalTypeIcon(_ type: String) -> String {
        switch type {
        case "steps": return "figure.walk"
        case "workouts": return "dumbbell.fill"
        case "calories": return "flame.fill"
        case "exercise_count": return "number"
        case "water": return "drop.fill"
        case "meals": return "fork.knife"
        default: return "target"
        }
    }
}
