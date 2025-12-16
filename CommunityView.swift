//
//  CommunityView.swift
//  FITGET
//

import SwiftUI

struct CommunityView: View {

    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var playerProgress: PlayerProgress

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // بيانات تجريبية للمنشورات – موديل محلي مختلف عن CommunityPost
    private let samplePosts: [CommunityFeedPost] = [
        CommunityFeedPost(
            id: UUID(),
            userName: "FITGET Team",
            isCoach: true,
            timeTextAR: "منذ ٣ ساعات",
            timeTextEN: "3h ago",
            contentAR: "أخبرنا: ما هو أكبر تحدي تواجهه حاليًا في التمرين أو التغذية؟ 👀",
            contentEN: "Tell us: what's your biggest challenge right now in training or nutrition? 👀",
            likes: 32,
            comments: 14
        ),
        CommunityFeedPost(
            id: UUID(),
            userName: "Ahmed",
            isCoach: false,
            timeTextAR: "منذ يوم",
            timeTextEN: "1d ago",
            contentAR: "اليوم أكملت ١٠٠٠٠ خطوة لأول مرة من فترة طويلة 💪",
            contentEN: "Today I finally hit 10,000 steps again after a long time 💪",
            likes: 18,
            comments: 5
        ),
        CommunityFeedPost(
            id: UUID(),
            userName: "Sara",
            isCoach: false,
            timeTextAR: "منذ ساعتين",
            timeTextEN: "2h ago",
            contentAR: "جرّبت برنامج حرق الدهون في البيت، التمرين الثالث كان نار 😅",
            contentEN: "Tried the home fat loss program, workout 3 was 🔥",
            likes: 24,
            comments: 9
        )
    ]

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    statsRow
                    actionsRow
                    feedHeader

                    LazyVStack(spacing: 14) {
                        ForEach(samplePosts) { post in
                            CommunityPostCard(
                                post: post,
                                isArabic: isArabic,
                                themeManager: themeManager
                            )
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(isArabic ? "المجتمع" : "Community")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            themeManager.primary,
                            themeManager.accent
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.14), radius: 14, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 70, height: 70)

                        Image(systemName: "person.3.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(isArabic ? "مجتمع FITGET" : "FITGET Community")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)

                        Text(
                            isArabic
                            ? "شارك تقدمك، اسأل الأسئلة، وتحفّز مع الآخرين في نفس الرحلة."
                            : "Share your progress, ask questions and stay motivated with others on the same journey."
                        )
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    Label {
                        Text(isArabic ? "مناسب لكل المستويات" : "For all levels")
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                    }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.22))
                    .clipShape(Capsule())

                    Label {
                        Text(isArabic ? "احترام متبادل" : "Respectful space")
                    } icon: {
                        Image(systemName: "hand.raised.fill")
                    }
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

    // MARK: - Stats row

    private var statsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                CommunityStatCard(
                    title: isArabic ? "مستواك" : "Your level",
                    value: "Lv \(playerProgress.currentLevel)",
                    icon: "bolt.fill",
                    gradient: LinearGradient(
                        colors: [Color.purple, Color.indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                CommunityStatCard(
                    title: isArabic ? "منشوراتك" : "Your posts",
                    value: "0",           // لاحقًا من الـ backend
                    icon: "square.and.pencil",
                    gradient: LinearGradient(
                        colors: [Color.blue, Color.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                CommunityStatCard(
                    title: isArabic ? "تفاعلات" : "Reactions",
                    value: "0",           // لاحقًا من الـ backend
                    icon: "heart.fill",
                    gradient: LinearGradient(
                        colors: [Color.red, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Actions row

    private var actionsRow: some View {
        HStack(spacing: 12) {
            Button {
                // TODO: فتح شاشة كتابة منشور جديد (NewPostView)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.pencil")
                    Text(isArabic ? "اكتب منشور" : "Write a post")
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(themeManager.primary)
                .foregroundColor(.white)
                .cornerRadius(18)
            }

            Button {
                // TODO: الذهاب لتحديات جماعية
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.3.sequence.fill")
                    Text(isArabic ? "تحديات جماعية" : "Group challenges")
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(themeManager.cardBackground)
                .foregroundColor(themeManager.textPrimary)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }

            Spacer()
        }
    }

    private var feedHeader: some View {
        HStack {
            Text(isArabic ? "آخر المنشورات" : "Latest posts")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            Spacer()
        }
    }
}

// MARK: - Local feed model (مختلف عن CommunityPost الأساسي)

struct CommunityFeedPost: Identifiable {
    let id: UUID
    let userName: String
    let isCoach: Bool
    let timeTextAR: String
    let timeTextEN: String
    let contentAR: String
    let contentEN: String
    let likes: Int
    let comments: Int
}

// MARK: - Subviews

struct CommunityStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 190, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(gradient)
                .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 6)
        )
    }
}

struct CommunityPostCard: View {
    let post: CommunityFeedPost
    let isArabic: Bool
    let themeManager: ThemeManager

    private var timeText: String {
        isArabic ? post.timeTextAR : post.timeTextEN
    }

    private var contentText: String {
        isArabic ? post.contentAR : post.contentEN
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(themeManager.primary.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Text(String(post.userName.prefix(1)))
                        .font(.headline.weight(.bold))
                        .foregroundColor(themeManager.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.userName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(themeManager.textPrimary)

                        if post.isCoach {
                            Text(isArabic ? "مدرب" : "Coach")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(themeManager.primary.opacity(0.1))
                                .foregroundColor(themeManager.primary)
                                .clipShape(Capsule())
                        }
                    }

                    Text(timeText)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }

                Spacer()
            }

            Text(contentText)
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("\(post.likes)")
                }
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble.fill")
                    Text("\(post.comments)")
                }

                Spacer()

                Button {
                    // TODO: فتح تفاصيل المنشور / التعليقات
                } label: {
                    Text(isArabic ? "عرض التفاصيل" : "View details")
                        .font(.caption)
                        .foregroundColor(themeManager.primary)
                }
            }
            .font(.caption)

            Divider()
                .padding(.top, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    NavigationStack {
        CommunityView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(AuthenticationManager.shared)
            .environmentObject(PlayerProgress())
    }
}
