//
//  WorkoutTimerView.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import SwiftUI
import Combine

struct WorkoutTimerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var isRunning: Bool = false
    @State private var isRestPhase: Bool = false
    @State private var remainingSeconds: Int = 45
    @State private var workDuration: Int = 45
    @State private var restDuration: Int = 60
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    private var phaseTitle: String {
        if isRestPhase {
            return isArabic ? "راحة" : "Rest"
        } else {
            return isArabic ? "تمرين" : "Work"
        }
    }
    
    private var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(phaseTitle)
                    .font(.title2.bold())
                    .foregroundColor(themeManager.textPrimary)
                
                ZStack {
                    Circle()
                        .strokeBorder(
                            themeManager.cardBackground,
                            lineWidth: 14
                        )
                        .frame(width: 220, height: 220)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AppColors.primaryBlue,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 220, height: 220)
                        .animation(.easeInOut(duration: 0.25), value: progress)
                    
                    VStack {
                        Text(formattedTime)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.textPrimary)
                        Text(isArabic ? "الوقت المتبقي" : "Remaining")
                            .font(.footnote)
                            .foregroundColor(themeManager.textSecondary)
                    }
                }
                
                HStack(spacing: 20) {
                    durationEditor(
                        title: isArabic ? "تمرين" : "Work",
                        value: $workDuration
                    )
                    durationEditor(
                        title: isArabic ? "راحة" : "Rest",
                        value: $restDuration
                    )
                }
                
                HStack(spacing: 20) {
                    Button(action: toggleStart) {
                        HStack {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            Text(isRunning ? (isArabic ? "إيقاف مؤقت" : "Pause")
                                           : (isArabic ? "بدء" : "Start"))
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryBlue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    
                    Button(role: .destructive, action: resetTimer) {
                        Text(isArabic ? "إعادة" : "Reset")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(themeManager.cardBackground)
                            .foregroundColor(themeManager.textPrimary)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 24)
        }
        .navigationTitle(isArabic ? "مؤقت التمرين" : "Workout timer")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            guard isRunning else { return }
            tick()
        }
    }
    
    private var progress: CGFloat {
        let total = isRestPhase ? restDuration : workDuration
        guard total > 0 else { return 0 }
        return CGFloat(total - remainingSeconds) / CGFloat(total)
    }
    
    private func durationEditor(title: String, value: Binding<Int>) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(themeManager.textPrimary)
            
            HStack {
                Button {
                    if value.wrappedValue > 10 { value.wrappedValue -= 5 }
                    resetPhaseIfNeeded()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                
                Text("\(value.wrappedValue)s")
                    .font(.headline)
                    .frame(minWidth: 60)
                
                Button {
                    value.wrappedValue += 5
                    resetPhaseIfNeeded()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .foregroundColor(AppColors.primaryBlue)
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }
    
    private func toggleStart() {
        if !isRunning {
            if remainingSeconds <= 0 {
                remainingSeconds = isRestPhase ? restDuration : workDuration
            }
        }
        isRunning.toggle()
    }
    
    private func resetTimer() {
        isRunning = false
        isRestPhase = false
        remainingSeconds = workDuration
    }
    
    private func resetPhaseIfNeeded() {
        if !isRunning {
            remainingSeconds = isRestPhase ? restDuration : workDuration
        }
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            isRestPhase.toggle()
            remainingSeconds = isRestPhase ? restDuration : workDuration
            return
        }
        remainingSeconds -= 1
    }
}

#Preview {
    NavigationStack {
        WorkoutTimerView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(LanguageManager.shared)
    }
}
