//
//  TipsManager.swift
//  FITGET
//
//  Created on 25/11/2025.
//
import Combine
import Foundation

@MainActor
final class TipsManager: ObservableObject {
    static let shared = TipsManager()
    
    @Published private(set) var tips: [Tip] = []
    
    private init() {
        loadDefaultTips()
    }
    
    private func loadDefaultTips() {
        tips = [
            Tip(
                titleAR: "ابدأ بالحركة الخفيفة",
                titleEN: "Start with light movement",
                bodyAR: "5-10 دقائق من المشي أو الإحماء الخفيف قبل التمرين تساعد على تهيئة المفاصل والعضلات وتقلل خطر الإصابة.",
                bodyEN: "Doing 5–10 minutes of walking or light warm-up before your workout prepares your joints and muscles and reduces injury risk.",
                category: .training
            ),
            Tip(
                titleAR: "اشرب الماء بانتظام",
                titleEN: "Drink water regularly",
                bodyAR: "حاول شرب كوب ماء كل ساعتين خلال اليوم، ولا تنتظر حتى تشعر بالعطش الشديد.",
                bodyEN: "Aim to drink a glass of water every two hours during the day, and don't wait until you feel very thirsty.",
                category: .hydration
            ),
            Tip(
                titleAR: "نم مبكرًا قدر الإمكان",
                titleEN: "Sleep as early as you can",
                bodyAR: "جودة النوم أهم من عدد الساعات فقط. حاول تثبيت وقت نوم واستيقاظ محدد لتحسين التعافي والأداء.",
                bodyEN: "Sleep quality matters more than hours alone. Try to keep a consistent bedtime and wake-up time to improve recovery and performance.",
                category: .sleep
            ),
            Tip(
                titleAR: "اهتم بالبروتين",
                titleEN: "Prioritize protein",
                bodyAR: "تناول مصدر بروتين في كل وجبة يساعد في بناء العضلات والحفاظ عليها، خصوصًا مع التمرين.",
                bodyEN: "Having a source of protein in every meal helps build and preserve muscle, especially when you train regularly.",
                category: .nutrition
            ),
            Tip(
                titleAR: "ابدأ بعادات صغيرة",
                titleEN: "Start with tiny habits",
                bodyAR: "بدل تغيير كل شيء مرة واحدة، ركّز على عادة صغيرة قابلة للاستمرار مثل المشي 10 دقائق أو شرب ماء بعد الاستيقاظ.",
                bodyEN: "Instead of changing everything at once, focus on one small sustainable habit like 10 minutes of walking or drinking water after waking up.",
                category: .mindset
            ),
            Tip(
                titleAR: "يوم للراحة مهم",
                titleEN: "Rest days matter",
                bodyAR: "يوم الراحة ليس كسلًا، بل جزء مهم من خطة التمرين ليسمح للعضلات بالتعافي والنمو.",
                bodyEN: "Rest days are not laziness; they are an essential part of training that allow your muscles to recover and grow.",
                category: .recovery
            ),
            Tip(
                titleAR: "اجعل نصف طبقك خضار",
                titleEN: "Make half your plate veggies",
                bodyAR: "حاول أن يكون نصف طبقك اليومي من الخضروات المتنوعة للحصول على الألياف والفيتامينات والمعادن.",
                bodyEN: "Try to make half of your daily plate colorful vegetables to get enough fiber, vitamins, and minerals.",
                category: .nutrition
            )
        ]
    }
    
    func tips(for category: TipCategory?) -> [Tip] {
        guard let category else { return tips }
        return tips.filter { $0.category == category }
    }
    
    func randomTip() -> Tip? {
        tips.randomElement()
    }
}
