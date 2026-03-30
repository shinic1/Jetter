import SwiftUI

struct CircadianTimelineCard: View {
    let schedule: SleepSchedule
    let severity: JetLagSeverity

    @State private var viewModel: CircadianTimelineViewModel
    @State private var animateIn = false
    @State private var showDetail = false

    init(schedule: SleepSchedule, severity: JetLagSeverity) {
        self.schedule = schedule
        self.severity = severity
        self._viewModel = State(initialValue: CircadianTimelineViewModel(
            schedule: schedule,
            severity: severity
        ))
    }

    var body: some View {
        VStack(spacing: 16) {
            
            header

            // Clock face
            clockSection

            // Current state info
            if let state = viewModel.currentState {
                stateInfo(state)
            }

            // Timezone shift indicator
            if severity.timezoneShiftHours != 0 {
                TimezoneShiftIndicator(severity: severity, animate: animateIn)
            }

            // Tap hint
            tapHint
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
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            CircadianTimelineDetailView(
                schedule: schedule,
                severity: severity,
                viewModel: viewModel
            )
        }
    }


    private var header: some View {
        HStack {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(JetterColors.amberGold)

            Text("Energy Timeline")
                .font(JetterTypography.headline)
                .foregroundStyle(.primary)

            Spacer()

            // Timezone indicator
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 10))
                Text(timezoneAbbreviation)
                    .font(JetterTypography.caption)
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.15))
            .clipShape(Capsule())
        }
        .opacity(animateIn ? 1 : 0)
    }


    private var clockSection: some View {
        CircadianClockFace(
            schedule: schedule,
            severity: severity,
            currentAngle: viewModel.currentState?.clockAngle ?? 0,
            sleepWindowAngles: viewModel.sleepWindowAngles,
            timezoneShiftAngle: viewModel.timezoneShiftAngle,
            isInteracting: $viewModel.isInteracting
        )
        .frame(height: 280)
        .padding(.vertical, 8)
        .scaleEffect(animateIn ? 1 : 0.8)
        .opacity(animateIn ? 1 : 0)
    }


    private func stateInfo(_ state: CircadianState) -> some View {
        VStack(spacing: 12) {
            // Time and energy level
            HStack(spacing: 16) {
                // Time display
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time")
                        .font(JetterTypography.caption)
                        .foregroundStyle(.secondary)

                    Text(viewModel.selectedTimeDisplay)
                        .font(JetterTypography.monoTime)
                        .foregroundStyle(.primary)
                }

                Divider()
                    .frame(height: 30)

                // Energy level
                VStack(alignment: .leading, spacing: 4) {
                    Text("Energy")
                        .font(JetterTypography.caption)
                        .foregroundStyle(.secondary)

                    Text(energyLevelText(for: state))
                        .font(JetterTypography.subheadline)
                        .foregroundStyle(energyLevelColor(for: state))
                }

                Spacer()
            }

            // Color-coded energy bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    // Filled bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(energyLevelColor(for: state))
                        .frame(width: geometry.size.width * (state.alertness / 100.0))
                }
            }
            .frame(height: 8)

            // Sleep window indicator (fixed height to prevent jumpiness)
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.caption2)
                    .foregroundStyle(JetterColors.amberGold)
                Text("Sleep window")
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(viewModel.isInSleepWindow ? 1 : 0)
        }
        .padding(12)
        .background(JetterColors.background.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .opacity(animateIn ? 1 : 0)
    }


    private var timezoneAbbreviation: String {
        // Get the departure timezone abbreviation
        let formatter = DateFormatter()
        formatter.timeZone = schedule.departureTimeZone
        formatter.dateFormat = "zzz"  // Short timezone name (e.g., "PST", "EDT")
        return formatter.string(from: schedule.departureTime)
    }


    private var tapHint: some View {
        Text("Tap to explore")
            .font(JetterTypography.caption)
            .foregroundStyle(.tertiary)
            .opacity(animateIn ? 1 : 0)
    }


    private func energyLevelText(for state: CircadianState) -> String {
        if state.alertness > 70 {
            return "Wide Awake"
        } else if state.alertness > 40 {
            return "Getting Tired"
        } else {
            return "Very Sleepy"
        }
    }

    private func energyLevelColor(for state: CircadianState) -> Color {
        if state.alertness > 70 {
            return .green
        } else if state.alertness > 40 {
            return .orange
        } else {
            return .red
        }
    }

}


