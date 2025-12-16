import SwiftUI
import AVKit

struct PhysioExerciseRow: View {
    let exercise: PhysioExercise
    let isArabic: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @State private var showVideo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(isArabic ? exercise.nameAr : exercise.nameEn)
                    .font(.subheadline.bold())

                Spacer()

                if exercise.videoURL != nil {
                    Button {
                        showVideo = true
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                            .foregroundColor(themeManager.primary)
                    }
                }
            }

            if let instructions = isArabic ? exercise.instructionsAr : exercise.instructionsEn {
                Text(instructions)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
        .padding()
        .background(themeManager.cardBackground)
        .cornerRadius(14)
        .sheet(isPresented: $showVideo) {
            if let urlString = exercise.videoURL,
               let url = URL(string: urlString) {
                VideoPlayer(player: AVPlayer(url: url))
            }
        }
    }
}
