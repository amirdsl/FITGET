//
//  WorkoutLogView.swift
//  FITGET
//

import SwiftUI

struct WorkoutLogView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var logManager = WorkoutLogManager.shared
    
    @State private var exerciseName: String = ""
    @State private var sets: String = "3"
    @State private var reps: String = "10"
    @State private var weight: String = "20"
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 16) {
                formSection
                
                Divider()
                    .background(themeManager.cardBackground)
                    .padding(.horizontal)
                
                logListSection
            }
            .padding(.top, 12)
        }
        .navigationTitle(isArabic ? "سجل الأوزان والعدّات" : "Workout log")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    // MARK: - Form
    
    private var formSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "إضافة تمرين" : "Add exercise")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                HStack {
                    TextField(isArabic ? "اسم التمرين" : "Exercise name",
                              text: $exerciseName)
                        .textInputAutocapitalization(.words)
                        .padding(10)
                        .background(themeManager.cardBackground)
                        .cornerRadius(14)
                }
                
                HStack(spacing: 10) {
                    numberField(title: isArabic ? "مجاميع" : "Sets", text: $sets)
                    numberField(title: isArabic ? "عدّات" : "Reps", text: $reps)
                    numberField(title: isArabic ? "وزن" : "Weight", text: $weight, unit: "kg")
                }
                
                Button(action: addEntryTapped) {
                    Text(isArabic ? "إضافة للسجل" : "Add to log")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryBlue)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                }
                .disabled(!canAddEntry)
                .opacity(canAddEntry ? 1 : 0.5)
            }
            .padding(.horizontal)
        }
    }
    
    private func numberField(title: String, text: Binding<String>, unit: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            HStack {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                if let unit {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
            }
            .padding(8)
            .background(themeManager.cardBackground)
            .cornerRadius(14)
        }
    }
    
    private var canAddEntry: Bool {
        !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(sets) != nil &&
        Int(reps) != nil &&
        Double(weight) != nil
    }
    
    private func addEntryTapped() {
        guard let s = Int(sets),
              let r = Int(reps),
              let w = Double(weight)
        else { return }
        
        WorkoutLogManager.shared.addEntry(
            exerciseName: exerciseName.trimmingCharacters(in: .whitespaces),
            sets: s,
            reps: r,
            weight: w
        )
        
        // إعادة التهيئة البسيطة
        exerciseName = ""
    }
    
    // MARK: - Log list
    
    private var logListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isArabic ? "السجل الأخير" : "Recent log")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                Spacer()
                Text("\(logManager.entries.count)")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            .padding(.horizontal)
            
            if logManager.entries.isEmpty {
                Spacer()
                Text(isArabic
                     ? "لم تُضِف أي تمرين بعد."
                     : "You haven’t logged any workout yet.")
                .font(.footnote)
                .foregroundColor(themeManager.textSecondary)
                Spacer()
            } else {
                List {
                    ForEach(logManager.entries) { entry in
                        WorkoutLogRow(entry: entry)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteRows)
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    private func deleteRows(at offsets: IndexSet) {
        for index in offsets {
            let entry = logManager.entries[index]
            logManager.removeEntry(entry)
        }
    }
}

// MARK: - Row

struct WorkoutLogRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    let entry: WorkoutLogManager.WorkoutEntry
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.exerciseName)
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.textPrimary)
                Spacer()
                Text(dateText)
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            HStack(spacing: 12) {
                Label("\(entry.sets) x \(entry.reps)",
                      systemImage: "repeat")
                Label(String(format: "%.1f kg", entry.weight),
                      systemImage: "dumbbell.fill")
            }
            .font(.caption2)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        WorkoutLogView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
