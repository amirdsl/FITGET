//
//  YouthHubView.swift
//  FITGET
//
//  مركز تدريب الناشئين (7–17)
//  شاشة تعرض فئات عمرية، رياضات، برامج مخصصة، وتحديات مرحة
//

import SwiftUI

// MARK: - Models

enum YouthAgeGroup: String, CaseIterable, Identifiable {
    case ages7to12
    case ages13to17

    var id: String { rawValue }

    func title(isArabic: Bool) -> String {
        switch self {
        case .ages7to12: return isArabic ? "٧–١٢ سنة" : "Ages 7–12"
        case .ages13to17: return isArabic ? "١٣–١٧ سنة" : "Ages 13–17"
        }
    }

    func description(isArabic: Bool) -> String {
        switch self {
        case .ages7to12:
            return isArabic ? "أساسيات الحركة، التوازن والمرح." : "Foundations: movement, balance & fun."
        case .ages13to17:
            return isArabic ? "تطوير القوة، السرعة والمهارات الرياضية." : "Develop strength, speed & sport skills."
        }
    }
}

enum SportCategory: String, CaseIterable, Identifiable {
    case football
    case basketball
    case volleyball
    case handball
    case combat
    case athletics
    case multi // general multi-sport

    var id: String { rawValue }

    func title(isArabic: Bool) -> String {
        switch self {
        case .football: return isArabic ? "كرة القدم" : "Football"
        case .basketball: return isArabic ? "كرة السلة" : "Basketball"
        case .volleyball: return isArabic ? "كرة الطائرة" : "Volleyball"
        case .handball: return isArabic ? "كرة اليد" : "Handball"
        case .combat: return isArabic ? "القتال/الفنون القتالية" : "Combat / Martial arts"
        case .athletics: return isArabic ? "ألعاب قوى" : "Athletics"
        case .multi: return isArabic ? "متعدد الرياضات" : "Multi-sport"
        }
    }

    /// systemIconName: استخدمنا رموز SF عامة قابلة للعرض؛ يمكن استبدالها بأصول مخصّصة لاحقاً
    func systemIconName() -> String {
        switch self {
        case .football: return "sportscourt"           // بديل آمن لكرة القدم
        case .basketball: return "basketball"         // متوفر في نسخ أحدث من SF
        case .volleyball: return "circle.grid.cross"  // تمثيل شبكي رمزي
        case .handball: return "figure.wave"          // تمثيل حركة / يد
        case .combat: return "shield.lefthalf.fill"
        case .athletics: return "bolt.fill"
        case .multi: return "figure.2.and.child.holdinghands"
        }
    }
}

// Program model for youth
struct YouthProgram: Identifiable {
    let id = UUID()
    let titleEn: String
    let titleAr: String
    let descriptionEn: String
    let descriptionAr: String
    let ageGroup: YouthAgeGroup
    let sport: SportCategory
    let durationWeeks: Int
    let sessionsPerWeek: Int
    let isPremiumOnly: Bool
    let iconName: String
}

