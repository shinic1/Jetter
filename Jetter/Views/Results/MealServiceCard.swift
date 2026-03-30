//
//  MealServiceCard.swift
//  Jetter
//
//  Created by Nico Bourel on 2/28/26.
//

import SwiftUI

struct MealServiceCard: View {
    let meals: [MealService]
    let schedule: SleepSchedule
    @Binding var mealPreference: MealPreference

    @State private var animateIn = false

    var body: some View {
        VStack(spacing: 16) {
            
            header

            if meals.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(meals.enumerated()), id: \.element.id) { index, meal in
                        mealRow(meal: meal)
                            .opacity(animateIn ? 1 : 0)
                            .offset(x: animateIn ? 0 : -20)
                            .animation(
                                .easeOut(duration: 0.4).delay(Double(index) * 0.1 + 0.2),
                                value: animateIn
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateIn = true
            }
        }
    }


    private var header: some View {
        HStack {
            Image(systemName: "fork.knife")
                .font(.system(size: 20))
                .foregroundStyle(.orange)

            Text("Meal Service")
                .font(JetterTypography.headline)
                .foregroundStyle(.primary)

            Spacer()

            if !meals.isEmpty {
                Text("\(meals.count) meal\(meals.count == 1 ? "" : "s")")
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .opacity(animateIn ? 1 : 0)
    }


    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "takeoutbag.and.cup.and.straw")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)

            Text("No meal service scheduled")
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .opacity(animateIn ? 1 : 0)
    }


    private func mealRow(meal: MealService) -> some View {
        let conflictsWithSleep = MealServiceCalculator.mealConflictsWithSleep(
            meal,
            schedule: schedule
        )

        return HStack(spacing: 16) {
            
            Image(systemName: meal.type.icon)
                .font(.system(size: 20))
                .foregroundStyle(conflictsWithSleep ? .orange : .green)
                .frame(width: 32)

            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(meal.type.rawValue)
                        .font(JetterTypography.subheadline)
                        .foregroundStyle(.primary)

                    if conflictsWithSleep {
                        Label("Potential conflict", systemImage: "exclamationmark.triangle.fill")
                            .font(JetterTypography.caption2)
                            .foregroundStyle(.orange)
                    }
                }

                Text(meal.formattedTimeAfterTakeoff)
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)

                // Local time
                Text(MealServiceCalculator.formatMealTime(meal))
                    .font(JetterTypography.monoTime)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

}

#Preview {
    @Previewable @State var mealPref = MealPreference()

    let mockSchedule = SleepSchedule(
        sleepStartAfterTakeoff: 3600,
        sleepEndAfterTakeoff: 7200,
        sleepDurationMinutes: 60,
        fallAsleepBufferMinutes: 15,
        numberOfCycles: 1,
        targetWakeLocalTime: Date(),
        sleepStartLocalDeparture: Date(),
        sleepEndLocalDeparture: Date(),
        arrivalLocalTime: Date(),
        departureTime: Date(),
        flightDurationMinutes: 180,
        departureTimeZone: .current,
        arrivalTimeZone: .current,
        scheduledMeals: [
            MealService(
                type: .dinner,
                scheduledTime: Date().addingTimeInterval(3600),
                timeAfterTakeoff: 3600,
                durationMinutes: 30
            )
        ]
    )

    return MealServiceCard(
        meals: mockSchedule.scheduledMeals,
        schedule: mockSchedule,
        mealPreference: $mealPref
    )
    .padding()
    .background(JetterColors.background)
}