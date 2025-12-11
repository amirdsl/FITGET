//
//  GuestTrialEntryView.swift
//  FITGET
//

import SwiftUI

struct GuestTrialEntryView: View {

    // MARK: - Environment

    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    // MARK: - Callbacks

    var onLoginSelected: (() -> Void)?
    var onSignupSelected: (() -> Void)?
    var onGuestStarted: (() -> Void)?

    // MARK: - Localized Strings

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    private var titleText: String {
        isArabic ? "مرحبًا بك في FITGET" : "Welcome to FITGET"
    }

    private var subtitleText: String {
        isArabic
        ? "اختر الطريقة الأنسب للبدء"
        : "Choose how you’d like to start"
    }

    private var guestTitle: String {
        isArabic ? "الدخول كضيف" : "Continue as guest"
    }

    private var guestDescription: String {
        if isArabic {
            return "يمكنك استكشاف أغلب المزايا الأساسية مجانًا بدون إنشاء حساب، ثم الترقية أو إنشاء حساب في أي وقت."
        } else {
            return "You can explore most of the core features for free without creating an account, then upgrade or create an account any time."
        }
    }

    private var upgradeHint: String {
        if isArabic {
            return "يمكنك الترقية لاحقًا للحصول على خطط مخصصة، متابعة تقدم متقدمة، ومحتوى حصري."
        } else {
            return "You can upgrade later to unlock personalized plans, advanced tracking, and exclusive content."
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background gradient based on theme
            LinearGradient(
                colors: [
                    themeManager.primary.opacity(0.95),
                    themeManager.primary.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 32)

                VStack(spacing: 20) {
                    headerSection
                    mainCard
                }
                .padding(.horizontal, 20)

                Spacer()

                Text(upgradeHint)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(titleText)
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(subtitleText)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
    }

    private var mainCard: some View {
        VStack(spacing: 20) {
            authButtonsSection
            guestSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.cardBackground.opacity(themeManager.isDarkMode ? 0.95 : 0.98))
                .shadow(radius: 18, x: 0, y: 10)
        )
    }

    private var authButtonsSection: some View {
        VStack(spacing: 14) {
            Button {
                onLoginSelected?()
            } label: {
                Text(isArabic ? "تسجيل الدخول" : "Log in")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(14)
            }

            Button {
                onSignupSelected?()
            } label: {
                Text(isArabic ? "إنشاء حساب جديد" : "Create new account")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(themeManager.primary)
                    .cornerRadius(14)
            }
        }
    }

    private var guestSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "person.badge.clock.fill")
                    .font(.title3)
                    .foregroundColor(themeManager.accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text(guestTitle)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)

                    Text(guestDescription)
                        .font(.subheadline)
                        .foregroundColor(themeManager.textSecondary)
                }
            }

            Button(action: startGuestFlow) {
                HStack {
                    Text(isArabic ? "الدخول كضيف الآن" : "Start as guest")
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    Image(systemName: isArabic ? "chevron.left" : "chevron.right")
                        .font(.caption.bold())
                }
                .padding()
                .background(themeManager.cardBackground.opacity(0.9))
                .cornerRadius(14)
            }
        }
        .padding(16)
        .background(
            Color.black.opacity(themeManager.isDarkMode ? 0.35 : 0.18)
        )
        .cornerRadius(18)
    }

    // MARK: - Actions

    private func startGuestFlow() {
        // نستخدم Free role كوضع افتراضي للضيف
        subscriptionStore.startGuestTrial()
        onGuestStarted?()
    }
}

#Preview {
    GuestTrialEntryView(
        onLoginSelected: {},
        onSignupSelected: {},
        onGuestStarted: {}
    )
    .environmentObject(FGSubscriptionStore())
    .environmentObject(ThemeManager.shared)
    .environmentObject(LanguageManager.shared)
}

/*
 ----------------------------------------------------------------------
 OLD IMPLEMENTATION (kept for reference, as requested - بدون حذف الكود)
 ----------------------------------------------------------------------

//
//  GuestTrialEntryView.swift
//  FITGET
//

import SwiftUI

struct GuestTrialEntryView_Old_Backup: View {

    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @StateObject private var guestManager = GuestTrialManager()

    var onLoginSelected: (() -> Void)?
    var onSignupSelected: (() -> Void)?
    var onGuestStarted: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("مرحبًا بك في FITGET")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text("اختر طريقة البدء المناسبة لك")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                Button {
                    onLoginSelected?()
                } label: {
                    Text("تسجيل الدخول")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    onSignupSelected?()
                } label: {
                    Text("إنشاء حساب جديد")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("أو جرّب التطبيق كضيف")
                    .font(.headline)

                if guestManager.isGuestActive {
                    Text("متبقّي \(guestManager.remainingDays) يوم من فترة الدخول كضيف.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("يمكنك تجربة الأساسيات كضيف لفترة محدودة.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Button(action: startGuestFlow) {
                    HStack {
                        Text("الدخول كضيف الآن")
                        Spacer()
                        Image(systemName: "chevron.left")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 6)
            )

            Spacer()

            Text("يمكنك الترقية إلى الباقات المدفوعة في أي وقت.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
        .onAppear {
            guestManager.update(from: subscriptionStore.state)
        }
    }

    private func startGuestFlow() {
        subscriptionStore.startGuestTrial()
        guestManager.update(from: subscriptionStore.state)
        onGuestStarted?()
    }
}

*/