struct CircadianTimelineDetailView: View {
    let schedule: SleepSchedule
    let severity: JetLagSeverity
    @State var viewModel: CircadianTimelineViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Interactive clock
                interactiveClock

                // Current state info
                if let state = viewModel.currentState {
                    currentStateCard(state)
                }

                // Simple instruction
                instructionCard

                Spacer()
            }
            .padding(20)
            .background(JetterColors.background.ignoresSafeArea())
            .navigationTitle("Energy Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(JetterColors.amberGold)
                }
            }
        }
    }


    private var interactiveClock: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Drag around the clock")
                    .font(JetterTypography.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                // Timezone indicator
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                    Text(timezoneAbbreviation)
                        .font(JetterTypography.caption)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.15))
                .clipShape(Capsule())
            }

            GeometryReader { geometry in
                CircadianClockFace(
                    schedule: schedule,
                    severity: severity,
                    currentAngle: viewModel.currentState?.clockAngle ?? 0,
                    sleepWindowAngles: viewModel.sleepWindowAngles,
                    timezoneShiftAngle: viewModel.timezoneShiftAngle,
                    isInteracting: $viewModel.isInteracting
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !viewModel.isInteracting {
                                HapticManager.selection()
                            }
                            viewModel.isInteracting = true
                            let angle = calculateAngle(from: value.location, in: geometry.size)
                            viewModel.updateState(for: angle)
                            // Haptic tick every 15 degrees (each hour)
                            let hourAngle = Int(angle / 15)
                            if Int(viewModel.lastDragAngle / 15) != hourAngle {
                                HapticManager.tick()
                            }
                            viewModel.lastDragAngle = angle
                        }
                        .onEnded { _ in
                            viewModel.isInteracting = false
                            HapticManager.selection()
                        }
                )
            }
            .frame(height: 350)
        }
        .padding(16)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }


    private func currentStateCard(_ state: CircadianState) -> some View {
        VStack(spacing: 16) {
            // Time display - larger
            VStack(spacing: 4) {
                Text("Time")
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)

                Text(viewModel.selectedTimeDisplay)
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
            }

            Divider()

            // Energy level with bar
            VStack(spacing: 8) {
                Text(energyLevelText(for: state))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(energyLevelColor(for: state))

                // Energy bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))

                        RoundedRectangle(cornerRadius: 6)
                            .fill(energyLevelColor(for: state))
                            .frame(width: geometry.size.width * (state.alertness / 100.0))
                    }
                }
                .frame(height: 12)
            }

            // Sleep window indicator (fixed height to prevent jumpiness)
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(JetterColors.amberGold)
                Text("You should be sleeping at this time")
                    .font(JetterTypography.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
            .opacity(viewModel.isInSleepWindow ? 1 : 0)
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }


    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Golden arc shows when you should sleep", systemImage: "moon.zzz.fill")
                .foregroundStyle(JetterColors.amberGold)
            Label("Dashed arc shows timezone shift", systemImage: "arrow.right.circle")
                .foregroundStyle(.blue)
        }
        .font(JetterTypography.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(JetterColors.cardBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }


    private func calculateAngle(from location: CGPoint, in size: CGSize) -> Double {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let radians = atan2(dy, dx)
        var degrees = radians * 180.0 / Double.pi
        degrees += 90.0
        if degrees < 0 {
            degrees += 360.0
        }
        return degrees
    }

    private func energyLevelText(for state: CircadianState) -> String {
        if state.alertness > 70 {
            return "Wide Awake"
        } else if state.alertness > 40 {
            return "Getting Tired"
        } else {
            return "Very Sleepy"
        }
    }

    private func energyLevelColor(for state: CircadianState) -> Color {
        if state.alertness > 70 {
            return .green
        } else if state.alertness > 40 {
            return .orange
        } else {
            return .red
        }
    }

    private var timezoneAbbreviation: String {
        // Get the departure timezone abbreviation
        let formatter = DateFormatter()
        formatter.timeZone = schedule.departureTimeZone
        formatter.dateFormat = "zzz"  // Short timezone name
        return formatter.string(from: schedule.departureTime)
    }
}

#Preview {
    CircadianTimelineCard(
        schedule: FlightInfo.preview.sleepSchedule,
        severity: FlightInfo.preview.jetLagSeverity
    )
    .padding()
    .background(JetterColors.background)
}
