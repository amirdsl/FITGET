//
//  GamificationManager.swift
//  FITGET
//
//  Created on 25/11/2025.
//
import Combine
import Foundation

/// مدير عام لنظام الجوائز (XP + Coins) مع حفظ محلي.
@MainActor
final class GamificationManager: ObservableObject {
    static let shared = GamificationManager()
    
    // إجمالي الخبرة المحفوظة داخل هذا المدير (يمكنك لاحقًا ربطها مع ProgressManager أو PlayerProgress)
    @Published private(set) var xp: Int = 0
    @Published private(set) var level: Int = 1
    @Published private(set) var xpForNextLevel: Int = 100
    
    // العملات التي يمكن استخدامها في المتجر / البرامج المدفوعة
    @Published private(set) var coins: Int = 0
    
    private let xpKey = "gamification_xp"
    private let levelKey = "gamification_level"
    private let coinsKey = "gamification_coins"
    
    private init() {
        load()
        recalcXPForNextLevel()
    }
    
    // MARK: - Load / Save
    
    private func load() {
        let defaults = UserDefaults.standard
        xp = defaults.integer(forKey: xpKey)
        let savedLevel = defaults.integer(forKey: levelKey)
        level = max(savedLevel, 1)
        coins = defaults.integer(forKey: coinsKey)
    }
    
    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(xp, forKey: xpKey)
        defaults.set(level, forKey: levelKey)
        defaults.set(coins, forKey: coinsKey)
    }
    
    private func recalcXPForNextLevel() {
        // لوجيك بسيط: كل مستوى يحتاج XP أكثر بقليل من السابق
        xpForNextLevel = 100 + (level - 1) * 75
    }
    
    // MARK: - XP
    
    func addXP(_ amount: Int) {
        guard amount > 0 else { return }
        xp += amount
        
        // ترقية المستوى لو تخطينا الحد
        while xp >= xpForNextLevel {
            xp -= xpForNextLevel
            level += 1
            recalcXPForNextLevel()
        }
        
        persist()
    }
    
    /// تستخدم لاحقًا لو حبيت تعمل Reset من الإعدادات أو لأغراض الاختبار
    func resetXP() {
        xp = 0
        level = 1
        recalcXPForNextLevel()
        persist()
    }
    
    // MARK: - Coins
    
    /// إضافة عملات للمستخدم
    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
        persist()
    }
    
    /// محاولة صرف عملات (ترجع false لو الرصيد غير كافي)
    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard amount > 0, coins >= amount else { return false }
        coins -= amount
        persist()
        return true
    }
    
    /// Reset كامل للـ Coins (إذا احتجته من الإعدادات)
    func resetCoins() {
        coins = 0
        persist()
    }
    
    /// Reset كامل للنظام
    func resetAll() {
        xp = 0
        level = 1
        coins = 0
        recalcXPForNextLevel()
        persist()
    }
}
