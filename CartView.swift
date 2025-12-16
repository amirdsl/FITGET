//
//  CartView.swift
//  FITGET
//
//  شاشة سلة المشتريات
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    private var isArabic: Bool {
        languageManager.currentLanguage == "ar"
    }

    // حالياً السلة فارغة دائماً إلى أن يتم ربطها بالمتجر/الـ backend
    @State private var items: [CartDisplayItem] = []

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            if items.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .navigationTitle(isArabic ? "سلة المشتريات" : "Cart")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "basket")
                .font(.system(size: 46, weight: .regular))
                .foregroundColor(.secondary)

            Text(isArabic ? "السلة فارغة حالياً" : "Your cart is empty")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)

            Text(
                isArabic
                ? "عند تفعيل المتجر وربطه بالمدفوعات و Supabase، أي عنصر تضيفه سيظهر هنا تلقائيًا قبل إتمام الشراء."
                : "Once the shop is connected to payments and Supabase, any item you add will appear here before checkout."
            )
            .font(.footnote)
            .foregroundColor(themeManager.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)

            NavigationLink {
                StoreView()             // ✅ المتجر الرئيسي
            } label: {
                Text(isArabic ? "اذهب إلى المتجر" : "Go to shop")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(22)
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.top, 80)
    }

    // MARK: - Content (في حالة وجود عناصر لاحقاً)

    private var content: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(items) { item in
                        CartItemRow(item: item, isArabic: isArabic, themeManager: themeManager)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            VStack(spacing: 8) {
                HStack {
                    Text(isArabic ? "الإجمالي" : "Total")
                        .font(.subheadline)
                    Spacer()
                    Text(totalPriceText)
                        .font(.headline.bold())
                }
                .padding(.horizontal, 16)

                Button {
                    // لاحقاً: تنفيذ عملية الشراء الحقيقية من خلال Supabase + بوابة دفع
                } label: {
                    HStack {
                        Spacer()
                        Text(isArabic ? "إتمام الشراء" : "Checkout")
                            .font(.subheadline.bold())
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 16)
        }
    }

    private var totalPriceText: String {
        let sum = items.reduce(0.0) { $0 + ($1.priceSAR * Double($1.quantity)) }
        return String(format: "SAR %.2f", sum)
    }
}

// MARK: - Models (Display only – لا تستبدل CartItem الأصلي)

struct CartDisplayItem: Identifiable {
    let id = UUID()
    let titleAR: String
    let titleEN: String
    let descriptionAR: String
    let descriptionEN: String
    let priceSAR: Double
    let quantity: Int
    let systemIcon: String
}

struct CartItemRow: View {
    let item: CartDisplayItem
    let isArabic: Bool
    let themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: item.systemIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isArabic ? item.titleAR : item.titleEN)
                    .font(.subheadline.bold())
                    .foregroundColor(themeManager.textPrimary)

                Text(isArabic ? item.descriptionAR : item.descriptionEN)
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                    .lineLimit(2)

                Text("x\(item.quantity)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "SAR %.2f", item.priceSAR * Double(item.quantity)))
                .font(.subheadline.bold())
                .foregroundColor(themeManager.textPrimary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(themeManager.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        CartView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(FGSubscriptionStore())
            .environmentObject(PlayerProgress())
    }
}
