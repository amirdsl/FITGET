//
//  OnlineCoachingView.swift
//  FITGET
//
//  شاشة المدرب الشخصي (Online Coaching + Chat + Plan)
//

import SwiftUI

// MARK: - MAIN VIEW

struct OnlineCoachingView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var showPaywall = false
    @State private var showRequestAlert = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var isPremium: Bool {
        subscriptionStore.state.isSubscriptionActive
    }

    private let mainCoach = CoachProfile.mainCoach
    private let coachingPackages = CoachingPackage.allPackages
    private let checkIns = CoachingCheckIn.recentCheckIns

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerCard

                    if !isPremium {
                        lockedBanner
                    } else {
                        coachSection
                        planSectionLink
                        progressSection
                        checkinsSection
                        packagesSection
                        howItWorksSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(isArabic ? "المدرب الشخصي" : "Online coaching")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        }
        .alert(isPresented: $showRequestAlert) {
            Alert(
                title: Text(isArabic ? "تم إرسال طلب الاهتمام" : "Request received"),
                message: Text(
                    isArabic
                    ? "سيتم في النسخة الكاملة إرسال طلبك لفريق FITGET وتوصيله لأقرب مدرب مناسب لك عبر البريد أو الواتساب المسجل في الحساب."
                    : "In the full version your request will be sent to the FITGET team and matched with a suitable coach using your account email / WhatsApp."
                ),
                dismissButton: .default(Text(isArabic ? "تم" : "OK"))
            )
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primary, themeManager.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 70, height: 70)

                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(isArabic ? "مدربك الشخصي أونلاين" : "Your online personal coach")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)

                        Text(
                            isArabic
                            ? "خطة تمرين وتغذية مخصصة + مراجعة أسبوعية ورسائل مباشرة مع المدرب."
                            : "Custom training & nutrition plan + weekly check-ins and direct messages with your coach."
                        )
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Lv \(playerProgress.currentLevel)")
                            .font(.subheadline.weight(.heavy))
                            .foregroundColor(.white)

                        Text(PlayerRankTitle.title(for: playerProgress.currentLevel))
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.16))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 8) {
                    Label {
                        Text(isArabic ? "متابعة أسبوعية" : "Weekly follow-up")
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                    }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.22))
                    .clipShape(Capsule())

                    Label {
                        Text(isArabic ? "خطة مخصصة لهدفك" : "Goal-based plan")
                    } icon: {
                        Image(systemName: "target")
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

    // MARK: - Locked banner

    private var lockedBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? "الميزة متاحة مع بريميوم" : "Available with Premium")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.textPrimary)

                    Text(
                        isArabic
                        ? "فعّل FITGET Premium للحصول على مدرب شخصي ومتابعة أسبوعية وخطة مخصصة لهدفك."
                        : "Activate FITGET Premium to get a personal coach, weekly follow-up and a custom plan built for your goal."
                    )
                    .font(.footnote)
                    .foregroundColor(themeManager.textSecondary)
                }

                Spacer()
            }

            Button {
                showPaywall = true
            } label: {
                HStack {
                    Spacer()
                    Text(isArabic ? "عرض الباقات" : "View premium plans")
                        .font(.subheadline.bold())
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(themeManager.primary)
                .foregroundColor(.white)
                .cornerRadius(18)
            }
        }
        .padding(14)
        .background(themeManager.cardBackground)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - Coach section

    private var coachSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "مدرب FITGET المقترح لك" : "Suggested FITGET coach for you")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            CoachProfileCard(coach: mainCoach, isArabic: isArabic, themeManager: themeManager)

            Button {
                showRequestAlert = true
            } label: {
                HStack {
                    Spacer()
                    Text(isArabic ? "إرسال طلب اهتمام" : "Send coaching request")
                        .font(.subheadline.bold())
                    Spacer()
                }
                .padding(.vertical, 11)
                .background(themeManager.primary)
                .foregroundColor(.white)
                .cornerRadius(20)
            }

            // نموذج الهدف والحالة الصحية
            NavigationLink {
                CoachingQuestionnaireView(isArabic: isArabic)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                    Text(isArabic ? "نموذج الهدف والحالة الصحية" : "Goal & health questionnaire")
                }
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(themeManager.cardBackground)
                .foregroundColor(themeManager.textPrimary)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(themeManager.primary.opacity(0.25), lineWidth: 1)
                )
            }

            // الشات مع المدرب
            NavigationLink {
                CoachingChatView(coach: mainCoach, isArabic: isArabic)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text(isArabic ? "فتح الشات مع المدرب" : "Open chat with coach")
                }
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(themeManager.cardBackground)
                .foregroundColor(themeManager.textPrimary)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(themeManager.primary.opacity(0.25), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Plan overview link

    private var planSectionLink: some View {
        NavigationLink {
            CoachingPlanOverviewView(isArabic: isArabic)
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? "خطة التدريب والتغذية" : "Training & nutrition plan")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.textPrimary)

                    Text(
                        isArabic
                        ? "ملخص الخطة الحالية حسب الهدف، التمرين، والسعرات."
                        : "Summary of your current block: training split & calories."
                    )
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                }

                Spacer()

                Image(systemName: isArabic ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.primary)
            }
            .padding(12)
            .background(themeManager.cardBackground)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }

    // MARK: - Progress section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "ماذا سيتابع المدرب؟" : "What will your coach track?")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(spacing: 10) {
                progressItem(
                    icon: "flame.fill",
                    titleAR: "التقدم في التمرين والسعرات",
                    titleEN: "Training & calorie progress",
                    detailAR: "تحميل الأوزان، عدد الجلسات، الالتزام بالسعرات والماكروز.",
                    detailEN: "Load progression, weekly sessions and adherence to calories/macros."
                )

                progressItem(
                    icon: "heart.fill",
                    titleAR: "الحالة الصحية والنوم",
                    titleEN: "Health & recovery",
                    detailAR: "معدل النبض، جودة النوم، مستوى الإرهاق قبل التمرين.",
                    detailEN: "Heart rate, sleep quality and fatigue level before workouts."
                )

                progressItem(
                    icon: "message.fill",
                    titleAR: "تقييم أسبوعي ورسائل",
                    titleEN: "Weekly review & messaging",
                    detailAR: "تقرير أسبوعي مختصر + توصيات واضحة لكل أسبوع.",
                    detailEN: "Short weekly report with clear recommendations for the next week."
                )
            }
            .padding(12)
            .background(themeManager.cardBackground)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }

    private func progressItem(icon: String,
                              titleAR: String,
                              titleEN: String,
                              detailAR: String,
                              detailEN: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(themeManager.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? titleAR : titleEN)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)

                Text(isArabic ? detailAR : detailEN)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    // MARK: - Check-ins section

    private var checkinsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "آخر المتابعات الأسبوعية" : "Recent weekly check-ins")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            if checkIns.isEmpty {
                Text(
                    isArabic
                    ? "ستظهر هنا تقارير المتابعة عندما تبدأ اشتراكك مع المدرب."
                    : "Your weekly review reports will appear here once you start coaching."
                )
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(checkIns) { checkIn in
                        CoachingCheckInRow(checkIn: checkIn, isArabic: isArabic, themeManager: themeManager)
                    }
                }
                .padding(10)
                .background(themeManager.cardBackground)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
            }

            // زر إضافة Check-in جديد
            NavigationLink {
                WeeklyCheckInFormView(isArabic: isArabic)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text(isArabic ? "إضافة متابعة أسبوعية جديدة" : "Add new weekly check-in")
                }
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(themeManager.cardBackground)
                .foregroundColor(themeManager.textPrimary)
                .cornerRadius(14)
            }
        }
    }

    // MARK: - Packages section

    private var packagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isArabic ? "باقات التدريب أونلاين" : "Online coaching packages")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(spacing: 12) {
                ForEach(coachingPackages) { pack in
                    CoachingPackageCard(
                        package: pack,
                        isArabic: isArabic,
                        themeManager: themeManager,
                        onSelect: { showPaywall = true }
                    )
                }
            }
        }
    }

    // MARK: - How it works

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "كيف يعمل نظام المدرب الشخصي؟" : "How does online coaching work?")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(alignment: .leading, spacing: 10) {
                howStep(
                    index: 1,
                    ar: "تملأ استبيان الهدف ومستوى اللياقة والحالة الصحية.",
                    en: "You fill a short form about your goal, fitness level and health status."
                )
                howStep(
                    index: 2,
                    ar: "يطلع المدرب على بياناتك ويرسم خطة تمرين وتغذية أولية لـ ٤ أسابيع.",
                    en: "Your coach reviews your data and builds your first 4-week training & nutrition block."
                )
                howStep(
                    index: 3,
                    ar: "كل أسبوع ترسل تحديث الوزن، الصور، وملاحظاتك في التطبيق.",
                    en: "Each week you submit weight, photos and notes directly inside the app."
                )
                howStep(
                    index: 4,
                    ar: "المدرب يرسل لك تقرير وتعديلات على الخطة حسب التزامك وتقدمك.",
                    en: "The coach replies with a review and adjusts your plan based on progress."
                )
            }
            .padding(12)
            .background(themeManager.cardBackground)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 3)
        }
    }

    private func howStep(index: Int, ar: String, en: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(themeManager.primary.opacity(0.12))
                    .frame(width: 26, height: 26)
                Text("\(index)")
                    .font(.caption.bold())
                    .foregroundColor(themeManager.primary)
            }

            Text(isArabic ? ar : en)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

