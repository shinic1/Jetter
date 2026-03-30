//
//  CircadianTimelineViewModel.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

@Observable
class CircadianTimelineViewModel {

    let schedule: SleepSchedule
    let severity: JetLagSeverity


    private(set) var timelineStates: [CircadianState] = []

    var selectedTime: Date?

    var currentState: CircadianState?

    var isInteracting: Bool = false

    var lastDragAngle: Double = 0


    var sleepWindowStartHour: Int {
        var calendar = Calendar.current
        calendar.timeZone = schedule.departureTimeZone
        let hour = calendar.component(.hour, from: schedule.sleepStartLocalDeparture)
        return hour
    }

    var sleepWindowStartMinute: Int {
        var calendar = Calendar.current
        calendar.timeZone = schedule.departureTimeZone
        return calendar.component(.minute, from: schedule.sleepStartLocalDeparture)
    }

    var sleepWindowEndHour: Int {
        var calendar = Calendar.current
        calendar.timeZone = schedule.departureTimeZone
        let hour = calendar.component(.hour, from: schedule.sleepEndLocalDeparture)
        return hour
    }

    var sleepWindowEndMinute: Int {
        var calendar = Calendar.current
        calendar.timeZone = schedule.departureTimeZone
        return calendar.component(.minute, from: schedule.sleepEndLocalDeparture)
    }


    var sleepWindowAngles: (start: Double, end: Double) {
        CircadianCalculator.sleepWindowAngles(for: schedule)
    }

    var timezoneShiftAngle: Double {
        CircadianCalculator.timezoneShiftAngle(for: severity)
    }

    var selectedTimeDisplay: String {
        guard let state = currentState else { return "" }
        let formatter = DateFormatter()
        formatter.timeZone = state.timeZone
        formatter.timeStyle = .short
        return formatter.string(from: state.time)
    }

    var alertnessDisplay: String {
        guard let state = currentState else { return "—" }
        return "\(Int(state.alertness))%"
    }

    var sleepPressureDisplay: String {
        guard let state = currentState else { return "—" }
        let level: String
        if state.sleepPressure < 30 {
            level = "Low"
        } else if state.sleepPressure < 60 {
            level = "Moderate"
        } else {
            level = "High"
        }
        return "\(level) (\(Int(state.sleepPressure))%)"
    }

    var isInSleepWindow: Bool {
        guard let state = currentState else { return false }
        let hour = state.hourOfDay
        let minute = state.minuteOfHour

        // Convert to total minutes for more accurate comparison
        let currentTotalMinutes = hour * 60 + minute
        let startTotalMinutes = sleepWindowStartHour * 60 + sleepWindowStartMinute
        let endTotalMinutes = sleepWindowEndHour * 60 + sleepWindowEndMinute

        // Handle sleep window crossing midnight
        if endTotalMinutes < startTotalMinutes {
            // Crosses midnight (e.g., 22:30 to 06:30)
            return currentTotalMinutes >= startTotalMinutes || currentTotalMinutes < endTotalMinutes
        } else {
            // Same day (e.g., 14:30 to 18:30)
            return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes < endTotalMinutes
        }
    }

    var alertnessColor: Color {
        guard let state = currentState else { return .gray }
        if state.alertness > 70 {
            return JetterColors.amberGold
        } else if state.alertness > 40 {
            return .orange
        } else {
            return .red.opacity(0.7)
        }
    }


    init(schedule: SleepSchedule, severity: JetLagSeverity) {
        self.schedule = schedule
        self.severity = severity
        self.generateTimeline()

        // Set initial state to departure time
        self.currentState = CircadianCalculator.calculateState(
            at: schedule.departureTime,
            schedule: schedule
        )
    }


    func generateTimeline() {
        self.timelineStates = CircadianCalculator.generateTimelineStates(
            for: schedule,
            intervalMinutes: 30
        )
    }

    func updateState(for angle: Double) {
        // Normalize angle to 0-360 range
        var normalizedAngle = angle
        while normalizedAngle < 0 {
            normalizedAngle += 360.0
        }
        while normalizedAngle >= 360.0 {
            normalizedAngle -= 360.0
        }

        // Convert angle to minutes from midnight
        // 360° = 1440 minutes (24 hours)
        // So: angle / 360 * 1440 = minutes from midnight
        let totalMinutes = (normalizedAngle / 360.0) * 1440.0
        let hours = Int(totalMinutes / 60.0)
        let minutes = Int(totalMinutes.truncatingRemainder(dividingBy: 60.0))

        // Create a date for this time of day in departure timezone
        var calendar = Calendar.current
        calendar.timeZone = schedule.departureTimeZone

        // Use departure date as base
        var components = calendar.dateComponents(
            [.year, .month, .day],
            from: schedule.departureTime
        )

        // Set time components
        components.hour = hours
        components.minute = minutes
        components.second = 0

        // Create the date and update state
        if let time = calendar.date(from: components) {
            self.selectedTime = time
            self.currentState = CircadianCalculator.calculateState(
                at: time,
                schedule: schedule
            )
        }
    }

    func resetToInitial() {
        self.selectedTime = nil
        self.currentState = CircadianCalculator.calculateState(
            at: schedule.departureTime,
            schedule: schedule
        )
        self.isInteracting = false
    }

    func closestState(for angle: Double) -> CircadianState? {
        return timelineStates.min(by: { state1, state2 in
            let diff1 = abs(state1.clockAngle - angle)
            let diff2 = abs(state2.clockAngle - angle)
            return diff1 < diff2
        })
    }
}
