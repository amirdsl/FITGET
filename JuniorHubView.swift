//
//  JuniorHubView.swift
//  FITGET
//
//  مركز الناشئين (٧–١٧ سنة)
//

import SwiftUI

enum JuniorAgeGroup: String, CaseIterable, Identifiable {
    case kids   // 7–12
    case teens  // 13–17

    var id: String { rawValue }

    func title(isArabic: Bool) -> String {
        switch self {
        case .kids:
            return isArabic ? "٧–١٢ سنة" : "7–12 yrs"
        case .teens:
            return isArabic ? "١٣–١٧ سنة" : "13–17 yrs"
        }
    }

    func label(isArabic: Bool) -> String {
        switch self {
        case .kids:
            return isArabic ? "ناشئين صغار" : "Young juniors"
        case .teens:
            return isArabic ? "ناشئين كبار" : "Older juniors"
        }
    }
}

struct JuniorProgram: Identifiable {
    enum Focus {
        case funFitness, fundamentals, strength, sportSkills
    }

    let id = UUID()
    let ageGroup: JuniorAgeGroup
    let focus: Focus

    let titleAR: String
    let titleEN: String
    let descriptionAR: String
    let descriptionEN: String

    let sessionsPerWeek: Int
    let durationWeeks: Int
    let isFree: Bool
    let levelTagAR: String
    let levelTagEN: String
    let systemIcon: String
}

extension JuniorProgram {
    static let samplePrograms: [JuniorProgram] = [
        JuniorProgram(
            ageGroup: .kids,
            focus: .funFitness,
            titleAR: "ألعاب حركة ممتعة في البيت",
            titleEN: "Fun movement games at home",
            descriptionAR: "٣ جلسات أسبوعياً تتضمن قفز، توازن، ورميات خفيفة تناسب الأطفال.",
            descriptionEN: "3 sessions/week of jumps, balance games and light throws for kids.",
            sessionsPerWeek: 3,
            durationWeeks: 4,
            isFree: true,
            levelTagAR: "مستوى عام",
            levelTagEN: "All levels",
            systemIcon: "gamecontroller.fill"
        ),
        JuniorProgram(
            ageGroup: .kids,
            focus: .fundamentals,
            titleAR: "أساسيات الحركة والرشاقة",
            titleEN: "Fundamental movement & agility",
            descriptionAR: "تمارين بسيطة لتعليم القفز الصحيح، الجري، تغيير الاتجاه، وتمرينات للرشاقة.",
            descriptionEN: "Simple drills teaching proper jumping, running, change of direction and agility.",
            sessionsPerWeek: 2,
            durationWeeks: 6,
            isFree: false,
            levelTagAR: "أساسي",
            levelTagEN: "Fundamental",
            systemIcon: "figure.run"
        ),
        JuniorProgram(
            ageGroup: .teens,
            focus: .strength,
            titleAR: "قوة للجسم كامل بدون معدات",
            titleEN: "Full body strength (no equipment)",
            descriptionAR: "٤ جلسات أسبوعية باستخدام وزن الجسم، معدّل خصيصاً للمراهقين.",
            descriptionEN: "4 sessions/week using bodyweight only, tailored for teenagers.",
            sessionsPerWeek: 4,
            durationWeeks: 6,
            isFree: true,
            levelTagAR: "مبتدئ–متوسط",
            levelTagEN: "Beg–Int",
            systemIcon: "figure.strengthtraining.traditional"
        ),
        JuniorProgram(
            ageGroup: .teens,
            focus: .sportSkills,
            titleAR: "سرعة ورشاقة لكرة القدم (ناشئين)",
            titleEN: "Speed & agility for football juniors",
            descriptionAR: "٣ جلسات أسبوعية لتحسين الجري السريع، التسارع، والرشاقة بالكرة وبدون.",
            descriptionEN: "3 sessions/week to improve acceleration, sprinting and agility with/without the ball.",
            sessionsPerWeek: 3,
            durationWeeks: 8,
            isFree: false,
            levelTagAR: "رياضي",
            levelTagEN: "Sport",
            systemIcon: "soccerball"
        )
    ]
}

struct JuniorHubView: View {

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    @State private var selectedAgeGroup: JuniorAgeGroup = .kids
    @State private var showPaywall: Bool = false
    @State private var showComingSoonAlert: Bool = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var isPremium: Bool {
        subscriptionStore.state.isSubscriptionActive
    }

