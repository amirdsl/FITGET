//
//  AppRootView.swift
//  FITGET
//

import SwiftUI
import Combine

// تعريف الـ Enum داخل الملف لحل مشكلة "Cannot find type"
enum AuthSheet: Identifiable {
    case login
    case signup

    var id: String {
        switch self {
        case .login: return "login"
        case .signup: return "signup"
        }
    }
}

// كلاس بسيط لإدارة جلسة التطبيق (إذا لم يكن موجوداً في مكان آخر)
final class AppAuthSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

struct AppRootView: View {
    // تعريف الكائنات (StateObjects)
    @StateObject private var subscriptionStore = FGSubscriptionStore()
    @StateObject private var playerProgress = PlayerProgressManager.shared
    @StateObject private var appAuthSession = AppAuthSession()
    @StateObject private var authManager = AuthenticationManager.shared

    // متغير للتحكم في ظهور Login/Signup
    @State private var activeAuthSheet: AuthSheet?

    var body: some View {
        rootContent
            // تمرير البيئات (Environment Objects)
            .environmentObject(subscriptionStore)
            .environmentObject(playerProgress)
            .environmentObject(appAuthSession)
            .environmentObject(authManager)
            
            // مراقبة تغيير حالة الدخول
            .onChange(of: appAuthSession.isLoggedIn, initial: false) { _, newValue in
                if newValue && subscriptionStore.state.role == .guest {
                    subscriptionStore.state.role = .free
                }
            }
            .onChange(of: authManager.isAuthenticated, initial: false) { _, isAuth in
                if isAuth && subscriptionStore.state.role == .guest {
                    subscriptionStore.state.role = .free
                }
            }
            // إدارة الشيت (Sheet)
            .sheet(item: $activeAuthSheet) { sheet in
                switch sheet {
                case .login:
                    LoginView()
                        .environmentObject(appAuthSession)
                        .environmentObject(authManager)
                case .signup:
                    SignupView()
                        .environmentObject(appAuthSession)
                        .environmentObject(authManager)
                }
            }
    }

    @ViewBuilder
    private var rootContent: some View {
        // إذا المستخدم مسجل دخول -> الصفحة الرئيسية
        if appAuthSession.isLoggedIn || authManager.isAuthenticated {
            MainTabEntryView()
                .environmentObject(subscriptionStore)
                .environmentObject(playerProgress)
        } else {
            // إذا لم يكن مسجل دخول -> صفحة الترحيب (WelcomeView)
            // وهي تحتوي على أزرار (تسجيل دخول، إنشاء حساب، ضيف)
            WelcomeView(
                onSignup: {
                    // فتح شيت إنشاء الحساب
                    activeAuthSheet = .signup
                },
                onLogin: {
                    // فتح شيت تسجيل الدخول
                    activeAuthSheet = .login
                },
                onGuest: {
                    // الدخول كضيف مباشرة
                    appAuthSession.isLoggedIn = true
                    subscriptionStore.state.role = .free
                }
            )
        }
    }
}

#Preview {
    AppRootView()
}
