//
//  AppRootView.swift
//  FITGET
//
//  Path: FITGET/AppRootView.swift
//

import SwiftUI
import Combine

/// جلسة بسيطة تحدد هل المستخدم عامل تسجيل دخول في الحساب ولا لأ.
/// (ده غير موضوع الاشتراك، الاشتراك جوه FGSubscriptionStore)
final class AuthSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

enum AuthSheet: Identifiable {
    case login
    case signup

    var id: String {
        switch self {
        case .login:  return "login"
        case .signup: return "signup"
        }
    }
}

struct AppRootView: View {

    // متجر الاشتراك (من SubscriptionModels.swift)
    @StateObject private var subscriptionStore = FGSubscriptionStore()

    // نظام الخبرة والكوينز
    @StateObject private var playerProgress = PlayerProgress()

    // حالة الدخول (محلي)
    @StateObject private var authSession = AuthSession()
    
    // 🔥 Supabase Auth
    @StateObject private var supabaseAuth = SupabaseAuthService.shared

    // Paywall
    @State private var showPaywall: Bool = false
    @State private var activeAuthSheet: AuthSheet?

    var body: some View {
        ZStack {
            rootContent
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        }
        .sheet(item: $activeAuthSheet) { sheet in
            switch sheet {
            case .login:
                LoginView()
                    .environmentObject(authSession)
                    .environmentObject(supabaseAuth)
            case .signup:
                SignupView()
                    .environmentObject(authSession)
                    .environmentObject(supabaseAuth)
            }
        }
        // نشر الـ EnvironmentObjects الرئيسية لباقي الشجرة
        .environmentObject(subscriptionStore)
        .environmentObject(playerProgress)
        .environmentObject(authSession)
        .environmentObject(supabaseAuth)
        .onAppear {
            // تهيئة خدمات Supabase الخاصة بالعلاج الطبيعي / التأهيل
            SupabaseManager.shared.configurePhysioBackend()

            Task {
                await supabaseAuth.loadSession()
            }
        }
        // iOS 17: onChange الجديد مع معامل initial
        .onChange(of: authSession.isLoggedIn, initial: false) { _, newValue in
            if newValue && subscriptionStore.state.role == .guest {
                subscriptionStore.state.role = .free
            }
        }
        .onChange(of: supabaseAuth.isAuthenticated, initial: false) { _, isAuth in
            if isAuth && subscriptionStore.state.role == .guest {
                subscriptionStore.state.role = .free
            }
        }
    }

    // MARK: - Root Content

    @ViewBuilder
    private var rootContent: some View {
        // لو المستخدم عامل تسجيل دخول (حساب موجود)
        if authSession.isLoggedIn || supabaseAuth.isAuthenticated {
            MainTabEntryView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        } else {
            // أول مرة / مو عامل تسجيل دخول → شاشة الدخول/التسجيل/الدخول السريع
            GuestTrialEntryView(
                onLoginSelected: {
                    activeAuthSheet = .login
                },
                onSignupSelected: {
                    activeAuthSheet = .signup
                },
                onGuestStarted: {
                    authSession.isLoggedIn = true
                    subscriptionStore.state.role = .free
                }
            )
            .environmentObject(subscriptionStore)
        }
    }
}

#Preview {
    AppRootView()
}