// MARK: - CHAT TYPES & VIEW

struct CoachingChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isFromCoach: Bool
    let timestamp: Date
}

struct CoachingChatView: View {
    let coach: CoachProfile
    let isArabic: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @State private var messages: [CoachingChatMessage] = CoachingChatView.sampleMessages
    @State private var draft: String = ""

    private var sortedMessages: [CoachingChatMessage] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(themeManager.primary.opacity(0.15))
                        .frame(width: 38, height: 38)
                    Image(systemName: coach.avatarSystemImage)
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(coach.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(themeManager.textPrimary)
                    Text(isArabic ? "متصل غالباً خلال أوقات العمل" : "Usually replies during working hours")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(themeManager.cardBackground)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(sortedMessages) { message in
                            CoachingChatBubble(message: message, isArabic: isArabic, themeManager: themeManager)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .onAppear {
                    if let lastID = sortedMessages.last?.id {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
                .onChange(of: messages.count) { _ in
                    if let lastID = sortedMessages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                TextField(
                    isArabic ? "اكتب رسالتك هنا..." : "Write your message...",
                    text: $draft,
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)

                Button {
                    send()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(isArabic ? -45 : 45))
                        .padding(8)
                        .background(themeManager.primary)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(themeManager.backgroundColor)
        }
        .navigationTitle(isArabic ? "مراسلة المدرب" : "Chat with coach")
        .navigationBarTitleDisplayMode(.inline)
        .background(themeManager.backgroundColor.ignoresSafeArea())
    }

    private func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let msg = CoachingChatMessage(text: trimmed, isFromCoach: false, timestamp: Date())
        messages.append(msg)
        draft = ""
    }

    static let sampleMessages: [CoachingChatMessage] = [
        CoachingChatMessage(
            text: "مرحباً، سأكون المدرب المسؤول عن متابعتك 👋",
            isFromCoach: true,
            timestamp: Date().addingTimeInterval(-3600)
        ),
        CoachingChatMessage(
            text: "أرسل لي وزنك الحالي، طولك، وأهم هدف تحب نركز عليه.",
            isFromCoach: true,
            timestamp: Date().addingTimeInterval(-3500)
        ),
        CoachingChatMessage(
            text: "أهلاً كابتن! هدفي إنقاص وزن مع الحفاظ على العضل.",
            isFromCoach: false,
            timestamp: Date().addingTimeInterval(-3400)
        )
    ]
}

struct CoachingChatBubble: View {
    let message: CoachingChatMessage
    let isArabic: Bool
    let themeManager: ThemeManager

    var body: some View {
        HStack {
            if message.isFromCoach {
                bubble
                Spacer()
            } else {
                Spacer()
                bubble
            }
        }
    }

    private var bubble: some View {
        Text(message.text)
            .font(.caption)
            .padding(10)
            .foregroundColor(message.isFromCoach ? themeManager.textPrimary : .white)
            .background(
                message.isFromCoach
                ? themeManager.cardBackground
                : themeManager.primary
            )
            .cornerRadius(14)
            .frame(maxWidth: 260, alignment: message.isFromCoach ? .leading : .trailing)
    }
}

// MARK: - SUBVIEWS + MODELS

struct CoachProfileCard: View {
    let coach: CoachProfile
    let isArabic: Bool
    let themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(themeManager.primary.opacity(0.14))
                    .frame(width: 60, height: 60)
                Image(systemName: coach.avatarSystemImage)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(themeManager.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(coach.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)

                Text(isArabic ? coach.specialityAR : coach.specialityEN)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)

                HStack(spacing: 6) {
                    Label("\(String(format: "%.1f", coach.rating))", systemImage: "star.fill")
                    Label("\(coach.yearsExperience) \(isArabic ? "سنوات خبرة" : "years exp.")", systemImage: "briefcase.fill")
                    Label("\(coach.clientsCount)+", systemImage: "person.3.fill")
                }
                .font(.caption2)
                .foregroundColor(themeManager.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct CoachingPackageCard: View {
    let package: CoachingPackage
    let isArabic: Bool
    let themeManager: ThemeManager
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isArabic ? package.titleAR : package.titleEN)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)
                Spacer()
                Text(package.priceFormatted)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(themeManager.primary)
            }

            Text(isArabic ? package.subtitleAR : package.subtitleEN)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(isArabic ? package.bulletsAR : package.bulletsEN, id: \.self) { bullet in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text(bullet)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(themeManager.primary.opacity(0.06))
                        .cornerRadius(10)
                    }
                }
            }

            Button {
                onSelect()
            } label: {
                HStack {
                    Spacer()
                    Text(isArabic ? "اختيار هذه الباقة" : "Select this package")
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
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct CoachingCheckInRow: View {
    let checkIn: CoachingCheckIn
    let isArabic: Bool
    let themeManager: ThemeManager

    private var weekText: String {
        isArabic ? "أسبوع \(checkIn.weekNumber)" : "Week \(checkIn.weekNumber)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(weekText)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(themeManager.textPrimary)

                Text(isArabic ? checkIn.summaryAR : checkIn.summaryEN)
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                    Text("\(checkIn.weightDeltaKg > 0 ? "+" : "")\(String(format: "%.1f", checkIn.weightDeltaKg)) kg")
                }
                .font(.caption2)
                .foregroundColor(checkIn.weightDeltaKg <= 0 ? .green : .orange)

                Text(isArabic ? checkIn.focusAR : checkIn.focusEN)
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            }
        }
        .padding(8)
        .background(themeManager.secondaryBackground.opacity(0.6))
        .cornerRadius(12)
    }
}

