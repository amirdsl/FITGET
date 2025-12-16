//
//  AuthenticationManager.swift
//  FITGET
//
//  Path: FITGET/Services/AuthenticationManager.swift
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
final class AuthenticationManager: ObservableObject {

    static let shared = AuthenticationManager()

    // MARK: - Published State

    @Published var isAuthenticated: Bool = false
    @Published var isGuest: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var currentUserEmail: String?
    @Published var currentUserName: String?

    // Profile fields
    @Published private(set) var currentUserId: String?
    @Published private(set) var age: Int?
    @Published private(set) var height: Double?
    @Published private(set) var weight: Double?
    @Published private(set) var gender: String?

    private var storedAccessToken: String?

    // Supabase
    private let supabase = SupabaseManager.shared
    private let d = UserDefaults.standard

    // MARK: - Init

    private init() {
        loadFromLocal()

        Task {
            await restoreSessionIfPossible()
            await observeAuthChanges()
        }
    }

    // MARK: - Public User Models

    struct AuthUser {
        let id: String
        let email: String?
        let name: String?
        let isGuest: Bool
        let age: Int?
        let height: Double?
        let weight: Double?
        let gender: String?
    }

    struct CurrentUserInfo {
        let age: Int?
        let height: Double?
        let weight: Double?
        let gender: String?
    }

    var authUser: AuthUser? {
        guard isAuthenticated || isGuest else { return nil }
        return AuthUser(
            id: currentUserId ?? "guest",
            email: currentUserEmail,
            name: currentUserName,
            isGuest: isGuest,
            age: age,
            height: height,
            weight: weight,
            gender: gender
        )
    }

    var currentUser: CurrentUserInfo? {
        if age == nil && height == nil && weight == nil && gender == nil {
            return nil
        }
        return CurrentUserInfo(
            age: age,
            height: height,
            weight: weight,
            gender: gender
        )
    }

    // MARK: - Local Cache (NOT source of truth)

    private func loadFromLocal() {
        currentUserEmail = d.string(forKey: "auth_email")
        currentUserName  = d.string(forKey: "auth_fullname")
        age              = d.object(forKey: "auth_age") as? Int
        height           = d.object(forKey: "auth_height") as? Double
        weight           = d.object(forKey: "auth_weight") as? Double
        gender           = d.string(forKey: "auth_gender")
        currentUserId    = d.string(forKey: "auth_user_id")
    }

    private func saveToLocal() {
        d.set(currentUserEmail, forKey: "auth_email")
        d.set(currentUserName,  forKey: "auth_fullname")
        d.set(age,              forKey: "auth_age")
        d.set(height,           forKey: "auth_height")
        d.set(weight,           forKey: "auth_weight")
        d.set(gender,           forKey: "auth_gender")
        d.set(currentUserId,    forKey: "auth_user_id")
    }

    // MARK: - Supabase Profile Models

    struct ProfileRow: Codable {
        let id: UUID
        let fullName: String?
        let heightCm: Double?
        let weightKg: Double?
        let gender: String?

        enum CodingKeys: String, CodingKey {
            case id
            case fullName = "full_name"
            case heightCm = "height_cm"
            case weightKg = "weight_kg"
            case gender
        }
    }

    // حذفنا هيكل InitialProfileInsert لأننا لم نعد نستخدمه من التطبيق

    struct ProfileUpdatePayload: Encodable {
        let height_cm: Double?
        let weight_kg: Double?
        let gender: String?
        let full_name: String?
    }

    // MARK: - Restore Session

    private func restoreSessionIfPossible() async {
        do {
            let session = try await supabase.auth.session
            await handleSignedIn(session: session)
        } catch {
            resetToGuest()
        }
    }

    private func observeAuthChanges() async {
        for await state in supabase.auth.authStateChanges {
            switch state.event {
            case .signedIn, .userUpdated, .tokenRefreshed:
                if let session = state.session {
                    await handleSignedIn(session: session)
                }
            case .signedOut, .userDeleted:
                resetToGuest()
            default:
                break
            }
        }
    }

