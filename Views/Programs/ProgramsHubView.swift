//
//  ProgramsHubView.swift
//  FITGET
//
//  Path: FITGET/Views/Programs/ProgramsHubView.swift
//
//  ✅ ملف مُعدّل: إضافة روابط تفصيلية للبرامج
//

import SwiftUI

struct ProgramsHubView: View {

    @EnvironmentObject var subscriptionStore: FGSubscriptionStore
    @State private var showPaywall: Bool = false

    private var canUsePaidPrograms: Bool {
        FGAppAccess.canAccess(.paidPrograms, state: subscriptionStore.state)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        readyProgramsSection
                        customProgramsSection
                        paidProgramsSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())

                if !canUsePaidPrograms {
                    VStack {
                        Spacer()
                        PremiumLockOverlay(
                            title: "البرامج المدفوعة للمشتركين فقط",
                            message: "افتح برامج المدربين المتقدمة، البرامج الطويلة، وبرامج التحويل الشامل مع FITGET بريميوم.",
                            onUpgradeTapped: {
                                showPaywall = true
                            }
                        )
                    }
                }
            }
            .navigationTitle("البرامج")
            .sheet(isPresented: $showPaywall) {
                SubscriptionPaywallView()
                    .environmentObject(subscriptionStore)
            }
        }
    }

    // MARK: - Sections

    private var readyProgramsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("برامج جاهزة (مجانية)")
                .font(.headline)

            NavigationLink {
                WorkoutProgramDetailView(
                    title: "برنامج المبتدئين ٤ أسابيع",
                    description: "٣ أيام تمرين في الأسبوع، تركيز على الأساسيات للجيم أو المنزل.\n\n• اليوم ١: كامل الجسم\n• اليوم ٢: كارديو خفيف + كور\n• اليوم ٣: مقاومة خفيفة + إطالات"
                )
            } label: {
                programCard(
                    title: "برنامج المبتدئين ٤ أسابيع",
                    subtitle: "٣ أيام تمرين في الأسبوع، تركيز على الأساسيات للجيم أو المنزل.",
                    icon: "figure.strengthtraining.traditional"
                )
            }

            NavigationLink {
                WorkoutProgramDetailView(
                    title: "برنامج نزول وزن ٦ أسابيع",
                    description: "دمج تمارين مقاومة وكارديو خفيف لحرق دهون بشكل آمن.\n\n• ٤ أيام نشاط أسبوعيًا\n• خطة كارديو تدريجية\n• تتبع سعرات + خطوات"
                )
            } label: {
                programCard(
                    title: "برنامج نزول وزن ٦ أسابيع",
                    subtitle: "دمج تمارين مقاومة وكارديو خفيف لحرق دهون بشكل آمن.",
                    icon: "figure.run"
                )
            }
        }
    }

    private var customProgramsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("برامج حسب هدفك")
                .font(.headline)

            NavigationLink {
                CustomProgramWizardView()
            } label: {
                programCard(
                    title: "برنامج مخصص من التطبيق",
                    subtitle: "جاوب على بعض الأسئلة حول هدفك ومستواك، وخلّي FITGET يبني لك برنامجك.",
                    icon: "wand.and.stars.inverse"
                )
            }
        }
    }

    private var paidProgramsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("برامج المدربين (مدفوعة)")
                .font(.headline)

            if canUsePaidPrograms {
                NavigationLink {
                    WorkoutProgramDetailView(
                        title: "برنامج تحويل ٩٠ يوم مع كابتن أحمد",
                        description: "برنامج شامل لبناء عضل ونزول دهون مع متابعة أونلاين.\n\n• ٥ أيام تمرين أسبوعيًا\n• مراجعة أسبوعية مع المدرب\n• تحديث الخطة حسب التقدم"
                    )
                } label: {
                    programCard(
                        title: "برنامج تحويل ٩٠ يوم مع كابتن أحمد",
                        subtitle: "برنامج شامل لبناء عضل ونزول دهون مع متابعة أونلاين.",
                        icon: "flame.circle.fill"
                    )
                }

                NavigationLink {
                    WorkoutProgramDetailView(
                        title: "برنامج نسائي لنحت الجسم ١٢ أسبوع",
                        description: "تركيز على الجزء السفلي والوسط، يناسب التدريب في البيت أو الجيم.\n\n• ٤ أيام تمرين\n• تمارين مناسبة للمبتدئات والمتقدمات\n• نصائح تغذية مرافقة"
                    )
                } label: {
                    programCard(
                        title: "برنامج نسائي لنحت الجسم ١٢ أسبوع",
                        subtitle: "تركيز على الجزء السفلي والوسط، يناسب التدريب في البيت أو الجيم.",
                        icon: "figure.dance"
                    )
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("افتح برامج المدربين المتقدمة")
                        .font(.subheadline.bold())
                    Text("مع FITGET بريميوم تقدر تشتري برامج جاهزة من مدربين معتمدين، ومتابعة خاصة لكل برنامج.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            }
        }
    }

    private func programCard(
        title: String,
        subtitle: String,
        icon: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.bold())

                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.left")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }
}

// MARK: - Program Detail

struct WorkoutProgramDetailView: View {
    let title: String
    let description: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title2.bold())

                Text(description)
                    .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("تفاصيل البرنامج")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Custom Program Wizard (بداية بسيطة)

struct CustomProgramWizardView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var goal: String = ""
    @State private var experience: String = ""
    @State private var daysPerWeek: Int = 3

    var body: some View {
        Form {
            Section(header: Text("هدفك الرئيسي")) {
                TextField("نزول وزن، بناء عضل، لياقة…", text: $goal)
            }

            Section(header: Text("مستوى الخبرة")) {
                TextField("مبتدئ، متوسط، متقدم", text: $experience)
            }

            Section(header: Text("أيام التمرين أسبوعياً")) {
                Stepper(value: $daysPerWeek, in: 2...6) {
                    Text("\(daysPerWeek) أيام")
                }
            }

            Section {
                Button("إنشاء برنامج مبدئي") {
                    dismiss()
                }
            }
        }
        .navigationTitle("برنامج مخصص")
    }
}

#Preview {
    let store = FGSubscriptionStore()
    var state = FGUserSubscriptionState()
    state.role = .free
    store.state = state

    return ProgramsHubView()
        .environmentObject(store)
}
