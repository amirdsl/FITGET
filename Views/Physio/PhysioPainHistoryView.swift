// FILE: PhysioPainHistoryView.swift

import SwiftUI

struct PhysioPainHistoryView: View {
    let program: PhysioProgram
    let userId: UUID

    @StateObject private var viewModel = PhysioPainHistoryViewModel()

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var newPainValue: Double = 3

    private var isArabic: Bool { languageManager.currentLanguage == "ar" }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isArabic ? "سجل الألم" : "Pain history")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)

                Spacer()

                if viewModel.isLoading {
                    ProgressView().scaleEffect(0.7)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            if viewModel.logs.isEmpty && !viewModel.isLoading {
                Text(isArabic ? "لا توجد سجلات ألم بعد." : "No pain logs yet.")
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
            } else {
                ForEach(viewModel.logs.prefix(5)) { log in
                    HStack {
                        Text(dateString(for: log.loggedAt))
                            .font(.caption)
                        Spacer()
                        Text("\(log.value)/10")
                            .font(.caption.bold())
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 2)
                }
            }

            Divider().padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(isArabic ? "أضف قياساً جديداً للألم" : "Add new pain entry")
                    .font(.subheadline)
                    .foregroundColor(themeManager.textPrimary)

                HStack {
                    Slider(value: $newPainValue, in: 0...10, step: 1)
                    Text("\(Int(newPainValue))/10")
                        .font(.caption.bold())
                        .frame(width: 44, alignment: .trailing)
                }

                Button {
                    viewModel.addLog(
                        userId: userId,
                        programId: program.id,
                        bodyArea: program.bodyArea,
                        value: Int(newPainValue)
                    )
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(isArabic ? "حفظ القياس" : "Save entry")
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(themeManager.primary)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
            }
        }
        .onAppear {
            viewModel.loadLogs(userId: userId, programId: program.id)
        }
    }

    private func dateString(for date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .short
        return df.string(from: date)
    }
}
