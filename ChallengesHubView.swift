//
//  ChallengesHubView.swift
//  FITGET
//

import SwiftUI
import Combine   // 👈 مهم لعلاج ObservableObject / ObservedObject

// MARK: - ChallengesRemoteService (طبقة بين الواجهة و SupabaseManager)

@MainActor
final class ChallengesRemoteService: ObservableObject {

    static let shared = ChallengesRemoteService()

    @Published var availableChallenges: [DBChallenge] = []
    @Published var joinedChallengeIds: Set<UUID> = []
    @Published var isLoading: Bool = false
    @Published var lastError: String?

    /// نحتفظ بالـ ChallengeV2 الأصلي حتى نستخدمه في join / leave
    private var rawChallenges: [UUID: ChallengeV2] = [:]

    /// مؤقتاً: user ثابت (يفضل لاحقاً أخذه من Auth)
    private let dummyUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    private init() {}

    // بيانات تجريبية في حال فشل الاتصال
    private var fallbackChallenges: [DBChallenge] {
        [
            DBChallenge(
                id: UUID(),
                titleAr: "تحدي 10,000 خطوة يومياً",
                titleEn: "10,000 Steps Daily",
                descriptionAr: "حافظ على نشاطك بالمشي اليومي لمدة أسبوعين.",
                descriptionEn: "Stay active by walking every day for two weeks.",
                durationDays: 14,
                targetValue: 10000,
                isPublic: true
            ),
            DBChallenge(
                id: UUID(),
                titleAr: "تحدي 3 تمارين أسبوعياً",
                titleEn: "3 Workouts per Week",
                descriptionAr: "التزم بـ 3 تمارين على الأقل كل أسبوع.",
                descriptionEn: "Commit to at least 3 workouts per week.",
                durationDays: 30,
                targetValue: 12,
                isPublic: true
            )
        ]
    }

    // تحميل التحديات من Supabase (مع fallback محلي)
    func loadChallenges() async {
        isLoading = true
        lastError = nil

        defer {
            isLoading = false
        }

        do {
            let result = try await SupabaseManager.shared
                .fetchChallengesWithParticipation(for: dummyUserId)

            // حفظ الموديل الخام
            rawChallenges = Dictionary(
                uniqueKeysWithValues: result.map { ($0.0.id, $0.0) }
            )

            // تحويل ChallengeV2 -> DBChallenge
            let mapped: [DBChallenge] = result.map { tuple in
                let ch = tuple.0

                let days = max(
                    1,
                    Calendar.current.dateComponents(
                        [.day],
                        from: ch.start_date,
                        to: ch.end_date
                    ).day ?? 1
                )

                return DBChallenge(
                    id: ch.id,
                    titleAr: ch.name_ar,
                    titleEn: ch.name_en,
                    descriptionAr: ch.description_ar,
                    descriptionEn: ch.description_en,
                    durationDays: days,
                    targetValue: Double(ch.goal_value),
                    isPublic: !ch.is_premium
                )
            }

            availableChallenges = mapped.isEmpty ? fallbackChallenges : mapped
            joinedChallengeIds = Set(result.compactMap { $0.1?.challenge_id })
        } catch {
            lastError = error.localizedDescription
            if availableChallenges.isEmpty {
                availableChallenges = fallbackChallenges
            }
        }
    }

    func join(challengeId: UUID) async {
        do {
            if let challenge = rawChallenges[challengeId] {
                try await SupabaseManager.shared.joinChallenge(challenge, userId: dummyUserId)
            }
            joinedChallengeIds.insert(challengeId)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func leave(challengeId: UUID) async {
        do {
            if let challenge = rawChallenges[challengeId] {
                try await SupabaseManager.shared.leaveChallenge(challenge, userId: dummyUserId)
            }
            joinedChallengeIds.remove(challengeId)
        } catch {
            lastError = error.localizedDescription
        }
    }
}

// MARK: - ChallengesHubView

struct ChallengesHubView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var playerProgress: PlayerProgress

    // الخدمة الجديدة
    @ObservedObject private var backend = ChallengesRemoteService.shared

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    statsRow
                    availableChallengesSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }

