//
//  AuthAPI.swift
//  FITGET
//

import Foundation
import Supabase

enum AuthAPI {

    private static let supabase = SupabaseManager.shared

    // MARK: - Login

    static func login(
        email: String,
        password: String
    ) async throws -> Session {

        let session = try await supabase.auth.signIn(
            email: email.lowercased(),
            password: password
        )

        return session
    }

    // MARK: - Register

    static func register(
        name: String,
        email: String,
        password: String
    ) async throws -> Session {

        _ = try await supabase.auth.signUp(
            email: email.lowercased(),
            password: password,
            data: [
                "full_name": .string(name)
            ]
        )

        return try await supabase.auth.session
    }

    // MARK: - OAuth

    static func oauthSignIn(
        provider: Provider,
        redirectURL: URL
    ) async throws {

        try await supabase.auth.signInWithOAuth(
            provider: provider,
            redirectTo: redirectURL
        )
    }

    // MARK: - Logout

    static func logout() async throws {
        try await supabase.auth.signOut()
    }
}