// MARK: - MODELS

struct CoachProfile {
    let name: String
    let specialityAR: String
    let specialityEN: String
    let rating: Double
    let yearsExperience: Int
    let clientsCount: Int
    let avatarSystemImage: String

    static let mainCoach = CoachProfile(
        name: "Coach Ahmed",
        specialityAR: "تخسيس و بناء عضل للرجال والنساء",
        specialityEN: "Fat loss & muscle gain for men and women",
        rating: 4.9,
        yearsExperience: 8,
        clientsCount: 230,
        avatarSystemImage: "person.crop.circle.fill.badge.checkmark"
    )
}

struct CoachingPackage: Identifiable {
    let id = UUID()
    let titleAR: String
    let titleEN: String
    let subtitleAR: String
    let subtitleEN: String
    let bulletsAR: [String]
    let bulletsEN: [String]
    let priceSAR: Double
    let durationWeeks: Int

    var priceFormatted: String {
        String(format: "SAR %.0f / %d w", priceSAR, durationWeeks)
    }

    static let allPackages: [CoachingPackage] = [
        CoachingPackage(
            titleAR: "متابعة أساسية ٤ أسابيع",
            titleEN: "Essential 4-week coaching",
            subtitleAR: "خطة تمرين وغذاء + متابعة أسبوعية بالتقارير.",
            subtitleEN: "Training & nutrition plan + weekly written check-ins.",
            bulletsAR: ["خطة تمرين في البيت أو النادي", "خطة سعرات وماكروز مبسطة", "تقرير أسبوعي مكتوب"],
            bulletsEN: ["Home or gym training plan", "Simple calories & macros plan", "Weekly written check-in"],
            priceSAR: 249,
            durationWeeks: 4
        ),
        CoachingPackage(
            titleAR: "متابعة مكثفة ٨ أسابيع",
            titleEN: "Intensive 8-week coaching",
            subtitleAR: "لمن يريد تغيير واضح في ٨ أسابيع مع تعديل مستمر للخطة.",
            subtitleEN: "For visible changes in 8 weeks with continuous plan adjustments.",
            bulletsAR: ["تعديل الخطة كل ٢–٣ أسابيع", "ردود على الأسئلة خلال أيام العمل", "متابعة للحالة الصحية والنوم"],
            bulletsEN: ["Plan updates every 2–3 weeks", "Answers to questions on weekdays", "Health & sleep monitoring"],
            priceSAR: 449,
            durationWeeks: 8
        ),
        CoachingPackage(
            titleAR: "تحويل جسم ١٢ أسبوع",
            titleEN: "12-week body transformation",
            subtitleAR: "أفضل خيار لمن يريد نظام كامل وتغيير جذري تحت متابعة دقيقة.",
            subtitleEN: "Best for full system & serious transformation with close monitoring.",
            bulletsAR: ["خطة مفصلة ٣ مراحل", "تعديل أسبوعي إذا لزم", "أولوية في الرد على الرسائل"],
            bulletsEN: ["3-phase detailed plan", "Weekly adjustments if needed", "Priority in message replies"],
            priceSAR: 649,
            durationWeeks: 12
        )
    ]
}

