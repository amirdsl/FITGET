//
//  PhysioSectionSelectionView.swift
//  FITGET
//

import SwiftUI

struct PhysioSectionSelectionView: View {

    @ObservedObject var physioService: PhysioRemoteService

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private let sections: [(id: String, ar: String, en: String)] = [
        ("knee", "الركبة", "Knee"),
        ("shoulder", "الكتف", "Shoulder"),
        ("back", "الظهر", "Back"),
        ("ankle", "الكاحل", "Ankle")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sections, id: \.id) { section in
                    NavigationLink {
                        PhysioProgramsListView(
                            bodyArea: section.id,
                            physioService: physioService
                        )
                    } label: {
                        sectionCard(section)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(isArabic ? "أقسام التأهيل" : "Rehab Sections")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionCard(_ section: (id: String, ar: String, en: String)) -> some View {
        HStack {
            Text(isArabic ? section.ar : section.en)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(themeManager.textSecondary)
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(16)
    }
}
