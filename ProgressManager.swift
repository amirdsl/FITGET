//
//  ProgressManager.swift
//  Fitget
//
//  Created on 24/11/2025.
//

import Foundation
import Combine
import Supabase

/// مدير التقدم (XP, Levels, Streak, Daily Activity)
final class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    // MARK: - Published State
    
    @Published var level: Int = 1
    @Published var totalXP: Int = 0
    @Published var xpForNextLevel: Int = 1000
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastActiveDate: Date?
    
    @Published var todaySteps: Int = 0
    @Published var todayCalories: Int = 0
    @Published var todayWorkouts: Int = 0
    
    /// إحصائيات آخر ٧ أيام (لشاشة الرسوم البيانية)
    @Published var last7DaysStats: [DailyStat] = []
    
    private let supabase = SupabaseManager.shared
    
    private init() { }
    
    // MARK: - Model
    
    struct DailyStat: Identifiable {
        let id = UUID()
        let date: Date
        let steps: Int
        let activeCalories: Int
        let workoutsCompleted: Int
    }
    
    // MARK: - Public API
    
    /// نداء يُستخدم عند إكمال تمرين (يعطي XP + يحدّث streak)
    func registerWorkoutCompleted(xp: Int = 100) {
        addXP(xp)
        todayWorkouts += 1
        markTodayActive()
        
        Task {
            await syncDailyActivity()
            await syncProgressToBackend()
        }
    }
    
    /// نداء عام لإضافة XP كمكافأة (مثلاً عند إكمال تحدّي)
    func addRewardXP(_ amount: Int) {
        guard amount > 0 else { return }
        addXP(amount)
        
        Task {
            await syncProgressToBackend()
        }
    }
    
    /// نداء لتحديث نشاط اليوم (من HealthKit أو ActivitySummary)
    func updateTodayActivity(steps: Int, calories: Int) {
        todaySteps = steps
        todayCalories = calories
        markTodayActive()
        
        let xpFromSteps = steps / 100        // كل 100 خطوة = 1 XP
        let xpFromCalories = calories / 10   // كل 10 kcal = 1 XP
        
        addXP(xpFromSteps + xpFromCalories)
        
        Task {
            await syncDailyActivity()
            await syncProgressToBackend()
        }
    }
    
    /// تحميل التقدم من Supabase (profiles + daily_stats)
    @MainActor
    func loadProgressFromBackend() async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString
            
            // profile: xp, level, streak_days
            struct ProfileRow: Decodable {
                let xp: Int?
                let level: Int?
                let streak_days: Int?
            }
            
            let profiles: [ProfileRow] = try await SupabaseManager.shared
                .from("profiles")
                .select("xp, level, streak_days")
                .eq("id", value: userId)
                .execute()
                .value
            
            if let row = profiles.first {
                let lvl = row.level ?? 1
                self.level = lvl
                self.totalXP = row.xp ?? 0
                self.xpForNextLevel = nextLevelXP(for: lvl)
                self.currentStreak = row.streak_days ?? 0
                self.longestStreak = max(self.longestStreak, self.currentStreak)
            }
            
            await loadLast7DaysActivity()
        } catch {
            print("ProgressManager load error: \(error)")
        }
    }
    
    // MARK: - XP / Levels Logic
    
    private func addXP(_ amount: Int) {
        guard amount > 0 else { return }
        totalXP += amount
        
        while totalXP >= xpForNextLevel {
            totalXP -= xpForNextLevel
            level += 1
            xpForNextLevel = nextLevelXP(for: level)
        }
    }
    
    private func nextLevelXP(for level: Int) -> Int {
        // يمكن تطويرها لاحقاً حسب المستويات (1–140)
        1000 + (level - 1) * 500
    }
    
    // MARK: - Streak Logic
    
    private func markTodayActive() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let last = lastActiveDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            switch diff {
            case 0:
                break
            case 1:
                currentStreak += 1
            default:
                currentStreak = 1
            }
        } else {
            currentStreak = max(currentStreak, 1)
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastActiveDate = today
    }
    
    // MARK: - Supabase Sync
    
    private func syncProgressToBackend() async {
        struct XPUpdate: Encodable {
            let xp: Int
            let level: Int
            let streak_days: Int
        }
        
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            let payload = XPUpdate(
                xp: totalXP,
                level: level,
                streak_days: currentStreak
            )
            
            _ = try await SupabaseManager.shared
                .from("profiles")
                .update(payload)
                .eq("id", value: userId.uuidString)
                .execute()
        } catch {
            print("ProgressManager sync profile error: \(error)")
        }
    }
    
    /// حفظ نشاط اليوم في جدول daily_stats
    private func syncDailyActivity() async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            let today = Calendar.current.startOfDay(for: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: today)
            
            struct DailyStatsPayload: Encodable {
                let user_id: UUID
                let stat_date: String
                let steps: Int
                let calories_burned: Double
                let calories_eaten: Double
            }
            
            let payload = DailyStatsPayload(
                user_id: userId,
                stat_date: dateString,
                steps: todaySteps,
                calories_burned: Double(todayCalories),
                calories_eaten: 0
            )
            
            _ = try await SupabaseManager.shared
                .from("daily_stats")
                .upsert(payload, onConflict: "user_id,stat_date")
                .execute()
        } catch {
            print("ProgressManager sync daily activity error: \(error)")
        }
    }
    
    /// تحميل آخر ٧ أيام من جدول daily_stats
    @MainActor
    func loadLast7DaysActivity() async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString
            
            struct Row: Decodable {
                let stat_date: String
                let steps: Int
                let calories_burned: Double
            }
            
            let rows: [Row] = try await SupabaseManager.shared
                .from("daily_stats")
                .select("stat_date, steps, calories_burned")
                .eq("user_id", value: userId)
                .order("stat_date", ascending: false)
                .limit(7)
                .execute()
                .value
            
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .gregorian)
            df.dateFormat = "yyyy-MM-dd"
            
            let mapped: [DailyStat] = rows.compactMap { row in
                guard let d = df.date(from: row.stat_date) else { return nil }
                return DailyStat(
                    date: d,
                    steps: row.steps,
                    activeCalories: Int(row.calories_burned),
                    workoutsCompleted: 0 // يمكن ربطه لاحقاً بـ user_workout_sessions
                )
            }
            
            self.last7DaysStats = mapped.sorted { $0.date < $1.date }
        } catch {
            print("ProgressManager loadLast7DaysActivity error: \(error)")
        }
    }
}
