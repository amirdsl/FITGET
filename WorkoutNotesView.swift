//
//  WorkoutNotesView.swift
//  FITGET
//

import SwiftUI

struct WorkoutNotesView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var notes: String = ""
    
    var isArabic: Bool { languageManager.currentLanguage == "ar" }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(isArabic ? "ملاحظات التمرين" : "Workout Notes")
                .font(.title3.bold())
                .padding(.top)
            
            TextEditor(text: $notes)
                .frame(maxHeight: .infinity)
                .padding()
                .background(themeManager.cardBackground)
                .cornerRadius(16)
            
            Button {
                saveNotes()
            } label: {
                Text(isArabic ? "حفظ" : "Save Notes")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeManager.primary)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(isArabic ? "ملاحظات" : "Notes")
    }
    
    func saveNotes() {
        UserDefaults.standard.set(notes, forKey: "workoutNotes")
    }
}

#Preview {
    NavigationStack {
        WorkoutNotesView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
