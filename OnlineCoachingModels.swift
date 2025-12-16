//
//  OnlineCoachingModels.swift
//  FITGET
//
//  Path: FITGET/Models/Coaching/OnlineCoachingModels.swift
//
import Combine
import Foundation

// حالة طلب التدريب الأونلاين
enum OnlineCoachingRequestStatus: String, Codable, CaseIterable {
    case pending      // قيد المراجعة
    case accepted     // تم القبول من المدرب
    case active       // متابعة نشطة
    case completed    // انتهى البرنامج
    case cancelled    // ملغي

    var localizedTitle: String {
        switch self {
        case .pending:
            return "قيد المراجعة"
        case .accepted:
            return "تم القبول"
        case .active:
            return "نشط"
        case .completed:
            return "مكتمل"
        case .cancelled:
            return "ملغي"
        }
    }
}

// نموذج طلب تدريب أونلاين واحد
struct OnlineCoachingRequest: Identifiable, Codable, Equatable {
    let id: UUID
    let coachName: String
    let coachSpecialty: String
    let goalDescription: String
    let preferredContact: String
    let createdAt: Date
    var status: OnlineCoachingRequestStatus

    init(
        id: UUID = UUID(),
        coachName: String,
        coachSpecialty: String,
        goalDescription: String,
        preferredContact: String,
        createdAt: Date = Date(),
        status: OnlineCoachingRequestStatus = .pending
    ) {
        self.id = id
        self.coachName = coachName
        self.coachSpecialty = coachSpecialty
        self.goalDescription = goalDescription
        self.preferredContact = preferredContact
        self.createdAt = createdAt
        self.status = status
    }
}

// عينات للاختبار (يمكن حذفها في الإنتاج)
extension OnlineCoachingRequest {
    static let sampleRequests: [OnlineCoachingRequest] = [
        OnlineCoachingRequest(
            coachName: "كابتن أحمد",
            coachSpecialty: "بناء عضل ولياقة عامة",
            goalDescription: "أريد بناء عضل وزيادة القوة مع نزول بسيط في الدهون خلال ٣ شهور.",
            preferredContact: "محادثة داخل التطبيق",
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 3),
            status: .active
        ),
        OnlineCoachingRequest(
            coachName: "كابتن سارة",
            coachSpecialty: "نزول وزن ونحت الجسم",
            goalDescription: "هدفي نزول ٦-٨ كجم قبل الصيف مع تحسين الشكل العام.",
            preferredContact: "مكالمة فيديو",
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 10),
            status: .completed
        )
    ]
}
