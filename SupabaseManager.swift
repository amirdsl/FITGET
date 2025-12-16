//
//  SupabaseManager.swift
//  FITGET
//

import Foundation
import Supabase

@MainActor
final class SupabaseManager {

    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        guard
            let urlString = Bundle.main.object(
                forInfoDictionaryKey: "SUPABASE_URL"
            ) as? String,
            let key = Bundle.main.object(
                forInfoDictionaryKey: "SUPABASE_ANON_KEY"
            ) as? String,
            let url = URL(string: urlString)
        else {
            fatalError("❌ Missing Supabase keys in Info.plist")
        }

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
    }

    // MARK: - Shortcuts

    var auth: AuthClient {
        client.auth
    }

    func from(_ table: String) -> PostgrestQueryBuilder {
        client.from(table)
    }

    // MARK: - RPC

    func rpc<T: Encodable>(
        _ fn: String,
        params: T
    ) async throws {
        try await client.rpc(fn, params: params).execute()
    }

    func rpc(_ fn: String) async throws {
        try await client.rpc(fn).execute()
    }
}