// Light catalog (sample) - replace / extend with backend later
enum YouthCatalog {
    static func samplePrograms() -> [YouthProgram] {
        [
            YouthProgram(
                titleEn: "Fun Ball Skills (7–12)",
                titleAr: "مهارات الكرة المرحة (٧–١٢)",
                descriptionEn: "Basic ball handling, coordination and fun small-sided games.",
                descriptionAr: "أساسيات تحكم الكرة، التناسق ولعب مصغّر ممتع.",
                ageGroup: .ages7to12,
                sport: .football,
                durationWeeks: 6,
                sessionsPerWeek: 3,
                isPremiumOnly: false,
                iconName: SportCategory.football.systemIconName()
            ),
            YouthProgram(
                titleEn: "Youth Agility & Speed (13–17)",
                titleAr: "السرعة والرشاقة للناشئين (١٣–١٧)",
                descriptionEn: "Progressive drills to improve sprinting and change-of-direction.",
                descriptionAr: "تمارين متدرجة لرفع السرعة وتغيير الاتجاه.",
                ageGroup: .ages13to17,
                sport: .athletics,
                durationWeeks: 8,
                sessionsPerWeek: 3,
                isPremiumOnly: false,
                iconName: SportCategory.athletics.systemIconName()
            ),
            YouthProgram(
                titleEn: "Basketball Fundamentals (7–12)",
                titleAr: "أساسيات السلة (٧–١٢)",
                descriptionEn: "Dribbling, passing and simple tactical play for kids.",
                descriptionAr: "مراوغة، تمرير ولعب تكتيكي بسيط للأطفال.",
                ageGroup: .ages7to12,
                sport: .basketball,
                durationWeeks: 6,
                sessionsPerWeek: 2,
                isPremiumOnly: false,
                iconName: SportCategory.basketball.systemIconName()
            ),
            YouthProgram(
                titleEn: "Strength for Teens (13–17)",
                titleAr: "قوة للمراهقين (١٣–١٧)",
                descriptionEn: "Bodyweight & basic gym program focusing on safe progression.",
                descriptionAr: "جسم وزن وتمارين جيم مبسطة مع تقدم آمن.",
                ageGroup: .ages13to17,
                sport: .multi,
                durationWeeks: 12,
                sessionsPerWeek: 3,
                isPremiumOnly: true,
                iconName: SportCategory.multi.systemIconName()
            ),
            YouthProgram(
                titleEn: "Combat Basics for Kids (7–12)",
                titleAr: "أساسيات القتال للأطفال (٧–١٢)",
                descriptionEn: "Discipline, coordination and basic technique in a safe environment.",
                descriptionAr: "انضباط وتناسق وتقنيات أساسية في بيئة آمنة.",
                ageGroup: .ages7to12,
                sport: .combat,
                durationWeeks: 8,
                sessionsPerWeek: 2,
                isPremiumOnly: false,
                iconName: SportCategory.combat.systemIconName()
            )
        ]
    }
}

// MARK: - YouthHubView

struct YouthHubView: View {

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    @State private var selectedAgeGroup: YouthAgeGroup = .ages7to12
    @State private var selectedSport: SportCategory? = nil
    @State private var programs: [YouthProgram] = []
    @State private var showPaywall: Bool = false
    @State private var searchText: String = ""

    private var isArabic: Bool { languageManager.currentLanguage == "ar" }
    private var isPremium: Bool { subscriptionStore.state.isSubscriptionActive }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                ageAndSportFilters
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                Divider()
                    .padding(.top, 8)

                if filteredPrograms.isEmpty {
                    emptyState
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12, pinnedViews: []) {
                            ForEach(filteredPrograms) { program in
                                YouthProgramRow(
                                    program: program,
                                    isArabic: isArabic,
                                    isPremiumUser: isPremium,
                                    onJoin: { p in join(program: p) },
                                    onRequestPremium: { showPaywall = true }
                                )
                                .environmentObject(themeManager)
                                .environmentObject(playerProgress)
                                .padding(.horizontal, 12)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .navigationTitle(isArabic ? "ناشئين" : "Youth training")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPrograms()
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(isArabic ? "مركز الناشئين" : "Youth hub")
                    .font(.title2.weight(.bold))
                    .foregroundColor(themeManager.textPrimary)

                Text(isArabic
                     ? "برامج مخصصة للفئات العمرية ٧–١٧ سنة، بأولوية الأمان والتطور المرح."
                     : "Programs tailored for ages 7–17 — safe, fun and progressive."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    // Quick action: suggest free trial or help
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                        .foregroundColor(themeManager.primary)
                }

                VStack(spacing: 2) {
                    Text(isArabic ? "المستوى" : "Level")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                    Text("Lv \(playerProgress.currentLevel)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.primary)
                }
            }
        }
    }

    // MARK: - Filters (age groups + sports + search)