            if backend.isLoading {
                Color.black.opacity(0.05).ignoresSafeArea()
                ProgressView()
            }
        }
        .navigationTitle(isArabic ? "التحديات" : "Challenges")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await backend.loadChallenges()
        }
        .alert(isPresented: Binding(
            get: { backend.lastError != nil },
            set: { _ in backend.lastError = nil }
        )) {
            Alert(
                title: Text(isArabic ? "خطأ" : "Error"),
                message: Text(backend.lastError ?? ""),
                dismissButton: .default(Text(isArabic ? "حسناً" : "OK"))
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 8) {
            Text(isArabic ? "ارفع حماسك بالتحديات" : "Boost your motivation with challenges")
                .font(.title3.bold())
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "انضم لتحديات حرق الدهون، عدد الخطوات، أو استمرارية التمرين واحصل على XP إضافي."
                : "Join challenges for fat loss, steps or workout consistency and earn extra XP."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity,
               alignment: isArabic ? .trailing : .leading)
    }

    // MARK: - Stats cards

    private var statsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                statCard(
                    titleAR: "XP الحالي",
                    titleEN: "Current XP",
                    value: "\(playerProgress.currentXP)",
                    gradient: [Color.orange, Color.red],
                    systemIcon: "bolt.fill"
                )

                statCard(
                    titleAR: "تحديات نشطة",
                    titleEN: "Active challenges",
                    value: "\(backend.joinedChallengeIds.count)",
                    gradient: [Color.green, Color.teal],
                    systemIcon: "checkmark.seal.fill"
                )

                statCard(
                    titleAR: "مستوى اللاعب",
                    titleEN: "Player level",
                    value: "Lv \(playerProgress.currentLevel)",
                    gradient: [Color.purple, Color.pink],
                    systemIcon: "star.fill"
                )
            }
        }
    }

    private func statCard(
        titleAR: String,
        titleEN: String,
        value: String,
        gradient: [Color],
        systemIcon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: systemIcon)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            Text(isArabic ? titleAR : titleEN)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 170, alignment: .leading)
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    // MARK: - List of challenges

    private var availableChallengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "تحديات متاحة" : "Available challenges")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            if backend.availableChallenges.isEmpty {
                Text(isArabic ? "لا يوجد تحديات حالياً." : "No challenges available right now.")
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(backend.availableChallenges) { challenge in
                    ChallengesHubCardView(
                        challenge: challenge,
                        isArabic: isArabic,
                        isJoined: backend.joinedChallengeIds.contains(challenge.id),
                        onToggleJoin: {
                            Task {
                                if backend.joinedChallengeIds.contains(challenge.id) {
                                    await backend.leave(challengeId: challenge.id)
                                } else {
                                    await backend.join(challengeId: challenge.id)
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Card component

struct ChallengesHubCardView: View {
    let challenge: DBChallenge
    let isArabic: Bool
    let isJoined: Bool
    let onToggleJoin: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    private var title: String {
        isArabic ? challenge.titleAr : challenge.titleEn
    }

    private var descriptionText: String {
        if isArabic {
            return challenge.descriptionAr ?? ""
        } else {
            return challenge.descriptionEn ?? ""
        }
    }

    private var durationText: String {
        if isArabic {
            return "\(challenge.durationDays) يوم"
        } else {
            return "\(challenge.durationDays) days"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: "target")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.orange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                        .lineLimit(2)

                    if !descriptionText.isEmpty {
                        Text(descriptionText)
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()
            }

            HStack(spacing: 8) {
                chip(icon: "clock", text: durationText)
                chip(
                    icon: "flame.fill",
                    text: isArabic
                        ? "هدف \(Int(challenge.targetValue))"
                        : "Target \(Int(challenge.targetValue))"
                )
                chip(icon: "globe", text: isArabic ? "عام" : "Public")
                Spacer()
            }

            HStack {
                Button(action: onToggleJoin) {
                    Text(
                        isJoined
                        ? (isArabic ? "مغادرة التحدي" : "Leave challenge")
                        : (isArabic ? "ابدأ التحدي" : "Join challenge")
                    )
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isJoined ? Color.gray.opacity(0.2) : Color.orange)
                    .foregroundColor(isJoined ? themeManager.textPrimary : .white)
                    .cornerRadius(18)
                }

                Spacer()
            }
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func chip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
        .foregroundColor(themeManager.textSecondary)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChallengesHubView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(PlayerProgress())
            .environmentObject(ThemeManager.shared)
    }
}
