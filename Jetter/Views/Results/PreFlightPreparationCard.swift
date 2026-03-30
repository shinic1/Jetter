import SwiftUI

struct PreFlightPreparationCard: View {
    let timeline: [PreparationDay]
    let daysUntilFlight: Int

    @State private var animateIn = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            header

            if shouldShowTimeline {
                // Timeline
                timelineView
            } else {
                // Too close to flight message
                tooCloseMessage
            }
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateIn = true
            }
        }
    }


    private var header: some View {
        HStack {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 20))
                .foregroundStyle(JetterColors.amberGold)

            Text("Prepare Before You Fly")
                .font(JetterTypography.headline)
                .foregroundStyle(.primary)

            Spacer()

            if !filteredTimeline.isEmpty {
                Text("\(filteredTimeline.count) days")
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(JetterColors.amberGold.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .opacity(animateIn ? 1 : 0)
    }


    private var timelineView: some View {
        VStack(spacing: 0) {
            ForEach(Array(filteredTimeline.enumerated()), id: \.element.id) { index, day in
                PreparationDayRow(
                    day: day,
                    isLast: index == filteredTimeline.count - 1
                )
                .opacity(animateIn ? 1 : 0)
                .offset(x: animateIn ? 0 : -20)
                .animation(
                    .easeOut(duration: 0.4).delay(Double(index) * 0.1 + 0.3),
                    value: animateIn
                )
            }
        }
    }


    private var tooCloseMessage: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 32))
                .foregroundStyle(.orange)

            Text("Your flight is in \(daysUntilFlight) day\(daysUntilFlight == 1 ? "" : "s")")
                .font(JetterTypography.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            Text("For best results, start adjusting your sleep schedule at least 3 days before departure. Focus on the sleep recommendations during your flight instead.")
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .opacity(animateIn ? 1 : 0)
    }


    private var shouldShowTimeline: Bool {
        daysUntilFlight >= 3 && !filteredTimeline.isEmpty
    }

    private var filteredTimeline: [PreparationDay] {
        timeline.filter { $0.daysBeforeFlight <= daysUntilFlight }
    }
}


struct PreparationDayRow: View {
    let day: PreparationDay
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(JetterColors.amberGold)
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(JetterColors.amberGold.opacity(0.3))
                        .frame(width: 2)
                }
            }

            
            VStack(alignment: .leading, spacing: 8) {
                // Day label
                Text(day.dayLabel)
                    .font(JetterTypography.subheadline)
                    .foregroundStyle(.primary)

                // Sleep times
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .font(.caption2)
                            .foregroundStyle(JetterColors.amberGold)

                        Text("Sleep at")
                            .font(JetterTypography.caption)
                            .foregroundStyle(.secondary)

                        Text(day.bedtimeString)
                            .font(JetterTypography.monoTime)
                            .foregroundStyle(.primary)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)

                        Text("Wake at")
                            .font(JetterTypography.caption)
                            .foregroundStyle(.secondary)

                        Text(day.wakeTimeString)
                            .font(JetterTypography.monoTime)
                            .foregroundStyle(.primary)
                    }
                }

                // Shift amount
                Text(day.shiftAmount)
                    .font(JetterTypography.caption)
                    .foregroundStyle(JetterColors.amberGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(JetterColors.amberGold.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.bottom, isLast ? 0 : 20)

            Spacer()
        }
    }
}

#Preview {
    let mockTimeline = [
        PreparationDay(
            daysBeforeFlight: 3,
            recommendedBedtime: Date().addingTimeInterval(-3 * 86400 + 79200), // 10 PM
            recommendedWakeTime: Date().addingTimeInterval(-3 * 86400 + 111600), // 7 AM next day
            shiftAmount: "1h earlier",
            description: "Gradually shift your sleep schedule earlier."
        ),
        PreparationDay(
            daysBeforeFlight: 2,
            recommendedBedtime: Date().addingTimeInterval(-2 * 86400 + 75600), // 9 PM
            recommendedWakeTime: Date().addingTimeInterval(-2 * 86400 + 108000), // 6 AM next day
            shiftAmount: "2h earlier",
            description: "Gradually shift your sleep schedule earlier."
        ),
        PreparationDay(
            daysBeforeFlight: 1,
            recommendedBedtime: Date().addingTimeInterval(-86400 + 72000), // 8 PM
            recommendedWakeTime: Date().addingTimeInterval(-86400 + 104400), // 5 AM next day
            shiftAmount: "3h earlier",
            description: "Final adjustment before your flight. Go to bed earlier tonight."
        )
    ]

    return VStack {
        PreFlightPreparationCard(
            timeline: mockTimeline,
            daysUntilFlight: 5
        )
        .padding()

        PreFlightPreparationCard(
            timeline: [],
            daysUntilFlight: 1
        )
        .padding()
    }
    .background(JetterColors.background)
}