    private var ageAndSportFilters: some View {
        VStack(spacing: 10) {
            // Age groups
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(YouthAgeGroup.allCases) { ag in
                        Button {
                            withAnimation { selectedAgeGroup = ag }
                            selectedSport = nil
                        } label: {
                            Text(ag.title(isArabic: isArabic))
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(selectedAgeGroup == ag ? themeManager.primary : themeManager.cardBackground)
                                .foregroundColor(selectedAgeGroup == ag ? .white : themeManager.textPrimary)
                                .cornerRadius(14)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            // Sports grid (horizontal chips)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SportCategory.allCases) { sp in
                        Button {
                            withAnimation { selectedSport = (selectedSport == sp) ? nil : sp }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: sp.systemIconName())
                                    .font(.system(size: 14))
                                Text(sp.title(isArabic: isArabic))
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(selectedSport == sp ? themeManager.primary : themeManager.secondaryBackground)
                            .foregroundColor(selectedSport == sp ? .white : themeManager.textPrimary)
                            .cornerRadius(14)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Search
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeManager.textSecondary)
                    TextField(isArabic ? "ابحث عن برنامج أو رياضة" : "Search program or sport", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(10)
                .background(themeManager.cardBackground)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 40))
                .foregroundColor(themeManager.primary.opacity(0.9))

            Text(isArabic ? "لا توجد برامج متاحة" : "No programs available")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(isArabic ? "جاري تجهيز المزيد من برامج الناشئين. جرّب تغيير الفئة أو الرياضة." : "More youth programs will be added soon. Try changing category or sport.")
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Logic

    private func loadPrograms() {
        // الآن محليّا - لاحقًا استبدل بالـ backend
        programs = YouthCatalog.samplePrograms()
    }

    private var filteredPrograms: [YouthProgram] {
        var list = programs.filter { $0.ageGroup == selectedAgeGroup }

        if let sp = selectedSport {
            list = list.filter { $0.sport == sp }
        }

        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.titleEn.lowercased().contains(q) || $0.titleAr.contains(q) ||
                $0.descriptionEn.lowercased().contains(q) || $0.descriptionAr.contains(q)
            }
        }

        return list
    }

    private func join(program: YouthProgram) {
        if program.isPremiumOnly && !isPremium {
            showPaywall = true
            return
        }

        // عند الانضمام: هنا من الممكن ربط PlayerProgress أو إرسال event للـ backend
        // سنمنح الطفل بعض XP كمكافأة بسيطة (مثال)
        playerProgress.apply(event: .challengeCompleted(difficulty: 1))
        // يمكن حفظ الانضمام محليًا أو إرسال طلب للـ backend لاحقًا
    }
}

// MARK: - Row view for programs

struct YouthProgramRow: View {
    let program: YouthProgram
    let isArabic: Bool
    let isPremiumUser: Bool
    let onJoin: (YouthProgram) -> Void
    let onRequestPremium: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var playerProgress: PlayerProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.secondaryBackground)
                        .frame(width: 56, height: 56)

                    Image(systemName: program.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(themeManager.primary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(isArabic ? program.titleAr : program.titleEn)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.textPrimary)

                    Text(isArabic ? program.descriptionAr : program.descriptionEn)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(program.durationWeeks)w")
                        .font(.caption2.bold())
                        .foregroundColor(themeManager.textSecondary)

                    Text("\(program.sessionsPerWeek)x")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                }
            }

            HStack {
                if program.isPremiumOnly && !isPremiumUser {
                    Button {
                        onRequestPremium()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                            Text(isArabic ? "متاح مع بريميوم" : "Premium only")
                                .font(.caption2.bold())
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.12))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                    }
                } else {
                    Button {
                        onJoin(program)
                    } label: {
                        Text(isArabic ? "انضم الآن" : "Join now")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(themeManager.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                Spacer()

                Text(program.sport.title(isArabic: isArabic))
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(themeManager.cardBackground)
                    .cornerRadius(10)
            }
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        YouthHubView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
