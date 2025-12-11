//
//  SupabaseManager.swift
//  FITGET
//
//  Created on 21/11/2025.
//

import Foundation
import Supabase
import PostgREST
import Auth

final class SupabaseManager {
    static let shared = SupabaseManager()

    private init() {}

    // MARK: - Config from UserDefaults (SettingsView)

    private var storedURLString: String {
        UserDefaults.standard.string(forKey: "https://wzroxxomcrofxaphgfuy.supabase.co") ?? ""
    }

    private var storedKeyString: String {
        UserDefaults.standard.string(forKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cm94eG9tY3JvZnhhcGhnZnV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MTQ2MTYsImV4cCI6MjA3OTk5MDYxNn0.jXuCptr9Q_CED1fReAvJeOtez0D8ZrdcVnjsh7i1Jao") ?? ""
    }

    var isConfigured: Bool {
        let urlString = storedURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = storedKeyString.trimmingCharacters(in: .whitespacesAndNewlines)
        return !urlString.isEmpty && !key.isEmpty && URL(string: urlString) != nil
    }

    // MARK: - Client

    private var client: SupabaseClient {
        let urlString = storedURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = storedKeyString.trimmingCharacters(in: .whitespacesAndNewlines)

        if let url = URL(string: urlString), !key.isEmpty {
            return SupabaseClient(
                supabaseURL: url,
                supabaseKey: key
            )
        } else {
            // Client تجريبي فقط لتفادي الكراش لو الإعدادات غير مكتملة
            let dummyURL = URL(string: "https://wzroxxomcrofxaphgfuy.supabase.co")!
            return SupabaseClient(
                supabaseURL: dummyURL,
                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cm94eG9tY3JvZnhhcGhnZnV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MTQ2MTYsImV4cCI6MjA3OTk5MDYxNn0.jXuCptr9Q_CED1fReAvJeOtez0D8ZrdcVnjsh7i1Jao"
            )
        }
    }

    var database: PostgrestClient {
        client.database
    }

    var auth: AuthClient {
        client.auth
    }

    var functions: FunctionsClient {
        client.functions
    }

    // MARK: - Simple Fetch Helpers (تقدر تكمل عليهم لاحقًا)

    func fetchExercises() async throws -> [Exercise] {
        try await database
            .from("exercises")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchPrograms() async throws -> [TrainingProgram] {
        try await database
            .from("training_programs")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchProfile(userId: UUID) async throws -> Profile? {
        let rows: [Profile] = try await database
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        return rows.first
    }

    func updateProfile(_ profile: Profile) async throws {
        _ = try await database
            .from("profiles")
            .update(profile)
            .eq("id", value: profile.id.uuidString)
            .execute()
    }

    // MARK: - XP Helper (Stub مؤقت بدون أخطاء)

    /// TODO: لاحقًا نربطها مع جدول progress في Supabase
    func addExperiencePoints(userId: UUID, points: Int) async throws {
        guard points > 0 else { return }
        // في النسخة الحالية لا نرسل شيء للباك إند لتفادي الأخطاء
    }
}
