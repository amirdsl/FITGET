//
//  SportsPerformanceHubView.swift
//  FITGET
//

import SwiftUI

// MARK: - Local models (prefixed SP لتفادي التعارض)

enum SPSportType: String, CaseIterable, Identifiable {
    case football
    case basketball
    case running
    case combat
    case athletics

    var id: String { rawValue }

    func title(isArabic: Bool) -> String {
        switch self {
        case .football:
            return isArabic ? "كرة قدم" : "Football"
        case .basketball:
            return isArabic ? "كرة سلة" : "Basketball"
        case .running:
            return isArabic ? "جري ولياقة" : "Running & conditioning"
        case .combat:
            return isArabic ? "ألعاب قتالية" : "Combat sports"
        case .athletics:
            return isArabic ? "ألعاب قوى" : "Athletics"
        }
    }

    func iconName() -> String {
        switch self {
        case .football:   return "soccerball"
        case .basketball: return "basketball"
        case .running:    return "figure.run"
        case .combat:     return "figure.boxing"
        case .athletics:  return "medal.fill"
        }
    }
}

struct SPSportProgramCard: Identifiable {
    let id = UUID()
    let sport: SPSportType
    let levelTagAR: String
    let levelTagEN: String
    let titleAR: String
    let titleEN: String
    let focusAR: String
    let focusEN: String
    let durationWeeks: Int
    let sessionsPerWeek: Int
}

