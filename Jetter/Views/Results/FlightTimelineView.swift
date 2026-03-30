import SwiftUI

struct FlightTimelineView: View {
    let schedule: SleepSchedule
    let flightDuration: Int
    @Binding var animate: Bool

    @State private var showAwakeStart = false
    @State private var showSleep = false
    @State private var showAwakeEnd = false
    @State private var planePosition: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Flight Timeline", systemImage: "airplane")
                .font(JetterTypography.headline)
                .foregroundStyle(.primary)

            // Time labels
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Depart")
                        .font(JetterTypography.caption2)
                        .foregroundStyle(.tertiary)
                    Text(schedule.departureTimeFormatted)
                        .font(JetterTypography.monoTime)
                        .foregroundStyle(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Arrive")
                        .font(JetterTypography.caption2)
                        .foregroundStyle(.tertiary)
                    Text(schedule.arrivalTimeFormatted)
                        .font(JetterTypography.monoTime)
                        .foregroundStyle(.primary)
                }
            }

            // Timeline bar
            GeometryReader { geo in
                let totalWidth = geo.size.width

                ZStack(alignment: .leading) {
                    // Track background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(JetterColors.deepNavy.opacity(0.2))
                        .frame(height: 52)

                    // Awake before sleep
                    awakeSegment(
                        segment: .awakeStart,
                        totalWidth: totalWidth,
                        show: showAwakeStart
                    )

                    // Sleep block
                    sleepSegment(totalWidth: totalWidth)

                    // Awake after sleep
                    awakeSegment(
                        segment: .awakeEnd,
                        totalWidth: totalWidth,
                        show: showAwakeEnd
                    )

                    // Airplane icon sliding across - synced with tiles
                    Image(systemName: "airplane")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(JetterColors.amberGold)
                        .offset(x: planePosition * totalWidth - 10, y: -20)
                }
            }
            .frame(height: 52)

            // Legend
            HStack(spacing: 20) {
                legendItem(color: JetterColors.amberGold.opacity(0.5), label: "Awake")
                if !schedule.isTooShortForSleep {
                    legendItem(color: JetterColors.sleepBlue, label: "Sleep")
                }
            }
            .font(JetterTypography.caption2)

            // Duration label
            Text(schedule.flightDurationMinutes > 0
                 ? "Total flight: \(flightDuration / 60)h \(flightDuration % 60)m"
                 : "")
                .font(JetterTypography.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .onChange(of: animate) { _, newValue in
            if newValue {
                // Sequential animation: tiles and plane move in sync
                withAnimation(.easeOut(duration: 0.7)) {
                    showAwakeStart = true
                }
                withAnimation(.easeOut(duration: 0.7).delay(0.6)) {
                    showSleep = true
                }
                withAnimation(.easeOut(duration: 0.7).delay(1.2)) {
                    showAwakeEnd = true
                }

                // Plane moves smoothly across the entire timeline
                withAnimation(.easeInOut(duration: 1.9)) {
                    planePosition = 1.0
                }
            } else {
                showAwakeStart = false
                showSleep = false
                showAwakeEnd = false
                planePosition = 0
            }
        }
    }


    private func awakeSegment(
        segment: Segment,
        totalWidth: CGFloat,
        show: Bool
    ) -> some View {
        let width = show ? segmentWidth(segment, totalWidth) : 0
        let offset = segmentOffset(segment, totalWidth)

        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(JetterColors.amberGold.opacity(0.5))
                .frame(width: max(width, 0), height: 52)

            // Add time duration text if segment is wide enough
            if width > 40 {
                HStack(spacing: 2) {
                    // Only show icon if there's enough space
                    if width > 70 {
                        Image(systemName: segment == .awakeStart ? "sun.max.fill" : "sun.horizon.fill")
                            .font(.system(size: 10))
                    }
                    Text(segment == .awakeStart ? schedule.awakeBeforeSleepFormatted : schedule.awakeAfterSleepFormatted)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(.white)
            }
        }
        .offset(x: offset)
    }

    private func sleepSegment(totalWidth: CGFloat) -> some View {
        let width = showSleep ? segmentWidth(.sleep, totalWidth) : 0
        let offset = segmentOffset(.sleep, totalWidth)

        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [JetterColors.sleepBlue, JetterColors.deepNavy.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(width, 0), height: 52)

            if width > 40 {
                HStack(spacing: 2) {
                    if width > 60 {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 10))
                    }
                    Text(schedule.sleepDurationFormatted)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(.white)
            }
        }
        .offset(x: offset)
    }


    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }


    private enum Segment {
        case awakeStart, sleep, awakeEnd
    }

    private func segmentWidth(_ segment: Segment, _ total: CGFloat) -> CGFloat {
        switch segment {
        case .awakeStart:
            return total * schedule.awakeStartProportion
        case .sleep:
            return total * schedule.sleepProportion
        case .awakeEnd:
            return total * schedule.awakeEndProportion
        }
    }

    private func segmentOffset(_ segment: Segment, _ total: CGFloat) -> CGFloat {
        switch segment {
        case .awakeStart:
            return 0
        case .sleep:
            return total * schedule.awakeStartProportion
        case .awakeEnd:
            return total * (schedule.awakeStartProportion + schedule.sleepProportion)
        }
    }

}
