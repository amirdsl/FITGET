//
//  HabitsTrackerView.swift
//  Fitget
//
//  Created on 20/11/2025.
//

import SwiftUI

// ✅ Struct مخصص لهذه الشاشة فقط لتفادي التعارض مع Habit في HabitsView
struct TrackerHabit: Identifiable {
    let id = UUID()
    var name: String
    var isCompleted: Bool
}

struct HabitsTrackerView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var habits: [TrackerHabit] = [
        TrackerHabit(name: "Drank 2L Water", isCompleted: true),
        TrackerHabit(name: "8 Hours Sleep", isCompleted: false),
        TrackerHabit(name: "Ate Vegetables", isCompleted: false)
    ]
    
    @State private var newHabit = ""
    
    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - Summary Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isArabic ? "تتبع عاداتك اليومية" : "Track your daily habits")
                            .font(.headline)
                        
                        Text(isArabic ? "حافظ على استمراريتك بعادات بسيطة يوميًا." :
                                "Stay consistent with small daily habits.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // MARK: - Add Habit
                    HStack {
                        TextField(isArabic ? "أضف عادة جديدة" : "Add a new habit", text: $newHabit)
                            .textFieldStyle(.roundedBorder)
                        
                        Button {
                            addHabit()
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .padding(8)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .disabled(newHabit.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    // MARK: - Habits List
                    if habits.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "checklist")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            Text(isArabic ? "لا توجد عادات بعد" : "No habits yet")
                                .font(.headline)
                            
                            Text(isArabic ? "ابدأ بإضافة عادات بسيطة لتحسين نمط حياتك." :
                                    "Start by adding simple habits to improve your lifestyle.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(habits) { habit in
                                Button {
                                    toggle(habit)
                                } label: {
                                    HStack {
                                        Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundColor(habit.isCompleted ? .green : .secondary)
                                        
                                        Text(habit.name)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .onDelete(perform: deleteHabit)
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .padding()
            }
            .navigationTitle(isArabic ? "العادات" : "Habits")
        }
    }
    
    // MARK: - Actions
    
    private func addHabit() {
        let trimmed = newHabit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let habit = TrackerHabit(name: trimmed, isCompleted: false)
        habits.append(habit)
        newHabit = ""
    }
    
    private func toggle(_ habit: TrackerHabit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
        }
    }
    
    private func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }
}

#Preview {
    HabitsTrackerView()
        .environmentObject(LanguageManager.shared)
}
