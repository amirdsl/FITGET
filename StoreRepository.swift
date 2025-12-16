//
//  StoreRepository.swift
//  FITGET
//

import Foundation
import Supabase
import PostgREST

// MARK: - Models

struct ShopItem: Identifiable, Codable {
    let id: UUID
    let nameEn: String
    let nameAr: String
    let descriptionEn: String?
    let descriptionAr: String?
    let price: Int
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case nameEn        = "name_en"
        case nameAr        = "name_ar"
        case descriptionEn = "description_en"
        case descriptionAr = "description_ar"
        case price
        case imageUrl      = "image_url"
    }
}

final class StoreRepository {
    static let shared = StoreRepository()
    private init() {}

    private let supabase = SupabaseManager.shared

    // MARK: - Coin Wallet

    func fetchCoinBalance(userId: UUID) async throws -> Int {
        struct Row: Decodable { let coin_balance: Int? }

        let rows: [Row] = try await SupabaseManager.shared
            .from("coin_wallet")
            .select("coin_balance")
            .eq("user_id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        return rows.first?.coin_balance ?? 0
    }

    func setCoinBalance(userId: UUID, balance: Int) async throws {
        struct Payload: Encodable {
            let user_id: UUID
            let coin_balance: Int
        }

        let payload = Payload(user_id: userId, coin_balance: balance)

        _ = try await SupabaseManager.shared
            .from("coin_wallet")
            .upsert(payload, onConflict: "user_id")
            .execute()
    }

    func addCoins(userId: UUID, delta: Int) async throws {
        let current = try await fetchCoinBalance(userId: userId)
        try await setCoinBalance(userId: userId, balance: max(0, current + delta))
    }

    // MARK: - Shop Items

    func fetchShopItems() async throws -> [ShopItem] {
        try await SupabaseManager.shared
            .from("shop_items")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Purchases

    func purchaseItem(userId: UUID, item: ShopItem) async throws -> Bool {
        let current = try await fetchCoinBalance(userId: userId)
        if current < item.price { return false }

        try await addCoins(userId: userId, delta: -item.price)

        struct PurchasePayload: Encodable {
            let user_id: UUID
            let item_id: UUID
        }

        let payload = PurchasePayload(user_id: userId, item_id: item.id)

        _ = try await SupabaseManager.shared
            .from("user_purchases")
            .insert(payload)
            .execute()

        return true
    }
}