    // برامج حسب الفئة العمرية
    private var filteredPrograms: [JuniorProgram] {
        JuniorProgram.samplePrograms.filter { $0.ageGroup == selectedAgeGroup }
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    ageSelector
                    infoStrip
                    programsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(isArabic ? "مركز الناشئين" : "Juniors hub")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        }
        .alert(isPresented: $showComingSoonAlert) {
            Alert(
                title: Text(isArabic ? "قريباً" : "Coming soon"),
                message: Text(
                    isArabic
                    ? "في النسخة الكاملة سيتم ربط هذه البرامج بتتبع كامل وتمارين مفصلة مع الفيديو."
                    : "In the full version these programs will be linked to full tracking and detailed video workouts."
                ),
                dismissButton: .default(Text(isArabic ? "حسناً" : "OK"))
            )
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primary, themeManager.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 7)

            VStack(alignment: .leading, spacing: 10) {
                Text(isArabic ? "بداية صحيحة للجيل الجديد" : "A strong start for the next generation")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                Text(
                    isArabic
                    ? "برامج خاصة للفئات من ٧–١٢ سنة ومن ١٣–١٧ سنة، تركّز على المتعة، اللياقة، وأساسيات الحركة والرياضة."
                    : "Special programs for ages 7–12 and 13–17 focusing on fun, fitness and fundamental sport skills."
                )
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 8) {
                    Label(isArabic ? "ألعاب وتمارين ممتعة" : "Fun & playful", systemImage: "face.smiling.fill")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.22))
                        .clipShape(Capsule())

                    Label(isArabic ? "مناسب للبيت أو النادي" : "Home or club", systemImage: "house.and.flag.fill")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.22))
                        .clipShape(Capsule())
                }
                .foregroundColor(.white)
            }
            .padding(16)
        }
    }

    // MARK: - Age selector

    private var ageSelector: some View {
        HStack(spacing: 10) {
            ForEach(JuniorAgeGroup.allCases) { group in
                let selected = (group == selectedAgeGroup)
                Button {
                    selectedAgeGroup = group
                } label: {
                    VStack(spacing: 2) {
                        Text(group.title(isArabic: isArabic))
                            .font(.subheadline.weight(.bold))
                        Text(group.label(isArabic: isArabic))
                            .font(.caption2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selected ? themeManager.primary : themeManager.cardBackground)
                    )
                    .foregroundColor(selected ? .white : themeManager.textPrimary)
                    .shadow(color: .black.opacity(selected ? 0.12 : 0), radius: 4, x: 0, y: 2)
                }
            }

            Spacer()
        }
    }

    // MARK: - Info strip

    private var infoStrip: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(themeManager.primary)

            Text(
                isArabic
                ? "ينصح بإشراف ولي الأمر أو المدرب أثناء أداء التمارين للفئات الصغيرة."
                : "Parental or coach supervision is recommended for younger athletes."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)

            Spacer()
        }
        .padding(10)
        .background(themeManager.cardBackground)
        .cornerRadius(14)
    }

    // MARK: - Programs

    private var programsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "برامج مقترحة" : "Suggested programs")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(spacing: 12) {
                ForEach(filteredPrograms) { program in
                    JuniorProgramCard(
                        program: program,
                        isArabic: isArabic,
                        isPremiumUser: isPremium,
                        themeManager: themeManager,
                        onPremiumRequested: { showPaywall = true },
                        onStart: { showComingSoonAlert = true }
                    )
                }
            }
        }
    }
}

struct JuniorProgramCard: View {
    let program: JuniorProgram
    let isArabic: Bool
    let isPremiumUser: Bool
    let themeManager: ThemeManager
    let onPremiumRequested: () -> Void
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(themeManager.primary.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: program.systemIcon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(themeManager.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? program.titleAR : program.titleEN)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.textPrimary)
                        .lineLimit(2)

                    Text(isArabic ? program.descriptionAR : program.descriptionEN)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .lineLimit(3)
                }

                Spacer()
            }

            HStack(spacing: 8) {
                pill(text: "\(program.sessionsPerWeek)x / \(program.durationWeeks)w")
                pill(text: isArabic ? program.levelTagAR : program.levelTagEN)

                if program.isFree {
                    pill(text: isArabic ? "مجاني" : "Free", isAccent: true)
                } else {
                    pill(text: isArabic ? "بريميوم" : "Premium", isAccent: true)
                }

                Spacer()
            }

            Button {
                if !program.isFree && !isPremiumUser {
                    onPremiumRequested()
                } else {
                    onStart()
                }
            } label: {
                HStack {
                    Spacer()
                    Text(isArabic ? "عرض الخطة" : "View plan")
                        .font(.caption.bold())
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(themeManager.primary)
                .foregroundColor(.white)
                .cornerRadius(14)
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 7, x: 0, y: 4)
    }

    private func pill(text: String, isAccent: Bool = false) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isAccent ? themeManager.primary.opacity(0.12) : themeManager.secondaryBackground)
            )
            .foregroundColor(isAccent ? themeManager.primary : themeManager.textSecondary)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        JuniorHubView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
