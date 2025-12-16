//
//  Exercise.swift
//  Fitget
//
//  Created on 21/11/2025.
//

import Foundation
import Combine

/// نموذج التمرين الأساسي داخل التطبيق
struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let slug: String

    let nameEn: String
    let nameAr: String

    let descriptionEn: String
    let descriptionAr: String

    /// المجموعة الرئيسية: chest, back, legs, shoulders, arms, core, full_body, cardio
    let muscleGroup: String

    /// المعدات: barbell, dumbbell, machine, cable, bodyweight, kettlebell, band
    let equipment: String

    /// مستوى الصعوبة: beginner, intermediate, advanced
    let difficulty: String

    /// هل التمرين بوزن الجسم فقط
    let isBodyweight: Bool

    /// العضلة الأساسية
    let primaryMuscle: String

    /// عضلات مساعدة
    let secondaryMuscles: [String]

    /// خطوات التنفيذ – إنجليزي
    let stepsEn: [String]

    /// خطوات التنفيذ – عربي
    let stepsAr: [String]

    /// نصائح تنفيذ – إنجليزي
    let tipsEn: [String]

    /// نصائح تنفيذ – عربي
    let tipsAr: [String]

    /// تقريب استهلاك السعرات في الدقيقة
    let caloriesPerMinute: Double

    /// هل التمرين Premium (مثلاً فيديو/شرح متقدم)
    let isPremium: Bool

    /// تاريخ إنشاء التمرين (يمكن استخدامه لاحقاً مع Supabase)
    let createdAt: Date

    init(
        id: UUID = UUID(),
        slug: String,
        nameEn: String,
        nameAr: String,
        descriptionEn: String,
        descriptionAr: String,
        muscleGroup: String,
        equipment: String,
        difficulty: String,
        isBodyweight: Bool,
        primaryMuscle: String,
        secondaryMuscles: [String] = [],
        stepsEn: [String],
        stepsAr: [String],
        tipsEn: [String],
        tipsAr: [String],
        caloriesPerMinute: Double,
        isPremium: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.slug = slug
        self.nameEn = nameEn
        self.nameAr = nameAr
        self.descriptionEn = descriptionEn
        self.descriptionAr = descriptionAr
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.difficulty = difficulty
        self.isBodyweight = isBodyweight
        self.primaryMuscle = primaryMuscle
        self.secondaryMuscles = secondaryMuscles
        self.stepsEn = stepsEn
        self.stepsAr = stepsAr
        self.tipsEn = tipsEn
        self.tipsAr = tipsAr
        self.caloriesPerMinute = caloriesPerMinute
        self.isPremium = isPremium
        self.createdAt = createdAt
    }
}

// MARK: - مكتبة تمارين جاهزة (أوفلاين)

extension Exercise {

