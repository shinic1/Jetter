//
//  CircadianCalculator.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct CircadianCalculator {


    static func generateTimelineStates(
        for schedule: SleepSchedule,
        intervalMinutes: Int = 30
    ) -> [CircadianState] {
        var states: [CircadianState] = []

        let departureTime = schedule.departureTime
        let arrivalTime = schedule.arrivalLocalTime
        let flightDuration = arrivalTime.timeIntervalSince(departureTime)

        // Generate states at regular intervals
        let numberOfIntervals = Int(flightDuration / Double(intervalMinutes * 60))

        for i in 0...numberOfIntervals {
            let timeOffset = Double(i * intervalMinutes * 60)
            let currentTime = departureTime.addingTimeInterval(timeOffset)

            // Determine timezone (departure until landing, then arrival)
            let timeZone = currentTime < arrivalTime
                ? schedule.departureTimeZone
                : schedule.arrivalTimeZone

            // Calculate hours awake (simplified model)
            let hoursAwake = calculateHoursAwake(
                at: currentTime,
                sleepStart: schedule.sleepStartLocalDeparture,
                sleepEnd: schedule.sleepEndLocalDeparture,
                departureTime: departureTime
            )

            let state = CircadianState(
                time: currentTime,
                timeZone: timeZone,
                hoursAwake: hoursAwake
            )

            states.append(state)
        }

        return states
    }

    static func calculateState(
        at time: Date,
        schedule: SleepSchedule
    ) -> CircadianState {
        // Determine which timezone to use
        let timeZone: TimeZone
        if time < schedule.arrivalLocalTime {
            timeZone = schedule.departureTimeZone
        } else {
            timeZone = schedule.arrivalTimeZone
        }

        let hoursAwake = calculateHoursAwake(
            at: time,
            sleepStart: schedule.sleepStartLocalDeparture,
            sleepEnd: schedule.sleepEndLocalDeparture,
            departureTime: schedule.departureTime
        )

        return CircadianState(
            time: time,
            timeZone: timeZone,
            hoursAwake: hoursAwake
        )
    }

    static func sleepWindowAngles(for schedule: SleepSchedule) -> (start: Double, end: Double) {
        // IMPORTANT: Use departure timezone to match the clock display
        var calendar = Calendar.current
        calendar.timeZone = schedule.departureTimeZone

        // Extract time components in departure timezone
        let sleepStartHour = calendar.component(.hour, from: schedule.sleepStartLocalDeparture)
        let sleepStartMinute = calendar.component(.minute, from: schedule.sleepStartLocalDeparture)
        let sleepEndHour = calendar.component(.hour, from: schedule.sleepEndLocalDeparture)
        let sleepEndMinute = calendar.component(.minute, from: schedule.sleepEndLocalDeparture)

        // Convert to total minutes since midnight
        let startMinutesFromMidnight = Double(sleepStartHour * 60 + sleepStartMinute)
        let endMinutesFromMidnight = Double(sleepEndHour * 60 + sleepEndMinute)

        // Convert minutes to degrees (1440 minutes in 24 hours = 360 degrees)
        // So 1 minute = 0.25 degrees
        let sleepStartAngle = (startMinutesFromMidnight / 1440.0) * 360.0
        var sleepEndAngle = (endMinutesFromMidnight / 1440.0) * 360.0

        // Handle midnight crossover
        if sleepEndAngle <= sleepStartAngle {
            sleepEndAngle += 360.0
        }

        return (start: sleepStartAngle, end: sleepEndAngle)
    }

    static func timezoneShiftAngle(for severity: JetLagSeverity) -> Double {
        // Convert hours to degrees (360° = 24 hours, so 15° per hour)
        let shiftDegrees = Double(severity.timezoneShiftHours) * 15.0

        // Direction affects sign
        switch severity.direction {
        case .east:
            return shiftDegrees
        case .west:
            return -shiftDegrees
        case .none:
            return 0
        }
    }


    private static func calculateHoursAwake(
        at time: Date,
        sleepStart: Date,
        sleepEnd: Date,
        departureTime: Date
    ) -> Double {
        // Assume person woke up 2 hours before departure
        let wakeTime = departureTime.addingTimeInterval(-2 * 60 * 60)

        // If exploring times before wake time (when dragging clock backwards),
        // assume they just woke up (0 hours awake)
        if time < wakeTime {
            return 0
        }

        // If current time is before sleep start, simple calculation
        if time < sleepStart {
            let hoursAwake = time.timeIntervalSince(wakeTime) / 3600.0
            return max(0, hoursAwake)
        }

        // If during sleep, return hours before sleep
        if time >= sleepStart && time < sleepEnd {
            let hoursAwake = sleepStart.timeIntervalSince(wakeTime) / 3600.0
            return max(0, hoursAwake)
        }

        // If after sleep, subtract sleep duration
        if time >= sleepEnd {
            let totalAwakeTime = time.timeIntervalSince(wakeTime)
            let sleepDuration = sleepEnd.timeIntervalSince(sleepStart)
            let hoursAwake = (totalAwakeTime - sleepDuration) / 3600.0
            return max(0, hoursAwake)
        }

        // Default fallback
        return 0
    }
}