struct CoachingCheckIn: Identifiable {
    let id = UUID()
    let weekNumber: Int
    let summaryAR: String
    let summaryEN: String
    let focusAR: String
    let focusEN: String
    let weightDeltaKg: Double

    static let recentCheckIns: [CoachingCheckIn] = [
        CoachingCheckIn(
            weekNumber: 1,
            summaryAR: "التزام ممتاز بالتمرين، متوسط في التغذية. نحتاج رفع البروتين قليلاً.",
            summaryEN: "Great training adherence, average nutrition. Need to increase protein slightly.",
            focusAR: "التركيز هذا الأسبوع على النوم ووجبة بعد التمرين.",
            focusEN: "Focus this week on sleep and post-workout meal.",
            weightDeltaKg: -0.7
        ),
        CoachingCheckIn(
            weekNumber: 2,
            summaryAR: "الوزن ثابت لكن المقاسات أفضل. سنزيد الكارديو الخفيف ١٥ دقيقة بعد تمرينين.",
            summaryEN: "Scale weight stable but measurements improved. Adding 15 min light cardio after two sessions.",
            focusAR: "التركيز على الحركة اليومية خارج التمرين.",
            focusEN: "Focus on daily movement outside workouts.",
            weightDeltaKg: -0.2
        )
    ]
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OnlineCoachingView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
            .environmentObject(AuthenticationManager.shared)
    }
}