    /// جميع التمارين الجاهزة داخل التطبيق (يمكن لاحقاً دمجها مع Supabase)
    static let all: [Exercise] = [
        // MARK: - Chest

        Exercise(
            slug: "barbell-bench-press",
            nameEn: "Barbell Bench Press",
            nameAr: "بنش بار مستوي",
            descriptionEn: "A fundamental compound exercise for building chest size and strength.",
            descriptionAr: "تمرين أساسي مركّب لبناء حجم وقوة عضلة الصدر.",
            muscleGroup: "chest",
            equipment: "barbell",
            difficulty: "intermediate",
            isBodyweight: false,
            primaryMuscle: "chest",
            secondaryMuscles: ["triceps", "front_shoulders"],
            stepsEn: [
                "Lie flat on the bench with your feet planted on the floor.",
                "Grip the bar slightly wider than shoulder-width.",
                "Lower the bar slowly to mid-chest level.",
                "Press the bar up while keeping your elbows under control."
            ],
            stepsAr: [
                "استلقِ على بنش مستوي مع تثبيت القدمين على الأرض.",
                "امسك البار أوسع قليلاً من عرض الكتفين.",
                "أنزل البار ببطء حتى منتصف الصدر.",
                "ادفع البار لأعلى مع التحكم في حركة الكوعين."
            ],
            tipsEn: [
                "Keep your shoulder blades retracted on the bench.",
                "Do not bounce the bar off your chest.",
                "Keep wrists straight and aligned with forearms."
            ],
            tipsAr: [
                "قُم بضم لوحي الكتف للخلف على البنش.",
                "لا تجعل البار يرتد عن الصدر.",
                "حافظ على الرسغ مستقيمًا في نفس خط الساعد."
            ],
            caloriesPerMinute: 7.5
        ),

        Exercise(
            slug: "incline-dumbbell-press",
            nameEn: "Incline Dumbbell Press",
            nameAr: "بنش دمبل مائل",
            descriptionEn: "Targets the upper chest and front delts.",
            descriptionAr: "يركّز على أعلى الصدر والأكتاف الأمامية.",
            muscleGroup: "chest",
            equipment: "dumbbell",
            difficulty: "intermediate",
            isBodyweight: false,
            primaryMuscle: "upper_chest",
            secondaryMuscles: ["front_shoulders", "triceps"],
            stepsEn: [
                "Set the bench to a 30–45° incline.",
                "Press the dumbbells from chest level up above the shoulders.",
                "Lower slowly with control."
            ],
            stepsAr: [
                "اضبط البنش على درجة ميل 30–45.",
                "ادفع الدمبل من مستوى الصدر إلى أعلى الكتفين.",
                "أنزل الدمبل ببطء مع التحكم في الحركة."
            ],
            tipsEn: [
                "Avoid excessive arching of the lower back.",
                "Keep elbows at about 45° from the body."
            ],
            tipsAr: [
                "تجنّب المبالغة في تقوّس أسفل الظهر.",
                "حافظ على الزاوية بين الكوع والجسم حوالي 45 درجة."
            ],
            caloriesPerMinute: 7.0
        ),

        Exercise(
            slug: "push-ups",
            nameEn: "Push Ups",
            nameAr: "تمرين الضغط",
            descriptionEn: "Bodyweight chest and triceps exercise suitable for all levels.",
            descriptionAr: "تمرين وزن الجسم للصدر والترايسبس مناسب لكل المستويات.",
            muscleGroup: "chest",
            equipment: "bodyweight",
            difficulty: "beginner",
            isBodyweight: true,
            primaryMuscle: "chest",
            secondaryMuscles: ["triceps", "front_shoulders", "core"],
            stepsEn: [
                "Place hands slightly wider than shoulder-width on the floor.",
                "Keep body in a straight line from head to heels.",
                "Lower chest toward the floor, then push back up."
            ],
            stepsAr: [
                "ضع اليدين أوسع قليلاً من عرض الكتفين على الأرض.",
                "حافظ على الجسم في خط مستقيم من الرأس حتى الكعبين.",
                "أنزل الصدر باتجاه الأرض ثم ادفع لأعلى."
            ],
            tipsEn: [
                "Do not let hips sag or pike up.",
                "Brace your core throughout the movement."
            ],
            tipsAr: [
                "لا تدع الحوض يهبط أو يرتفع بشكل مبالغ فيه.",
                "شد عضلات البطن طوال الحركة."
            ],
            caloriesPerMinute: 6.5,
            isPremium: false
        ),

        // MARK: - Back

        Exercise(
            slug: "pull-ups",
            nameEn: "Pull Ups",
            nameAr: "العقلة",
            descriptionEn: "A compound bodyweight exercise focusing on back width and biceps.",
            descriptionAr: "تمرين وزن الجسم مركّز على عضلات الظهر العريضة والبايسبس.",
            muscleGroup: "back",
            equipment: "bodyweight",
            difficulty: "advanced",
            isBodyweight: true,
            primaryMuscle: "lats",
            secondaryMuscles: ["biceps", "rear_shoulders"],
            stepsEn: [
                "Grab the bar with an overhand grip, slightly wider than shoulders.",
                "Start from a dead hang with arms straight.",
                "Pull your chest toward the bar until chin passes the bar.",
                "Lower under control back to full extension."
            ],
            stepsAr: [
                "امسك البار بقبضة علوية أوسع قليلاً من الكتفين.",
                "ابدأ من وضع تعليق والذراعان مستقيمتان.",
                "اسحب صدرك نحو البار حتى يتجاوز الذقن مستوى البار.",
                "انزل ببطء إلى وضع الذراع المستقيم."
            ],
            tipsEn: [
                "Think of driving elbows down, not pulling with the hands.",
                "Avoid excessive swinging or kipping."
            ],
            tipsAr: [
                "تخيّل أنك تدفع الكوعين إلى الأسفل بدل سحب الجسم باليدين.",
                "تجنّب التأرجح الزائد بالجسم."
            ],
            caloriesPerMinute: 8.0,
            isPremium: false
        ),

        Exercise(
            slug: "barbell-deadlift",
            nameEn: "Barbell Deadlift",
            nameAr: "ديدلفت بار",
            descriptionEn: "Full posterior chain strength exercise targeting back, glutes and hamstrings.",
            descriptionAr: "تمرين قوي للسلسلة الخلفية يستهدف الظهر والمؤخرة وأوتار الركبة.",
            muscleGroup: "back",
            equipment: "barbell",
            difficulty: "advanced",
            isBodyweight: false,
            primaryMuscle: "lower_back",
            secondaryMuscles: ["glutes", "hamstrings", "traps"],
            stepsEn: [
                "Stand with mid-foot under the bar and grip shoulder-width.",
                "Keep back neutral and chest up.",
                "Push the floor away and stand up with the bar.",
                "Lower the bar by hinging at the hips."
            ],
            stepsAr: [
                "قف بحيث يكون منتصف القدم تحت البار وامسكه بعرض الكتف تقريباً.",
                "حافظ على الظهر مستقيمًا والصدر مرفوعًا.",
                "ادفع الأرض بقدميك واتجه للوقوف رافعًا البار.",
                "أنزل البار عن طريق ثني مفصل الحوض للخلف."
            ],
            tipsEn: [
                "Keep the bar close to your body at all times.",
                "Do not round your lower back."
            ],
            tipsAr: [
                "حافظ على البار قريبًا من جسمك طوال الحركة.",
                "لا تقوّس أسفل الظهر."
            ],
            caloriesPerMinute: 10.0,
            isPremium: true
        ),

        // MARK: - Legs

        Exercise(
            slug: "back-squat",
            nameEn: "Back Squat",
            nameAr: "سكوات حر",
            descriptionEn: "King of leg exercises targeting quads, glutes and core.",
            descriptionAr: "ملك تمارين الأرجل، يستهدف الأفخاذ والمؤخرة والجذع.",
            muscleGroup: "legs",
            equipment: "barbell",
            difficulty: "intermediate",
            isBodyweight: false,
            primaryMuscle: "quads",
            secondaryMuscles: ["glutes", "hamstrings", "core"],
            stepsEn: [
                "Place the bar on your upper back, grip it firmly.",
                "Stand with feet shoulder-width apart.",
                "Sit back and down until thighs are at least parallel.",
                "Drive through mid-foot to stand up."
            ],
            stepsAr: [
                "ضع البار على أعلى الظهر وامسكه جيدًا.",
                "افتح القدمين بمستوى عرض الكتف تقريبًا.",
                "انزل بالمؤخرة للخلف وللأسفل حتى يصبح الفخذ موازيًا للأرض أو أقل.",
                "ادفع الأرض بقدميك للعودة لوضع الوقوف."
            ],
            tipsEn: [
                "Keep knees tracking over toes, not collapsing inward.",
                "Maintain a neutral spine throughout."
            ],
            tipsAr: [
                "اجعل الركبتين في نفس اتجاه أصابع القدم ولا تسمح بانهيارهما للداخل.",
                "حافظ على استقامة الظهر طوال الحركة."
            ],
            caloriesPerMinute: 9.0
        ),

        Exercise(
            slug: "bodyweight-squat",
            nameEn: "Bodyweight Squat",
            nameAr: "سكوات وزن الجسم",
            descriptionEn: "Beginner-friendly leg exercise that can be done anywhere.",
            descriptionAr: "تمرين أرجل مناسب للمبتدئين يمكن أداؤه في أي مكان.",
            muscleGroup: "legs",
            equipment: "bodyweight",
            difficulty: "beginner",
            isBodyweight: true,
            primaryMuscle: "quads",
            secondaryMuscles: ["glutes", "core"],
            stepsEn: [
                "Stand with feet slightly wider than shoulder-width.",
                "Sit back and down as if sitting on a chair.",
                "Go as low as comfortable, then stand back up."
            ],
            stepsAr: [
                "قف والقدمان أوسع قليلاً من الكتفين.",
                "انزل بالمؤخرة للخلف كأنك تجلس على كرسي.",
                "انزل للمدى المريح ثم اصعد مرة أخرى."
            ],
            tipsEn: [
                "Keep heels on the ground.",
                "Look forward, not at the floor."
            ],
            tipsAr: [
                "حافظ على الكعبين ثابتين على الأرض.",
                "انظر للأمام ولا تنظر إلى الأرض."
            ],
            caloriesPerMinute: 5.5
        ),

        // MARK: - Shoulders

        Exercise(
            slug: "overhead-press",
            nameEn: "Overhead Press",
            nameAr: "ضغط كتف بار",
            descriptionEn: "Compound shoulder press for overall shoulder strength.",
            descriptionAr: "تمرين مركّب لتقوية عضلات الكتف بالكامل.",
            muscleGroup: "shoulders",
            equipment: "barbell",
            difficulty: "intermediate",
            isBodyweight: false,
            primaryMuscle: "front_shoulders",
            secondaryMuscles: ["side_shoulders", "triceps"],
            stepsEn: [
                "Stand tall with the bar at shoulder level.",
                "Press the bar overhead until arms are locked.",
                "Lower under control back to the starting position."
            ],
            stepsAr: [
                "قف مستقيمًا والبار عند مستوى الكتف.",
                "ادفع البار للأعلى حتى استقامة الذراعين.",
                "أنزل البار ببطء إلى نقطة البداية."
            ],
            tipsEn: [
                "Keep your core braced to avoid over-arching the back.",
                "Move your head slightly back then through as the bar passes."
            ],
            tipsAr: [
                "شد عضلات البطن لتجنّب تقوّس أسفل الظهر.",
                "حرّك رأسك قليلاً للخلف ثم للأمام أثناء مرور البار."
            ],
            caloriesPerMinute: 7.0
        ),

        // MARK: - Arms

        Exercise(
            slug: "dumbbell-biceps-curl",
            nameEn: "Dumbbell Biceps Curl",
            nameAr: "بايسبس دمبل",
            descriptionEn: "Isolation exercise for the biceps.",
            descriptionAr: "تمرين عزل لعضلة البايسبس.",
            muscleGroup: "arms",
            equipment: "dumbbell",
            difficulty: "beginner",
            isBodyweight: false,
            primaryMuscle: "biceps",
            secondaryMuscles: [],
            stepsEn: [
                "Stand tall holding dumbbells by your sides.",
                "Curl the weights up while keeping elbows close to your body.",
                "Lower slowly back to the start."
            ],
            stepsAr: [
                "قف مستقيمًا والدمبل بجانب الجسم.",
                "اثنِ الكوعين لرفع الدمبل مع إبقاء الكوعين قريبين من الجذع.",
                "أنزل الدمبل ببطء إلى نقطة البداية."
            ],
            tipsEn: [
                "Avoid swinging your torso.",
                "Squeeze the biceps at the top."
            ],
            tipsAr: [
                "تجنّب التأرجح بالجسم أثناء الرفع.",
                "اضغط على عضلة البايسبس في أعلى الحركة."
            ],
            caloriesPerMinute: 4.5
        ),

        Exercise(
            slug: "triceps-rope-pushdown",
            nameEn: "Triceps Rope Pushdown",
            nameAr: "ترايسبس حبل",
            descriptionEn: "Great isolation exercise for triceps strength and shape.",
            descriptionAr: "تمرين ممتاز لعزل وتقوية عضلة الترايسبس.",
            muscleGroup: "arms",
            equipment: "cable",
            difficulty: "beginner",
            isBodyweight: false,
            primaryMuscle: "triceps",
            secondaryMuscles: [],
            stepsEn: [
                "Hold the rope attachment with elbows by your sides.",
                "Push the rope down until arms are extended.",
                "Control the return to starting position."
            ],
            stepsAr: [
                "أمسك الحبل والكوعان ملاصقان للجسم.",
                "ادفع الحبل للأسفل حتى استقامة الذراعين.",
                "ارجع ببطء لنقطة البداية."
            ],
            tipsEn: [
                "Do not let elbows move forward.",
                "Separate the rope slightly at the bottom for extra contraction."
            ],
            tipsAr: [
                "لا تدع الكوعين يتحركان للأمام.",
                "افتح الحبل قليلاً في أسفل الحركة لزيادة الانقباض."
            ],
            caloriesPerMinute: 4.0
        ),

        // MARK: - Core

        Exercise(
            slug: "plank",
            nameEn: "Plank",
            nameAr: "بلانك",
            descriptionEn: "Isometric core exercise improving stability and endurance.",
            descriptionAr: "تمرين ثبات لعضلات البطن يقوّي الاستقرار والتحمّل.",
            muscleGroup: "core",
            equipment: "bodyweight",
            difficulty: "beginner",
            isBodyweight: true,
            primaryMuscle: "abs",
            secondaryMuscles: ["lower_back", "shoulders"],
            stepsEn: [
                "Support your body on forearms and toes.",
                "Keep body in a straight line.",
                "Hold the position without letting hips drop."
            ],
            stepsAr: [
                "اسند جسمك على الساعدين وأصابع القدمين.",
                "حافظ على الجسم في خط مستقيم.",
                "اثبت في الوضعية دون هبوط الحوض."
            ],
            tipsEn: [
                "Brace your abs as if preparing for a punch.",
                "Do not hold your breath."
            ],
            tipsAr: [
                "شد عضلات البطن كما لو أنك تستعد لتلقي ضربة.",
                "لا تحبس أنفاسك خلال التمرين."
            ],
            caloriesPerMinute: 3.5
        ),

        // MARK: - Full Body / Cardio

        Exercise(
            slug: "burpees",
            nameEn: "Burpees",
            nameAr: "بيربيز",
            descriptionEn: "High-intensity full-body movement for conditioning.",
            descriptionAr: "حركة عالية الشدة لكامل الجسم لزيادة اللياقة والتحمّل.",
            muscleGroup: "full_body",
            equipment: "bodyweight",
            difficulty: "advanced",
            isBodyweight: true,
            primaryMuscle: "full_body",
            secondaryMuscles: ["legs", "chest", "core"],
            stepsEn: [
                "Start standing, drop into a squat position.",
                "Kick feet back into a plank and perform a push up (optional).",
                "Return feet to squat and explode up into a jump."
            ],
            stepsAr: [
                "ابدأ واقفًا ثم انزل لوضع السكوات.",
                "اركل القدمين للخلف لوضع البلانك، ويمكن إضافة ضغطه.",
                "ارجع لوضع السكوات ثم اقفز للأعلى بقوة."
            ],
            tipsEn: [
                "Start slowly and build up intensity.",
                "Maintain good plank position to protect lower back."
            ],
            tipsAr: [
                "ابدأ بسرعة منخفضة ثم زد الشدة تدريجيًا.",
                "حافظ على وضعية بلانك صحيحة لحماية أسفل الظهر."
            ],
            caloriesPerMinute: 12.0
        ),

        Exercise(
            slug: "treadmill-run",
            nameEn: "Treadmill Run",
            nameAr: "جري على السير",
            descriptionEn: "Steady-state cardio to improve endurance and burn calories.",
            descriptionAr: "كارديو ثابت لتحسين التحمل وحرق السعرات.",
            muscleGroup: "cardio",
            equipment: "machine",
            difficulty: "beginner",
            isBodyweight: false,
            primaryMuscle: "legs",
            secondaryMuscles: ["cardio_system"],
            stepsEn: [
                "Start with a light walk to warm up.",
                "Gradually increase speed to a light jog or run.",
                "Maintain steady breathing and posture."
            ],
            stepsAr: [
                "ابدأ بالمشي الخفيف للإحماء.",
                "ارفع السرعة تدريجيًا إلى هرولة أو جري خفيف.",
                "حافظ على تنفس منتظم ووضعية جيدة للجسم."
            ],
            tipsEn: [
                "Do not hold on to the handrails all the time.",
                "Increase speed or incline gradually."
            ],
            tipsAr: [
                "لا تتمسك بالمقابض طوال الوقت.",
                "ارفع السرعة أو درجة الميل تدريجيًا."
            ],
            caloriesPerMinute: 9.0
        )
    ]

    /// فلترة حسب مجموعة العضلة
    static func byMuscleGroup(_ key: String) -> [Exercise] {
        if key == "all" { return all }
        return all.filter { $0.muscleGroup == key }
    }
}