    private func handleSignedIn(session: Session) async {
        let user = session.user

        isAuthenticated = true
        isGuest = false
        currentUserId = user.id.uuidString
        currentUserEmail = user.email
        storedAccessToken = session.accessToken

        // محاولة استرجاع الاسم من Metadata
        if currentUserName == nil {
            if let metaName = user.userMetadata["full_name"] {
                if case .string(let nameStr) = metaName {
                    currentUserName = nameStr
                }
            } else if let metaName = user.userMetadata["name"] {
                if case .string(let nameStr) = metaName {
                    currentUserName = nameStr
                }
            }
        }

        // تحميل البروفايل الموجود (الذي أنشأه الـ Trigger)
        await loadProfileFromDatabase(userId: user.id)

        // 🔗 تحميل Player Progress
        await PlayerProgressManager.shared.loadProgress(for: user.id)

        saveToLocal()
    }

    private func resetToGuest() {
        isAuthenticated = false
        isGuest = true
        currentUserId = nil
        currentUserEmail = nil
        currentUserName = "Guest"
        storedAccessToken = nil
        age = nil
        height = nil
        weight = nil
        gender = nil
        errorMessage = nil
        saveToLocal()
    }

    // MARK: - Profile Load

    private func loadProfileFromDatabase(userId: UUID) async {
        do {
            let rows: [ProfileRow] = try await SupabaseManager.shared
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .limit(1)
                .execute()
                .value

            if let row = rows.first {
                currentUserName = row.fullName ?? currentUserEmail
                height = row.heightCm
                weight = row.weightKg
                gender = row.gender
            }
            // لم نعد نحاول إنشاء البروفايل هنا يدوياً
            // نعتمد على أن قاعدة البيانات ستقوم بذلك
            
            saveToLocal()
        } catch {
            print("Profile load failed:", error)
        }
    }

    // تم حذف createInitialProfile لأن الـ Trigger يقوم بالمهمة

    // MARK: - Update Profile (used by NutritionView)

    func updateUserInfo(age: Int, height: Double, weight: Double, gender: String) {
        self.age = age
        self.height = height
        self.weight = weight
        self.gender = gender
        saveToLocal()

        guard let idString = currentUserId,
              let uuid = UUID(uuidString: idString) else { return }

        let payload = ProfileUpdatePayload(
            height_cm: height,
            weight_kg: weight,
            gender: gender,
            full_name: currentUserName
        )

        Task {
            try? await SupabaseManager.shared
                .from("profiles")
                .update(payload)
                .eq("id", value: uuid.uuidString)
                .execute()
        }
    }

    // MARK: - Email / Password

    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await supabase.auth.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: password
            )
            await handleSignedIn(session: session)
        } catch {
            print("SignIn Error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func signUp(name: String, email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        
        do {
            print("🚀 Attempting Sign Up (Trigger-based) for: \(email)")
            
            // 1. تجهيز البيانات الوصفية (Metadata)
            // ضروري جداً إرسال الاسم هنا لأن الـ Trigger سيقرأه من هنا ليضعه في جدول profiles
            let metadata: [String: AnyJSON] = [
                "full_name": .string(name),
                "name": .string(name)
            ]
            
            // 2. التسجيل فقط (بدون إنشاء بروفايل يدوياً)
            let response = try await supabase.auth.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: password,
                data: metadata
            )
            
            print("✅ Supabase Auth Call Success. User ID: \(response.user.id)")
            
            // 3. التحقق من الجلسة
            if let session = response.session {
                print("✅ Session active. Signing in locally...")
                currentUserName = name
                currentUserEmail = email
                
                // في هذه اللحظة، المفترض أن الـ Trigger قد أنشأ البروفايل في قاعدة البيانات
                // دالة handleSignedIn ستحاول قراءته
                await handleSignedIn(session: session)
                
            } else {
                print("⚠️ User created. Waiting for email confirmation.")
                errorMessage = "Account created! Please check your email to confirm."
            }
            
        } catch {
            print("❌ Sign Up Failed: \(error)")
            isLoading = false
            
            let errStr = error.localizedDescription
            if errStr.contains("User already registered") {
                errorMessage = "Email already in use."
            } else if errStr.contains("Database error") {
                // هذا الخطأ يظهر عادة إذا فشل الـ Trigger
                errorMessage = "System error. Please try again later."
            } else {
                errorMessage = errStr
            }
        }
        
        if isLoading { isLoading = false }
    }


    // MARK: - Guest Mode

    func startGuestSession() {
        resetToGuest()
    }

    // MARK: - Logout

    func signOut() {
        Task { try? await supabase.auth.signOut() }
        resetToGuest()
    }
}
