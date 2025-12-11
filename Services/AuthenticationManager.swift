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
    
    // بيانات زيادة للبروفايل
    @Published private(set) var currentUserId: String?
    @Published private(set) var age: Int?
    @Published private(set) var height: Double?
    @Published private(set) var weight: Double?
    @Published private(set) var gender: String?
    
    // توكن (لو احتجناه مستقبلًا)
    private var storedAccessToken: String?
    
    // Supabase client
    private let supabase = SupabaseManager.shared
    
    // تخزين محلي بسيط
    private let d = UserDefaults.standard
    
    // MARK: - Init
    
    private init() {
        loadFromLocal()
        
        // محاولة استرجاع جلسة من Supabase + مراقبة حالة Auth
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
    
    /// تمثيل بسيط لبيانات المستخدم الحالية (للشاشات مثل NutritionView)
    struct CurrentUserInfo {
        let age: Int?
        let height: Double?
        let weight: Double?
        let gender: String?
    }
    
    /// مستخدم التطبيق الحالي (للواجهات اللي تحتاج معلومات كاملة)
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
    
    /// واجهة متوافقة مع ما تستخدمه NutritionView:
    /// `if let user = authManager.currentUser { ... }`
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
    
    // MARK: - Local Storage
    
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
    
    // MARK: - Profile Model مرتبط بجدول profiles
    
    struct ProfileRow: Codable {
        let id: UUID
        let fullName: String?
        let avatarURL: String?
        let goal: String?
        let experienceLevel: String?
        let preferredWorkouts: [String]?
        let heightCm: Double?
        let weightKg: Double?
        let gender: String?
        let dateOfBirth: String?
        let createdAt: String?
        let updatedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case fullName          = "full_name"
            case avatarURL         = "avatar_url"
            case goal
            case experienceLevel   = "experience_level"
            case preferredWorkouts = "preferred_workouts"
            case heightCm          = "height_cm"
            case weightKg          = "weight_kg"
            case gender
            case dateOfBirth       = "date_of_birth"
            case createdAt         = "created_at"
            case updatedAt         = "updated_at"
        }
    }
    
    // MARK: - Restore Session
    
    private func restoreSessionIfPossible() async {
        do {
            let session = try await supabase.auth.session
            let user = session.user
            
            isAuthenticated   = true
            isGuest           = false
            currentUserId     = user.id.uuidString
            currentUserEmail  = user.email
            storedAccessToken = session.accessToken
            
            await loadProfileFromDatabase(userId: user.id)
            saveToLocal()
        } catch {
            // لا يوجد جلسة حالية → تجاهل
            isAuthenticated = false
        }
    }
    
    private func observeAuthChanges() async {
        for await state in supabase.auth.authStateChanges {
            switch state.event {
            case .signedIn, .userUpdated, .tokenRefreshed:
                Task {
                    await self.handleSignedInState()
                }
            case .signedOut, .userDeleted, .passwordRecovery:
                Task {
                    await self.handleSignedOutState()
                }
            default:
                break
            }
        }
    }
    
    private func handleSignedInState() async {
        do {
            let session = try await supabase.auth.session
            let user = session.user
            isAuthenticated   = true
            isGuest           = false
            currentUserId     = user.id.uuidString
            currentUserEmail  = user.email
            storedAccessToken = session.accessToken
            
            await loadProfileFromDatabase(userId: user.id)
            saveToLocal()
        } catch {
            print("Failed to refresh session on auth change: \(error)")
        }
    }
    
    private func handleSignedOutState() async {
        isAuthenticated   = false
        isGuest           = false
        currentUserEmail  = nil
        currentUserName   = nil
        currentUserId     = nil
        storedAccessToken = nil
        age               = nil
        height            = nil
        weight            = nil
        gender            = nil
        errorMessage      = nil
        
        saveToLocal()
    }
    
    // MARK: - Load / Create Profile from Supabase
    
    private func loadProfileFromDatabase(userId: UUID) async {
        do {
            let rows: [ProfileRow] = try await supabase.database
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .limit(1)
                .execute()
                .value
            
            guard let row = rows.first else {
                // ما فيه صف → ننشئ بروفايل مبدئي لو احتجنا
                return
            }
            
            self.currentUserName = row.fullName ?? currentUserEmail
            self.height          = row.heightCm
            self.weight          = row.weightKg
            self.gender          = row.gender
            
            saveToLocal()
        } catch {
            print("Failed to load profile: \(error)")
        }
    }
    
    private func createInitialProfile(for userId: UUID, fullName: String) async {
        let profile = ProfileRow(
            id: userId,
            fullName: fullName,
            avatarURL: nil,
            goal: nil,
            experienceLevel: nil,
            preferredWorkouts: nil,
            heightCm: nil,
            weightKg: nil,
            gender: nil,
            dateOfBirth: nil,
            createdAt: nil,
            updatedAt: nil
        )
        
        do {
            _ = try await supabase.database
                .from("profiles")
                .insert(profile)
                .execute()
        } catch {
            print("Failed to create initial profile: \(error)")
        }
    }
    
    private func updateProfileInDatabase(
        userId: UUID,
        fullName: String?,
        age: Int?,
        height: Double?,
        weight: Double?,
        gender: String?
    ) async {
        let profile = ProfileRow(
            id: userId,
            fullName: fullName ?? currentUserName,
            avatarURL: nil,
            goal: nil,
            experienceLevel: nil,
            preferredWorkouts: nil,
            heightCm: height,
            weightKg: weight,
            gender: gender,
            dateOfBirth: nil,
            createdAt: nil,
            updatedAt: nil
        )
        
        do {
            _ = try await supabase.database
                .from("profiles")
                .upsert(profile)
                .eq("id", value: profile.id.uuidString)
                .execute()
        } catch {
            print("Failed to update profile: \(error)")
        }
    }
    
    // MARK: - Email / Password Sign In
    
    func signIn(email: String, password: String) async {
        errorMessage = nil
        
        let trimmedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        guard !trimmedEmail.isEmpty,
              !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.signIn(
                email: trimmedEmail,
                password: password
            )
            
            let user = session.user
            isAuthenticated   = true
            isGuest           = false
            currentUserId     = user.id.uuidString
            currentUserEmail  = user.email
            currentUserName   = user.email
            storedAccessToken = session.accessToken
            
            await loadProfileFromDatabase(userId: user.id)
            saveToLocal()
        } catch {
            print("Sign in error: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Email / Password Sign Up
    
    func signUp(name: String, email: String, password: String) async {
        errorMessage = nil
        
        let trimmedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        let trimmedName = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty,
              !password.isEmpty,
              !trimmedName.isEmpty else {
            errorMessage = "Please fill all fields."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let metadata: [String: AnyJSON] = [
                "full_name": .string(trimmedName)
            ]
            
            _ = try await supabase.auth.signUp(
                email: trimmedEmail,
                password: password,
                data: metadata
            )
            
            // لو مفعل تأكيد الإيميل في Supabase قد لا ترجع جلسة مباشرة
            if let session = try? await supabase.auth.session {
                let user = session.user
                isAuthenticated   = true
                isGuest           = false
                currentUserId     = user.id.uuidString
                currentUserEmail  = user.email
                currentUserName   = trimmedName
                storedAccessToken = session.accessToken
                
                await createInitialProfile(for: user.id, fullName: trimmedName)
                saveToLocal()
            } else {
                // تحتاج تفعيل "Disable email confirmations" لو حاب تسجيل فوري
                errorMessage = "Check your email to confirm your account."
            }
        } catch {
            print("Sign up error: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - تحديث بيانات المستخدم من داخل التطبيق (تُستخدم في NutritionView)
    
    func updateUserInfo(age: Int, height: Double, weight: Double, gender: String) {
        self.age    = age
        self.height = height
        self.weight = weight
        self.gender = gender
        saveToLocal()
        
        if let idString = currentUserId,
           let uuid = UUID(uuidString: idString) {
            Task {
                await self.updateProfileInDatabase(
                    userId: uuid,
                    fullName: nil,
                    age: age,
                    height: height,
                    weight: weight,
                    gender: gender
                )
            }
        }
    }
    
    // MARK: - Guest Mode
    
    func startGuestSession() {
        isGuest           = true
        isAuthenticated   = false
        currentUserId     = nil
        currentUserEmail  = nil
        currentUserName   = "Guest"
        storedAccessToken = nil
        age               = nil
        height            = nil
        weight            = nil
        gender            = nil
        errorMessage      = nil
        
        saveToLocal()
    }
    
    // MARK: - OAuth (مستقبلًا)
    
    enum OAuthProvider {
        case apple
        case google
    }
    
    func signInWithOAuth(_ provider: OAuthProvider) async {
        // سيتم تفعيلها لاحقًا مع ASWebAuthenticationSession
        errorMessage = "OAuth not configured yet."
    }
    
    // MARK: - Logout
    
    func signOut() {
        Task {
            try? await supabase.auth.signOut()
        }
        
        isAuthenticated   = false
        isGuest           = false
        currentUserEmail  = nil
        currentUserName   = nil
        currentUserId     = nil
        storedAccessToken = nil
        age               = nil
        height            = nil
        weight            = nil
        gender            = nil
        errorMessage      = nil
        
        saveToLocal()
    }
}
