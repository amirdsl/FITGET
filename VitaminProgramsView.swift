//
//  VitaminProgramsView.swift
//  FITGET
//

import SwiftUI

struct VitaminProgramsView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var isArabic: Bool { languageManager.currentLanguage == "ar" }
    
    let programs = VitaminProgram.samplePrograms
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(programs) { p in
                    NavigationLink {
                        VitaminProgramDetailView(program: p)
                    } label: {
                        vitaminProgramCard(p)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(isArabic ? "برامج الفيتامينات" : "Vitamin Programs")
    }
}

// MARK: - MODEL

struct VitaminProgram: Identifiable {
    let id = UUID()
    
    let titleAr: String
    let titleEn: String
    let goalAr: String
    let goalEn: String
    let schedule: [String]   // جدول أسبوعي
    
    static let samplePrograms: [VitaminProgram] = [
        VitaminProgram(
            titleAr: "برنامج الضخامة + القوة",
            titleEn: "Muscle & Strength Pack",
            goalAr: "زيادة القوة والكتلة العضلية",
            goalEn: "Strength and mass building",
            schedule: [
                "Creatine – 5g يوميًا",
                "Whey Protein – بعد التمرين",
                "Multivitamin – مع الفطور",
                "Omega-3 – مع الغداء"
            ]
        ),
        
        VitaminProgram(
            titleAr: "برنامج الحرق ورفع المناعة",
            titleEn: "Fat Loss + Immunity",
            goalAr: "رفع المناعة + زيادة الحرق",
            goalEn: "Increase metabolism & immunity",
            schedule: [
                "Vitamin C – صباحًا",
                "Green Tea Extract – قبل التمرين",
                "Omega-3 – مساءً",
                "Zinc – قبل النوم"
            ]
        )
    ]
}

// MARK: - UI COMPONENTS

func vitaminProgramCard(_ p: VitaminProgram) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(LanguageManager.shared.currentLanguage == "ar" ? p.titleAr : p.titleEn)
            .font(.headline)
            .foregroundColor(.white)
        
        Text(LanguageManager.shared.currentLanguage == "ar" ? p.goalAr : p.goalEn)
            .font(.caption)
            .foregroundColor(.orange)
        
        Text("Click to view full weekly supplement plan")
            .font(.caption2)
            .foregroundColor(.gray)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.blue.opacity(0.25))
    .cornerRadius(16)
}

struct VitaminProgramDetailView: View {
    
    let program: VitaminProgram
    
    var isArabic: Bool { LanguageManager.shared.currentLanguage == "ar" }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text(isArabic ? program.titleAr : program.titleEn)
                    .font(.title2.bold())
                
                Text(isArabic ? program.goalAr : program.goalEn)
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                Divider().padding(.vertical)
                
                ForEach(program.schedule, id: \.self) { day in
                    HStack(alignment: .top) {
                        Circle()
                            .fill(.orange)
                            .frame(width: 8, height: 8)
                        
                        Text(day)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer(minLength: 30)
            }
            .padding()
        }
        .navigationTitle(isArabic ? "تفاصيل البرنامج" : "Program Details")
    }
}

#Preview {
    NavigationStack {
        VitaminProgramsView()
            .environmentObject(LanguageManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