struct SportsPerformanceHubView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    @State private var selectedSport: SPSportType = .football

    private var programs: [SPSportProgramCard] {
        [
            SPSportProgramCard(
                sport: .football,
                levelTagAR: "مبتدئ",
                levelTagEN: "Beginner",
                titleAR: "أساسيات لياقة لاعب كرة القدم",
                titleEN: "Footballer base conditioning",
                focusAR: "تحمل، تغيير اتجاه، قوة أساسية.",
                focusEN: "Endurance, change of direction, core strength.",
                durationWeeks: 6,
                sessionsPerWeek: 3
            ),
            SPSportProgramCard(
                sport: .football,
                levelTagAR: "متوسط",
                levelTagEN: "Intermediate",
                titleAR: "تسارع وسرعة كرة القدم",
                titleEN: "Football acceleration & speed",
                focusAR: "انطلاقات، جري متقطع، رشاقة مع الكرة.",
                focusEN: "Sprints, repeated efforts, with-ball agility.",
                durationWeeks: 6,
                sessionsPerWeek: 3
            ),
            SPSportProgramCard(
                sport: .basketball,
                levelTagAR: "متوسط",
                levelTagEN: "Intermediate",
                titleAR: "رشاقة وقفز كرة السلة",
                titleEN: "Basketball agility & vertical jump",
                focusAR: "قفزات، تغيير اتجاه، قوة أرجل.",
                focusEN: "Jumping, cutting, leg power.",
                durationWeeks: 6,
                sessionsPerWeek: 3
            ),
            SPSportProgramCard(
                sport: .running,
                levelTagAR: "مبتدئ",
                levelTagEN: "Beginner",
                titleAR: "من المبتدئ إلى 5K",
                titleEN: "Beginner to 5K",
                focusAR: "بناء تحمل تدريجي حتى 5 كيلومتر.",
                focusEN: "Progressive build-up to 5K.",
                durationWeeks: 8,
                sessionsPerWeek: 3
            ),
            SPSportProgramCard(
                sport: .combat,
                levelTagAR: "متقدم",
                levelTagEN: "Advanced",
                titleAR: "لياقة قتال للملاكمة / الكيك بوكسينج",
                titleEN: "Fight conditioning (boxing / kickboxing)",
                focusAR: "جولات عالية الشدة، تحمل عضلي وتنفس.",
                focusEN: "High-intensity rounds, muscular & cardio endurance.",
                durationWeeks: 8,
                sessionsPerWeek: 4
            ),
            SPSportProgramCard(
                sport: .athletics,
                levelTagAR: "متوسط",
                levelTagEN: "Intermediate",
                titleAR: "سرعة 100–200 متر",
                titleEN: "100–200m sprint speed",
                focusAR: "انطلاق، تسارع، تقنية جري.",
                focusEN: "Start, acceleration, sprint mechanics.",
                durationWeeks: 6,
                sessionsPerWeek: 3
            )
        ]
    }

    private var filteredPrograms: [SPSportProgramCard] {
        programs.filter { $0.sport == selectedSport }
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    sportChips
                    programList
                    infoSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(isArabic ? "تطوير أداء الرياضة" : "Sports performance")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primary, themeManager.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 70, height: 70)

                    Image(systemName: "sportscourt")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(isArabic ? "برامج تحسين أداء الرياضيين" : "Performance programs for athletes")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)

                    Text(
                        isArabic
                        ? "اختر رياضتك المفضلة للحصول على برامج تركّز على السرعة، الرشاقة، التحمل والقوة الخاصة بكل لعبة."
                        : "Pick your sport to access programs focused on the speed, agility, endurance and power demands of that game."
                    )
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(16)
        }
    }

    // MARK: - Sport chips

    private var sportChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SPSportType.allCases) { sport in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSport = sport
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: sport.iconName())
                            Text(sport.title(isArabic: isArabic))
                        }
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    sport == selectedSport
                                    ? themeManager.primary
                                    : themeManager.cardBackground
                                )
                        )
                        .foregroundColor(
                            sport == selectedSport
                            ? .white
                            : themeManager.textPrimary
                        )
                        .shadow(
                            color: .black.opacity(sport == selectedSport ? 0.12 : 0.03),
                            radius: sport == selectedSport ? 6 : 3,
                            x: 0, y: sport == selectedSport ? 4 : 2
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Program list

    private var programList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(
                isArabic
                ? "برامج \(selectedSport.title(isArabic: true))"
                : "\(selectedSport.title(isArabic: false)) programs"
            )
            .font(.headline)
            .foregroundColor(themeManager.textPrimary)

            if filteredPrograms.isEmpty {
                Text(
                    isArabic
                    ? "سيتم إضافة برامج لهذه الرياضة قريباً."
                    : "Programs for this sport will be added soon."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(filteredPrograms) { program in
                        sportsProgramCard(program)
                    }
                }
            }
        }
    }

    private func sportsProgramCard(_ program: SPSportProgramCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isArabic ? program.titleAR : program.titleEN)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Text(isArabic ? program.levelTagAR : program.levelTagEN)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.primary.opacity(0.08))
                    .foregroundColor(themeManager.primary)
                    .clipShape(Capsule())
            }

            Text(isArabic ? program.focusAR : program.focusEN)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)

            HStack(spacing: 10) {
                Label("\(program.durationWeeks) \(isArabic ? "أسابيع" : "weeks")",
                      systemImage: "calendar")
                Label("\(program.sessionsPerWeek)x / \(isArabic ? "أسبوع" : "week")",
                      systemImage: "figure.run")
            }
            .font(.caption2)
            .foregroundColor(themeManager.textSecondary)

            Text(
                isArabic
                ? "في النسخة الكاملة سيتم ربط هذه البرامج مباشرة بجداول التمارين داخل قاعدة البيانات مع تمييز لكل رياضة ومستوى."
                : "In the full version these programs will be linked to your actual workouts in the database, tagged by sport and level."
            )
            .font(.caption2)
            .foregroundColor(themeManager.textSecondary.opacity(0.8))
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isArabic ? "للناشئين والكبار" : "For youth & adults")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "يمكن لاحقاً ربط هذه البرامج بقسم الناشئين بحيث يكون لكل فئة عمرية نسخة مناسبة من برنامج مهارات الرياضة المفضلة."
                : "Later these programs can be mirrored inside the youth section with age-appropriate versions of each sport-specific plan."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
    }
}

#Preview {
    NavigationStack {
        SportsPerformanceHubView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
