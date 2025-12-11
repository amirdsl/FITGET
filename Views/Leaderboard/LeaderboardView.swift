//
//  LeaderboardView.swift
//  Fitget
//
//  لوحة المتصدرين (XP / تحديات / خطوات)
//

import SwiftUI

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let value: Int
    let suffix: String
    let isCurrentUser: Bool
}

struct LeaderboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @ObservedObject private var progressManager = ProgressManager.shared
    
    @State private var selectedTab = 0
    
    var isArabic: Bool { languageManager.currentLanguage == "ar" }
    
    // بيانات وهمية (لاحقًا تربطها مع Supabase)
    private var xpLeaderboard: [LeaderboardEntry] {
        [
            LeaderboardEntry(rank: 1, name: "Omar",  value: 4500, suffix: "XP", isCurrentUser: false),
            LeaderboardEntry(rank: 2, name: "Lina",  value: 3900, suffix: "XP", isCurrentUser: false),
            LeaderboardEntry(rank: 3, name: "You",   value: progressManager.totalXP, suffix: "XP", isCurrentUser: true)
        ]
    }
    
    private let tabs: [String] = ["xp", "challenges", "steps"]
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 16) {
                header
                
                tabSelector
                
                TabView(selection: $selectedTab) {
                    leaderboardList(entries: xpLeaderboard)
                        .tag(0)
                    
                    placeholderBoard(
                        titleAR: "تحديات الأسبوع",
                        titleEN: "Weekly challenges"
                    )
                    .tag(1)
                    
                    placeholderBoard(
                        titleAR: "أفضل عدد خطوات",
                        titleEN: "Top steps"
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .padding(.bottom, 8)
        }
        .navigationTitle(isArabic ? "لوحة المتصدرين" : "Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await progressManager.loadProgressFromBackend()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "نافس أصدقائك" : "Compete with others")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            Text(
                isArabic
                ? "كلما زادت نقاط الخبرة (XP) والتحديات المكتملة، ارتفع ترتيبك في لوحة المتصدرين."
                : "The more XP and completed challenges you have, the higher you rank."
            )
            .font(.caption)
            .foregroundColor(themeManager.textSecondary)
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    // MARK: - Tabs
    
    private var tabSelector: some View {
        HStack(spacing: 8) {
            tabButton(index: 0,
                      title: isArabic ? "XP" : "XP")
            tabButton(index: 1,
                      title: isArabic ? "التحديات" : "Challenges")
            tabButton(index: 2,
                      title: isArabic ? "الخطوات" : "Steps")
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private func tabButton(index: Int, title: String) -> some View {
        Button {
            withAnimation { selectedTab = index }
        } label: {
            Text(title)
                .font(.caption)
                .fontWeight(selectedTab == index ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    selectedTab == index
                    ? AppColors.primaryBlue.opacity(0.15)
                    : themeManager.cardBackground
                )
                .foregroundColor(
                    selectedTab == index
                    ? AppColors.primaryBlue
                    : themeManager.textSecondary
                )
                .cornerRadius(12)
        }
    }
    
    // MARK: - Lists
    
    private func leaderboardList(entries: [LeaderboardEntry]) -> some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(entries) { entry in
                    LeaderboardRow(entry: entry, isArabic: isArabic)
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
    
    private func placeholderBoard(titleAR: String, titleEN: String) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(isArabic ? "\(titleAR) (قريباً)" : "\(titleEN) (coming soon)")
                    .font(.subheadline)
                    .foregroundColor(themeManager.textSecondary)
                    .padding(.top, 24)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Row

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isArabic: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Text("#\(entry.rank)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(
                    entry.rank == 1 ? AppColors.accentGold : themeManager.textSecondary
                )
                .frame(width: 32)
            
            Circle()
                .fill(entry.isCurrentUser ? AppColors.primaryBlue : themeManager.cardBackground)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(entry.name.prefix(1)))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(entry.isCurrentUser ? .white : themeManager.textPrimary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.isCurrentUser && isArabic ? "أنت" :
                        entry.isCurrentUser ? "You" : entry.name)
                    .font(.subheadline)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("\(entry.value) \(entry.suffix)")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
        }
        .padding(10)
        .background(
            entry.isCurrentUser
            ? AppColors.primaryBlue.opacity(0.12)
            : themeManager.cardBackground
        )
        .cornerRadius(14)
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
