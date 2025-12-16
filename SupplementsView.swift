//
//  SupplementsView.swift
//  FITGET
//

import SwiftUI

struct SupplementsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var supplements: [Supplement] = []
    @State private var isLoading = false
    @State private var error: String?

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                } else if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    List {
                        ForEach(supplements) { supp in
                            SupplementRow(supplement: supp, isArabic: isArabic)
                                .listRowBackground(themeManager.cardBackground)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(isArabic ? "المكملات والفيتامينات" : "Supplements")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await loadData()
                }
            }
        }
    }

    private func loadData() async {
        isLoading = true
        error = nil
        do {
            supplements = try await NutritionRepository.shared.fetchSupplements()
        } catch {
            self.error = isArabic ? "فشل تحميل البيانات" : "Failed to load data"
        }
        isLoading = false
    }
}

private struct SupplementRow: View {
    let supplement: Supplement
    let isArabic: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? supplement.nameAr : supplement.nameEn)
                .font(.headline)
            if let desc = isArabic ? supplement.descriptionAr : supplement.descriptionEn {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            if let benefits = isArabic ? supplement.benefitsAr : supplement.benefitsEn {
                Text(benefits)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    SupplementsView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(ThemeManager.shared)
}
