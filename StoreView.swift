//
//  StoreView.swift
//  FITGET
//
//  متجر عملات ومحتوى FITGET
//

import SwiftUI

struct StoreView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    @State private var showComingSoonAlert = false

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    coinsPacksSection
                    unlockablesSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(isArabic ? "متجر FITGET" : "FITGET Store")
        .navigationBarTitleDisplayMode(.large)
        .alert(isPresented: $showComingSoonAlert) {
            Alert(
                title: Text(isArabic ? "قريباً" : "Coming soon"),
                message: Text(
                    isArabic
                    ? "سيتم ربط المتجر ببوابات دفع حقيقية وسوبابيز لشراء العملات وفتح المزايا."
                    : "The shop will be connected to real payment providers and Supabase so you can buy coins and unlock features."
                ),
                dismissButton: .default(Text(isArabic ? "حسناً" : "OK"))
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [themeManager.primary.opacity(0.95),
                         themeManager.primary.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 150)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.12),
                    radius: 8,
                    x: 0,
                    y: 6)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(isArabic ? "عملاتك الحالية" : "Your current coins")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.85))

                        Text("\(playerProgress.totalCoins)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }

                    Spacer()
                }

                Text(
                    isArabic
                    ? "استخدم العملات لفتح برامج خاصة، تحديات مميزة، أو تخصيصات للأفاتار."
                    : "Use coins to unlock special programs, premium challenges, or avatar cosmetics."
                )
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
        }
    }

    // MARK: - Coin packs

    private var coinsPacksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "حزم العملات" : "Coin packs")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            VStack(spacing: 10) {
                ForEach(StoreCoinPack.allPacks) { pack in
                    Button {
                        // حاليًا مجرد تنبيه "قريباً"
                        showComingSoonAlert = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.yellow.opacity(0.15))
                                    .frame(width: 52, height: 52)

                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.yellow)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(isArabic ? pack.titleAR : pack.titleEN)
                                    .font(.subheadline.bold())
                                    .foregroundColor(themeManager.textPrimary)

                                Text(isArabic ? pack.subtitleAR : pack.subtitleEN)
                                    .font(.caption)
                                    .foregroundColor(themeManager.textSecondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(pack.coins) 🪙")
                                    .font(.subheadline.bold())
                                    .foregroundColor(themeManager.textPrimary)

                                Text(pack.priceFormatted)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(themeManager.cardBackground)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.04),
                                radius: 3,
                                x: 0,
                                y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Unlockables

    private var unlockablesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isArabic ? "عناصر يمكن فتحها بالعملات" : "Unlockable items with coins")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "لاحقاً سيتم ربط هذه العناصر بجداول shop_items و coin_transactions في Supabase."
                : "Later these items will be backed by shop_items and coin_transactions tables in Supabase."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)

            VStack(spacing: 10) {
                ForEach(StoreUnlockableItem.sample) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(item.color.opacity(0.12))
                                .frame(width: 52, height: 52)

                            Image(systemName: item.systemIcon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(item.color)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(isArabic ? item.titleAR : item.titleEN)
                                .font(.subheadline.bold())
                                .foregroundColor(themeManager.textPrimary)

                            Text(isArabic ? item.subtitleAR : item.subtitleEN)
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(item.costCoins) 🪙")
                                .font(.subheadline.bold())
                                .foregroundColor(themeManager.textPrimary)

                            Text(isArabic ? "قريباً" : "Soon")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .background(themeManager.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.04),
                            radius: 3,
                            x: 0,
                            y: 2)
                }
            }
        }
    }
}

// MARK: - Models (خاصة بالمتجر فقط)

struct StoreCoinPack: Identifiable {
    let id = UUID()
    let coins: Int
    let priceSAR: Double

    let titleAR: String
    let titleEN: String
    let subtitleAR: String
    let subtitleEN: String

    var priceFormatted: String {
        String(format: "SAR %.2f", priceSAR)
    }

    static let allPacks: [StoreCoinPack] = [
        StoreCoinPack(
            coins: 250,
            priceSAR: 9.99,
            titleAR: "حزمة بداية",
            titleEN: "Starter pack",
            subtitleAR: "مناسبة للتجربة وفتح بعض المزايا",
            subtitleEN: "Good for trying and unlocking a few perks"
        ),
        StoreCoinPack(
            coins: 750,
            priceSAR: 24.99,
            titleAR: "حزمة متقدمة",
            titleEN: "Advanced pack",
            subtitleAR: "تكفي لعدة برامج وتخصيصات",
            subtitleEN: "Enough for several programs and cosmetics"
        ),
        StoreCoinPack(
            coins: 2000,
            priceSAR: 59.99,
            titleAR: "حزمة محترفين",
            titleEN: "Pro pack",
            subtitleAR: "للمستخدمين الجادين في استغلال كل المزايا",
            subtitleEN: "For users who want to unlock everything"
        )
    ]
}

struct StoreUnlockableItem: Identifiable {
    let id = UUID()
    let titleAR: String
    let titleEN: String
    let subtitleAR: String
    let subtitleEN: String
    let systemIcon: String
    let color: Color
    let costCoins: Int

    static let sample: [StoreUnlockableItem] = [
        StoreUnlockableItem(
            titleAR: "برنامج تحدي ٤ أسابيع",
            titleEN: "4-week challenge program",
            subtitleAR: "برنامج مكثف مع تتبع وتحديات خاصة.",
            subtitleEN: "Intense program with extra tracking and special challenges.",
            systemIcon: "flag.2.crossed.fill",
            color: .orange,
            costCoins: 500
        ),
        StoreUnlockableItem(
            titleAR: "ثيمات خاصة للأفاتار",
            titleEN: "Special avatar themes",
            subtitleAR: "فتح أشكال وألوان مميزة للأفاتار الخاص بك.",
            subtitleEN: "Unlock unique avatar styles and colors.",
            systemIcon: "person.crop.circle.badge.checkmark",
            color: .purple,
            costCoins: 300
        ),
        StoreUnlockableItem(
            titleAR: "دخول تحديات VIP",
            titleEN: "VIP challenge access",
            subtitleAR: "اشتراك في تحديات حصرية بجوائز أكبر.",
            subtitleEN: "Access to exclusive challenges with bigger rewards.",
            systemIcon: "crown.fill",
            color: .yellow,
            costCoins: 700
        )
    ]
}

#Preview {
    NavigationStack {
        StoreView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
