//
//  CommunityModels.swift
//  FITGET
//
//  Models used in Community (posts, users, conversations, messages)
//

import Combine
import Foundation

// MARK: - Tabs

enum CommunityTab: String, CaseIterable, Identifiable {
    case feed
    case messages
    case friends
    
    var id: String { rawValue }
    
    func title(isArabic: Bool) -> String {
        switch self {
        case .feed:
            return isArabic ? "المنشورات" : "Feed"
        case .messages:
            return isArabic ? "الرسائل" : "Messages"
        case .friends:
            return isArabic ? "الأصدقاء" : "Friends"
        }
    }
    
    var iconName: String {
        switch self {
        case .feed: return "text.bubble.fill"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .friends: return "person.2.fill"
        }
    }
}

// MARK: - Users

enum UserRole: String, Codable, Equatable {
    case coach
    case athlete
    
    func label(isArabic: Bool) -> String {
        switch self {
        case .coach:
            return isArabic ? "مدرب" : "Coach"
        case .athlete:
            return isArabic ? "لاعب" : "Athlete"
        }
    }
}

struct CommunityUser: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let role: UserRole
    var isFriend: Bool
    var isFollowing: Bool
}

extension CommunityUser {
    static let sampleUsers: [CommunityUser] = [
        CommunityUser(id: UUID(), name: "Coach Ahmed", role: .coach,   isFriend: true,  isFollowing: true),
        CommunityUser(id: UUID(), name: "Sara",        role: .athlete, isFriend: true,  isFollowing: true),
        CommunityUser(id: UUID(), name: "Omar",        role: .athlete, isFriend: false, isFollowing: true),
        CommunityUser(id: UUID(), name: "Coach Lina",  role: .coach,   isFriend: false, isFollowing: false)
    ]
}

// MARK: - Posts / Reactions

enum PostMediaType: String, Codable {
    case image
    case video
}

enum ReactionType: String, Codable {
    case like
    case fire
    case clap
}

struct ReactionSummary: Codable {
    var likeCount: Int
    var fireCount: Int
    var clapCount: Int
    
    var userReaction: ReactionType?
}

struct CommunityPost: Identifiable, Codable {
    let id: UUID
    let author: CommunityUser
    let createdAt: Date
    let text: String
    let mediaType: PostMediaType?
    let mediaURL: String?        // لاحقًا تتوصل مع ملفات حقيقية
    
    var reactions: ReactionSummary
    var commentsCount: Int
    
    init(
        id: UUID = UUID(),
        author: CommunityUser,
        createdAt: Date,
        text: String,
        mediaType: PostMediaType? = nil,
        mediaURL: String? = nil,
        reactions: ReactionSummary,
        commentsCount: Int
    ) {
        self.id = id
        self.author = author
        self.createdAt = createdAt
        self.text = text
        self.mediaType = mediaType
        self.mediaURL = mediaURL
        self.reactions = reactions
        self.commentsCount = commentsCount
    }
}

extension CommunityPost {
    static let samplePosts: [CommunityPost] = [
        CommunityPost(
            author: CommunityUser(
                id: UUID(),
                name: "Coach Ahmed",
                role: .coach,
                isFriend: true,
                isFollowing: true
            ),
            createdAt: Date().addingTimeInterval(-60 * 30),
            text: "جلسة اليوم كانت ممتازة 👊 ركزنا على الـ form في السكوات، النتيجة فرق كبير في التحكم.",
            mediaType: .image,
            mediaURL: nil,
            reactions: ReactionSummary(likeCount: 12, fireCount: 5, clapCount: 3, userReaction: nil),
            commentsCount: 4
        ),
        CommunityPost(
            author: CommunityUser(
                id: UUID(),
                name: "Sara",
                role: .athlete,
                isFriend: false,
                isFollowing: true
            ),
            createdAt: Date().addingTimeInterval(-60 * 90),
            text: "أول مرة أكمل أسبوع كامل بدون ما أفوّت تمرين واحد 🔥",
            mediaType: nil,
            mediaURL: nil,
            reactions: ReactionSummary(likeCount: 20, fireCount: 9, clapCount: 7, userReaction: nil),
            commentsCount: 8
        ),
        CommunityPost(
            author: CommunityUser(
                id: UUID(),
                name: "Coach Lina",
                role: .coach,
                isFriend: false,
                isFollowing: false
            ),
            createdAt: Date().addingTimeInterval(-60 * 180),
            text: "نصيحة اليوم: النوم الجيد = تقدم أسرع من التمرين بس بدون راحة.",
            mediaType: .image,
            mediaURL: nil,
            reactions: ReactionSummary(likeCount: 15, fireCount: 4, clapCount: 6, userReaction: nil),
            commentsCount: 3
        )
    ]
}

// MARK: - Conversations / Messages

struct Conversation: Identifiable, Codable {
    let id: UUID
    let withUser: CommunityUser
    let lastMessage: String
    let lastTimestamp: Date
    let unreadCount: Int
    let isCoach: Bool
    
    init(
        id: UUID = UUID(),
        withUser: CommunityUser,
        lastMessage: String,
        lastTimestamp: Date,
        unreadCount: Int,
        isCoach: Bool
    ) {
        self.id = id
        self.withUser = withUser
        self.lastMessage = lastMessage
        self.lastTimestamp = lastTimestamp
        self.unreadCount = unreadCount
        self.isCoach = isCoach
    }
}

extension Conversation {
    static let sampleConversations: [Conversation] = [
        Conversation(
            withUser: CommunityUser(
                id: UUID(),
                name: "Coach Ahmed",
                role: .coach,
                isFriend: true,
                isFollowing: true
            ),
            lastMessage: "لا تنسَ تسخين الركبة قبل الجلسة 👌",
            lastTimestamp: Date().addingTimeInterval(-60 * 10),
            unreadCount: 1,
            isCoach: true
        ),
        Conversation(
            withUser: CommunityUser(
                id: UUID(),
                name: "Sara",
                role: .athlete,
                isFriend: true,
                isFollowing: true
            ),
            lastMessage: "شكراً على تعديل البرنامج الغذائي 🙏",
            lastTimestamp: Date().addingTimeInterval(-60 * 50),
            unreadCount: 0,
            isCoach: false
        )
    ]
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
}

extension ChatMessage {
    static let sampleThread: [ChatMessage] = [
        ChatMessage(id: UUID(), text: "كيف كانت جلسة اليوم؟", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-60 * 30)),
        ChatMessage(id: UUID(), text: "ممتازة، بس حسيت ثقل في الركبة.", isFromCurrentUser: true, timestamp: Date().addingTimeInterval(-60 * 25)),
        ChatMessage(id: UUID(), text: "تمام، هنخفف الوزن في السكوات الجاية ونركز على الـ warm-up.", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-60 * 20))
    ]
}
