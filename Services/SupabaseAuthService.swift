//
//  SupabaseAuthService.swift
//  FITGET
//

import Foundation
import Combine
import Supabase

/// خدمة موحدة للتعامل مع Supabase Auth
@MainActor
final class SupabaseAuthService: ObservableObject {

    static let shared = SupabaseAuthService()

    /// هل المستخدم مسجّل دخول حاليًا
    @Published var isAuthenticated: Bool = false

    /// جلسة Supabase الكاملة (نستخدمها في AppRootView للمراقبة)
    @Published var session: Session?

    /// كائن المستخدم الحالي
    @Published var currentUser: User?

    /// حالة تحميل/أخطاء بسيطة للواجهات
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// Supabase manager الموحد في المشروع
    private let supabase = SupabaseManager.shared

    private init() {
        Task {
            await loadSession()
        }
    }

    // MARK: - Session

    /// تستدعيها الواجهات عند التشغيل الأول
    func loadSession() async {
        await refreshSession()
    }

    /// تحميل الجلسة الحالية من Supabase وتحديث الحالة المنشورة
    func refreshSession() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // في supabase-swift: ترجع Session أو ترمي خطأ إذا ما فيه جلسة
            let currentSession = try await supabase.auth.session
            self.session = currentSession
            self.currentUser = currentSession.user
            self.isAuthenticated = true
            // لا نعرض رسالة خطأ هنا؛ لو مافيه جلسة ببساطة المستخدم غير مسجّل
            self.errorMessage = nil
        } catch {
            // لا توجد جلسة حالية أو خطأ آخر → نعتبره "ليس مسجّل دخول"
            self.session = nil
            self.currentUser = nil
            self.isAuthenticated = false
            // لا نمرر رسالة "Auth session missing" للمستخدم
            print("SupabaseAuthService.refreshSession error:", error)
        }
    }

    // MARK: - Email / Password

    /// تسجيل الدخول بالإيميل والباسورد
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let newSession = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            self.session = newSession
            self.currentUser = newSession.user
            self.isAuthenticated = true
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    /// إنشاء حساب جديد
    ///
    /// ملاحظة: بعض إعدادات Supabase لا ترجع Session بعد التسجيل
    /// (في حالة تفعيل تأكيد البريد)، لذلك لا نحاول فرض وجود Session هنا.
    func signUp(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            // نحاول الحصول على Session إن وجدت بدون ما نرمي خطأ
            let maybeSession = try? await supabase.auth.session
            self.session = maybeSession
            self.currentUser = maybeSession?.user
            self.isAuthenticated = (maybeSession != nil)
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        do {
            try await supabase.auth.signOut()
        } catch {
            print("SupabaseAuthService.signOut error:", error)
        }
        self.session = nil
        self.currentUser = nil
        self.isAuthenticated = false
    }

    // MARK: - Guest Mode (داخل التطبيق فقط)

    /// الدخول كضيف (بدون حساب في Supabase)
    func enterGuestMode() {
        // لا يوجد مستخدم في Supabase، لكن التطبيق يفتح كـ Free User
        self.session = nil
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
