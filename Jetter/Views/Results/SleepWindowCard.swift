import SwiftUI

struct SleepWindowCard: View {
    let schedule: SleepSchedule

    var body: some View {
        VStack(spacing: 16) {
            Label("Your Sleep Window", systemImage: "bed.double.fill")
                .font(JetterTypography.headline)
                .foregroundStyle(JetterColors.amberGold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .background(JetterColors.amberGold.opacity(0.2))

            if schedule.isTooShortForSleep {
                tooShortMessage
            } else {
                sleepColumns
            }
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var tooShortMessage: some View {
        VStack(spacing: 10) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 28))
                .foregroundStyle(JetterColors.amberGold)

            Text("Flight Too Short for Sleep")
                .font(JetterTypography.headline)
                .foregroundStyle(.primary)

            Text("Stay awake and adjust to local time on arrival. Get a good night's rest before your flight.")
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }

    private var sleepColumns: some View {
        HStack(spacing: 0) {
            instructionColumn(
                icon: "sun.max.fill",
                label: "Stay Awake",
                time: "First \(schedule.awakeBeforeSleepFormatted)",
                detail: schedule.hoursAfterTakeoffStart + " in",
                color: JetterColors.amberGold
            )

            Rectangle()
                .fill(.quaternary)
                .frame(width: 1)
                .padding(.vertical, 4)

            instructionColumn(
                icon: "moon.zzz.fill",
                label: "Sleep",
                time: schedule.sleepDurationFormatted,
                detail: "\(schedule.numberOfCycles) cycle\(schedule.numberOfCycles > 1 ? "s" : "")",
                color: JetterColors.sleepBlue
            )

            Rectangle()
                .fill(.quaternary)
                .frame(width: 1)
                .padding(.vertical, 4)

            instructionColumn(
                icon: "alarm.fill",
                label: "Wake Up",
                time: "\(schedule.hoursAfterTakeoffEnd) into flight",
                detail: "\(schedule.awakeAfterSleepFormatted) before landing",
                color: .green
            )
        }
    }

    private func instructionColumn(
        icon: String,
        label: String,
        time: String,
        detail: String,
        color: Color
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)

            Text(label)
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)

            Text(time)
                .font(JetterTypography.monoTime)
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.8)

            Text(detail)
                .font(JetterTypography.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
