//
//  NewPostView.swift
//  FITGET
//
//  شاشة إنشاء منشور جديد في المجتمع
//

import SwiftUI

struct NewPostView: View {
    let isArabic: Bool
    let currentUser: CommunityUser
    let onSubmit: (CommunityPost) -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var text: String = ""
    @State private var selectedMediaType: PostMediaType? = nil
    
    private var canPost: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Text
                    VStack(alignment: .leading, spacing: 6) {
                        Text(isArabic ? "اكتب ما تريد مشاركته" : "What do you want to share?")
                            .font(.subheadline)
                            .foregroundColor(themeManager.textSecondary)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(themeManager.cardBackground)
                            
                            TextEditor(text: $text)
                                .padding(8)
                                .foregroundColor(themeManager.textPrimary)
                                .background(Color.clear)
                            
                            if text.isEmpty {
                                Text(
                                    isArabic
                                    ? "مثال: أنهيت اليوم تمرين الأرجل بالكامل 💪"
                                    : "Example: Just crushed my leg day workout 💪"
                                )
                                .foregroundColor(themeManager.textSecondary)
                                .font(.caption)
                                .padding(12)
                            }
                        }
                        .frame(minHeight: 140)
                    }
                    
                    // Media type
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isArabic ? "إضافة صورة / فيديو (اختياري)" : "Add photo / video (optional)")
                            .font(.subheadline)
                            .foregroundColor(themeManager.textSecondary)
                        
                        HStack(spacing: 12) {
                            mediaTypeButton(
                                type: .image,
                                systemImage: "photo.on.rectangle",
                                labelAR: "صورة",
                                labelEN: "Image"
                            )
                            
                            mediaTypeButton(
                                type: .video,
                                systemImage: "play.rectangle.fill",
                                labelAR: "فيديو",
                                labelEN: "Video"
                            )
                            
                            Spacer()
                        }
                        
                        if let type = selectedMediaType {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(themeManager.secondaryBackground)
                                    .frame(height: 140)
                                
                                VStack(spacing: 6) {
                                    Image(systemName: type == .image ? "photo.on.rectangle.angled" : "play.rectangle.fill")
                                        .font(.title2)
                                    Text(
                                        isArabic
                                        ? (type == .image ? "سيتم اختيار صورة من الاستديو في النسخة الكاملة." : "سيتم اختيار فيديو من الاستديو في النسخة الكاملة.")
                                        : (type == .image ? "Image will be chosen from gallery in full version." : "Video will be chosen from gallery in full version.")
                                    )
                                    .font(.caption2)
                                    .foregroundColor(themeManager.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                }
                                .foregroundColor(themeManager.textSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(isArabic ? "منشور جديد" : "New post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(isArabic ? "إلغاء" : "Cancel")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createPost()
                    } label: {
                        Text(isArabic ? "نشر" : "Post")
                            .fontWeight(.semibold)
                    }
                    .disabled(!canPost)
                }
            }
        }
    }
    
    private func mediaTypeButton(
        type: PostMediaType,
        systemImage: String,
        labelAR: String,
        labelEN: String
    ) -> some View {
        let isSelected = selectedMediaType == type
        
        return Button {
            if isSelected {
                selectedMediaType = nil
            } else {
                selectedMediaType = type
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(isArabic ? labelAR : labelEN)
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.primaryBlue.opacity(0.15) : themeManager.cardBackground)
            )
            .foregroundColor(isSelected ? AppColors.primaryBlue : themeManager.textPrimary)
        }
    }
    
    private func createPost() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newPost = CommunityPost(
            author: currentUser,
            createdAt: Date(),
            text: trimmed,
            mediaType: selectedMediaType,
            mediaURL: nil,
            reactions: ReactionSummary(likeCount: 0, fireCount: 0, clapCount: 0, userReaction: nil),
            commentsCount: 0
        )
        
        onSubmit(newPost)
        dismiss()
        // TODO: إرسال البوست للـ backend (Supabase) في المرحلة التالية
    }
}

#Preview {
    NewPostView(
        isArabic: true,
        currentUser: CommunityUser(
            id: UUID(),
            name: "You",
            role: .athlete,
            isFriend: true,
            isFollowing: true
        ),
        onSubmit: { _ in }
    )
    .environmentObject(ThemeManager.shared)
}
