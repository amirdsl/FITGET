//
//  SubscriptionPaywallView.swift
//  FITGET
//
//  Path: FITGET/Views/Subscriptions/SubscriptionPaywallView.swift
//

import SwiftUI

struct SubscriptionPaywallView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var playerProgress: PlayerProgress

    // باقات FITGET الأساسية (٦ أسابيع / ٩٠ يوم / ٦ شهور / ١٢ شهر)
    private let plans: [FGSubscriptionPlan] = [
        FGSubscriptionPlan(
            tier: .pro,
            duration: .monthly,           // نستخدم شهر كقيمة تقريبية، لكن النص يوضح ٦ أسابيع
            priceInCents: 21000,          // 210 ريال
            isBestValue: false
        ),
        FGSubscriptionPlan(
            tier: .pro,
            duration: .threeMonths,       // ٩٠ يوم
            priceInCents: 37800,          // 378 ريال
            isBestValue: false
        ),
        FGSubscriptionPlan(
            tier: .pro,
            duration: .sixMonths,
            priceInCents: 67200,          // 672 ريال
            isBestValue: false
        ),
        FGSubscriptionPlan(
            tier: .pro,
            duration: .yearly,
            priceInCents: 109200,         // 1092 ريال
            isBestValue: true
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    headerSection

                    VStack(spacing: 16) {
                        ForEach(Array(plans.enumerated()), id: \.element.id) { index, plan in
                            subscriptionCard(for: plan, index: index)
                        }
                    }
                    .padding(.horizontal)

                    footerSection
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("باقة FITGET بريميوم")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("إغلاق") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("طوّر مستواك مع FITGET")
                .font(.title2.bold())

            Text("اختر الخطة اللي تناسب هدفك، وافتح كل التمارين، التغذية، التحديات، والمجتمع والتدريب الأونلاين.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private func subscriptionCard(for plan: FGSubscriptionPlan, index: Int) -> some View {
        let ui = uiInfo(for: plan, index: index)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(ui.title)
                            .font(.headline)

                        if ui.isBestValue {
                            Text("الأكثر توفيراً")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }

                    Text(ui.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if let original = ui.originalPriceText {
                        Text(original)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .strikethrough()
                    }

                    Text(ui.discountedPriceText)
                        .font(.title3.bold())

                    if let discountLabel = ui.discountLabel {
                        Text(discountLabel)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(8)
                    }
                }
            }

            if !ui.benefits.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(ui.benefits, id: \.self) { benefit in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text(benefit)
                                .font(.footnote)
                        }
                    }
                }
                .padding(.top, 4)
            }

            Button {
                handleSelect(plan: plan)
            } label: {
                Text("اختـر الباقة")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)

        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }

    private var footerSection: some View {
        VStack(spacing: 4) {
            Text("يمكنك البدء كمستخدم مجاني في أي وقت، والترقية لاحقاً لبريميوم.")
                .font(.footnote)
                .foregroundColor(.secondary)

            Text("بريميوم يفتح: المجتمع الكامل، التحديات الجماعية، البرامج المدفوعة، والتدريب الأونلاين مع المدربين.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.top, 16)
    }

    // MARK: - Helpers

    private func handleSelect(plan: FGSubscriptionPlan) {
        // هنا لاحقاً ممكن تربطه مع StoreKit / شراء حقيقي
        subscriptionStore.applySubscription(plan: plan)
        dismiss()
    }

    private func uiInfo(for plan: FGSubscriptionPlan, index: Int) -> (title: String,
                                                                     subtitle: String,
                                                                     originalPriceText: String?,
                                                                     discountedPriceText: String,
                                                                     discountLabel: String?,
                                                                     benefits: [String],
                                                                     isBestValue: Bool) {

        switch index {
        case 0:
            // ٦ أسابيع
            return (
                title: "خطة الـ ٦ أسابيع",
                subtitle: "لبداية قوية وسريعة، نتائج ملحوظة في وقت قصير.",
                originalPriceText: "٧٠٠ ريال",
                discountedPriceText: "٢١٠ ريال",
                discountLabel: "خصم ٧٠٪",
                benefits: [
                    "برنامج تمارين مكثف للجيم أو المنزل لمدة ٦ أسابيع.",
                    "نظام غذائي بسيط يساعدك تبدأ بدون تعقيد.",
                    "تحديات قصيرة المدى لرفع حماسك والتزامك.",
                    "فتح كامل للتطبيق خلال مدة الخطة."
                ],
                isBestValue: false
            )
        case 1:
            // ٩٠ يوم
            return (
                title: "تحدي الـ ٩٠ يوم",
                subtitle: "لكل من قرر يغيّر جسمه وحياته خلال ٣ شهور.",
                originalPriceText: "١٢٦٠ ريال",
                discountedPriceText: "٣٧٨ ريال",
                discountLabel: "خصم ٧٠٪",
                benefits: [
                    "خطة تمرين متدرجة ترفع قوتك ولياقتك بشكل ملحوظ.",
                    "نظام غذائي مصمم لفترة التحدي مع تحديث حسب تقدمك.",
                    "دخول لتحديات يومية وأسبوعية داخل المجتمع.",
                    "XP و Coins إضافية عند إكمال التحدي بالكامل."
                ],
                isBestValue: false
            )
        case 2:
            // ٦ شهور
            return (
                title: "خطة الـ ٦ شهور",
                subtitle: "أنسب اختيار لبناء عادة مستمرة وتغيير حقيقي.",
                originalPriceText: "٢٢٤٠ ريال",
                discountedPriceText: "٦٧٢ ريال",
                discountLabel: "خصم ٧٠٪",
                benefits: [
                    "برنامج تمارين طويل المدى من مستوى سهل لمتقدم.",
                    "نظام غذائي مرن مع خيارات وجبات تناسبك.",
                    "متابعة مستمرة من فريق FITGET داخل التطبيق.",
                    "وصول كامل للتحديات والبرامج الجاهزة والمخصصة."
                ],
                isBestValue: false
            )
        default:
            // ١٢ شهر
            return (
                title: "خطة الـ ١٢ شهر",
                subtitle: "للي حاب يعيش أسلوب حياة رياضي مع FITGET طول السنة.",
                originalPriceText: "٣٦٤٠ ريال",
                discountedPriceText: "١٠٩٢ ريال",
                discountLabel: "خصم ٧٠٪",
                benefits: [
                    "فتح كامل للتطبيق طوال السنة (تمارين، تغذية، تحديات، مجتمع).",
                    "تطوير البرامج والغذاء حسب تقدمك كل فترة.",
                    "وصول دائم للتدريب الأونلاين مع المدربين داخل التطبيق.",
                    "أكبر قيمة مقابل السعر مع مكافآت XP و Coins موسمية."
                ],
                isBestValue: true
            )
        }
    }
}

#Preview {
    SubscriptionPaywallView()
        .environmentObject(FGSubscriptionStore())
        .environmentObject(PlayerProgress())
}
