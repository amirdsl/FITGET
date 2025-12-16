//
//  CartManager.swift
//  Fitget
//
//  Path: Fitget/Managers/Supabase/CartManager.swift
//
//  Created on 23/11/2025.
//

import Foundation
import Supabase
import Combine

struct CartItem: Identifiable, Decodable {
    let id: UUID
    let user_id: UUID
    let program_id: UUID
    let quantity: Int
    let created_at: Date?
}

private struct NewCartItem: Encodable {
    let user_id: UUID
    let program_id: UUID
    let quantity: Int
}

final class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared
    
    private init() { }
    
    // MARK: - Load
    
    @MainActor
    func loadCart() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            let fetched: [CartItem] = try await SupabaseManager.shared
                .from("cart_items")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            self.items = fetched
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    // MARK: - Add
    
    @MainActor
    func addProgramToCart(programId: UUID, quantity: Int = 1) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            let payload = NewCartItem(
                user_id: userId,
                program_id: programId,
                quantity: quantity
            )
            
            let inserted: [CartItem] = try await SupabaseManager.shared
                .from("cart_items")
                .insert(payload)
                .select()
                .execute()
                .value
            
            for item in inserted {
                if let index = items.firstIndex(where: { $0.id == item.id }) {
                    items[index] = item
                } else {
                    items.append(item)
                }
            }
            
            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    // MARK: - Remove
    
    @MainActor
    func removeItem(_ item: CartItem) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await SupabaseManager.shared
                .from("cart_items")
                .delete()
                .eq("id", value: item.id)
                .execute()
            
            items.removeAll { $0.id == item.id }
            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    // MARK: - Clear
    
    @MainActor
    func clearCart() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            try await SupabaseManager.shared
                .from("cart_items")
                .delete()
                .eq("user_id", value: userId)
                .execute()
            
            items.removeAll()
            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
