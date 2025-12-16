//
//  PhysioSmartStartView.swift
//  FITGET
//

import SwiftUI

struct PhysioSmartStartView: View {

    let bodyArea: String
    let difficulty: String?

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var isLoading = false
    @State private var selectedProgram: PhysioProgram?
    @State private var showProgram = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        VStack(spacing: 16) {

            Button {
                Task { await loadSmartProgram() }
            } label: {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(isArabic ? "ابدأ برنامج مناسب لي" : "Start recommended program")
                            .font(.subheadline.bold())
                    }
                    Spacer()
                }
                .padding()
                .background(themeManager.primary)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(isLoading)

            NavigationLink(
                destination: destinationView,
                isActive: $showProgram
            ) {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        if let program = selectedProgram {
            PhysioProgramDetailView(
                program: program,
                physioService: PhysioRemoteService.shared
            )
        }
    }

    // MARK: - Logic

    private func loadSmartProgram() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let program = try await SupabaseManager.shared
                .fetchSmartPhysioProgram(
                    bodyArea: bodyArea,
                    difficulty: difficulty
                )

            selectedProgram = program
            showProgram = true

        } catch {
            print("❌ Smart program error:", error)
        }
    }
}
