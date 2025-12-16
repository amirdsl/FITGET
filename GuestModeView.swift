//
//  GuestModeView.swift
//  FITGET
//

import SwiftUI

struct GuestModeView: View {
    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @EnvironmentObject var appAuthSession: AuthSession
    
    var onGuestStarted: () -> Void
    
    @State private var remainingDays = 7

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Welcome Section
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "ff6b6b").opacity(0.2), Color(hex: "ff8c42").opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "figure.walk")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "ff6b6b"))
                    }

                    VStack(spacing: 8) {
                        Text("جرب FITGET مجاناً")
                            .font(.system(size: 20, weight: .bold))

                        Text("استمتع بـ 7 أيام كاملة من جميع المميزات")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)

                // Trial Info
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "0091ff").opacity(0.1))
                                .frame(width: 40, height: 40)

                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "0091ff"))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("فترة تجريبية")
                                .font(.system(size: 14, weight: .semibold))
                            Text("\(remainingDays) أيام متبقية")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "00d4ff").opacity(0.1))
                                .frame(width: 40, height: 40)

                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "00d4ff"))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("جميع المميزات")
                                .font(.system(size: 14, weight: .semibold))
                            Text("وصول كامل للبرامج والتمارين")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Features List
                VStack(alignment: .leading, spacing: 12) {
                    Text("ماذا يمكنك أن تفعل؟")
                        .font(.system(size: 14, weight: .semibold))

                    VStack(spacing: 12) {
                        featureRow(title: "اختر برنامج تمرين مناسب", icon: "figure.run")
                        featureRow(title: "اتبع البرامج الموصى بها", icon: "play.circle")
                        featureRow(title: "تتبع تقدمك", icon: "chart.line.uptrend.xyaxis")
                        featureRow(title: "احصل على نصائح التغذية", icon: "fork.knife")
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Warning
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color(hex: "ffa500"))

                    Text("ستحتاج لإنشاء حساب قبل انتهاء الفترة التجريبية")
                        .font(.system(size: 12, weight: .regular))

                    Spacer()
                }
                .padding(12)
                .background(Color(hex: "ffa500").opacity(0.1))
                .cornerRadius(8)

                Spacer()
                    .frame(height: 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }

        // Action Button
        VStack(spacing: 12) {
            Button(action: {
                onGuestStarted()
            }, label: {
                Text("ابدأ التصفح")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    // تم تعديل التدرج هنا لنقاط قياسية
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "0091ff"), Color(hex: "00d4ff")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            })
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    private func featureRow(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "0091ff"))
                .frame(width: 32, height: 32)
                .background(Color(hex: "0091ff").opacity(0.1))
                .cornerRadius(8)

            Text(title)
                .font(.system(size: 14, weight: .regular))

            Spacer()
        }
    }
}

#Preview {
    GuestModeView(onGuestStarted: {})
        .environmentObject(FGSubscriptionStore())
        .environmentObject(AuthSession())
}
