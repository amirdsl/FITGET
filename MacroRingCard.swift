//
//  MacroRingCard.swift
//  FITGET
//

import SwiftUI

/// بطاقة لعرض توزيع الماكروز + السعرات لليوم.
/// تستخدم MacroBreakdown (protein / carbs / fats / calories)
struct MacroRingCard: View {

    let macros: MacroBreakdown
    let isArabic: Bool

    private var totalGrams: Double {
        Double(macros.protein + macros.carbs + macros.fats)
    }

    private var proteinRatio: Double {
        guard totalGrams > 0 else { return 0 }
        return Double(macros.protein) / totalGrams
    }

    private var carbsRatio: Double {
        guard totalGrams > 0 else { return 0 }
        return Double(macros.carbs) / totalGrams
    }

    private var fatsRatio: Double {
        guard totalGrams > 0 else { return 0 }
        return Double(macros.fats) / totalGrams
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isArabic ? "الماكروز اليوم" : "Today’s macros")
                .font(.caption)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)

                // بروتين
                Circle()
                    .trim(from: 0, to: proteinRatio)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.6)]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // كربوهيدرات
                Circle()
                    .trim(from: proteinRatio, to: proteinRatio + carbsRatio)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.6)]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // دهون
                Circle()
                    .trim(from: proteinRatio + carbsRatio, to: 1.0)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.6)]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(macros.calories)")
                        .font(.system(size: 16, weight: .bold))
                    Text("kcal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 6) {
                macroDot(color: .green, text: "P \(macros.protein)g")
                macroDot(color: .blue, text: "C \(macros.carbs)g")
                macroDot(color: .orange, text: "F \(macros.fats)g")
            }
            .font(.caption2)
        }
    }

    private func macroDot(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
        }
    }
}

#Preview {
    MacroRingCard(
        macros: MacroBreakdown(
            protein: 120,
            carbs: 200,
            fats: 60,
            calories: 2200
        ),
        isArabic: false
    )
}
