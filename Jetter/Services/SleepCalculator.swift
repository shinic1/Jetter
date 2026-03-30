//
//  SleepCalculator.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct SleepCalculator {


    static let fallAsleepBuffer: TimeInterval = 20 * 60
    static let noSleepAfterTakeoff: TimeInterval = 45 * 60
    static let noSleepBeforeLanding: TimeInterval = 50 * 60
    static let cycleLength: TimeInterval = 90 * 60


    static func calculate(for flight: FlightInfo) -> SleepSchedule {
        guard let depAirport = flight.departureAirport,
              let arrAirport = flight.arrivalAirport else {
            // Return a minimal fallback schedule if airports are missing
            let now = Date()
            return SleepSchedule(
                sleepStartAfterTakeoff: noSleepAfterTakeoff,
                sleepEndAfterTakeoff: noSleepAfterTakeoff + cycleLength,
                sleepDurationMinutes: 90,
                fallAsleepBufferMinutes: 20,
                numberOfCycles: 1,
                targetWakeLocalTime: now,
                sleepStartLocalDeparture: now,
                sleepEndLocalDeparture: now,
                arrivalLocalTime: now,
                departureTime: now,
                flightDurationMinutes: 0,
                departureTimeZone: .current,
                arrivalTimeZone: .current,
                scheduledMeals: []  // No meals for fallback schedule
            )
        }

        let depTZ = depAirport.timeZone
        let arrTZ = arrAirport.timeZone
        let flightDuration = flight.flightDuration
        let takeoff = flight.departureDate

        // Step 1: Compute arrival time (Date is timezone-agnostic)
        let arrivalTime = takeoff.addingTimeInterval(flightDuration)

        // Step 2: Select target wake time
        let targetWake = selectTargetWakeTime(
            arrivalTime: arrivalTime,
            arrivalTimeZone: arrTZ
        )

        // Step 3 & 4: Determine available window
        let windowStart = noSleepAfterTakeoff
        let windowEnd = flightDuration - noSleepBeforeLanding
        let availableWindow = max(windowEnd - windowStart, 0)

        // Step 5: Choose cycles and build schedule
        let targetWakeAfterTakeoff = targetWake.timeIntervalSince(takeoff)
        let cycles = chooseSleepCycles(
            availableWindow: availableWindow,
            targetWakeAfterTakeoff: targetWakeAfterTakeoff,
            windowStart: windowStart,
            windowEnd: windowEnd
        )

        // Flight too short for sleep — return awake-only schedule with meal calculation
        if cycles == 0 {
            // Create preliminary schedule for meal calculation
            let preliminarySchedule = SleepSchedule(
                sleepStartAfterTakeoff: 0,
                sleepEndAfterTakeoff: 0,
                sleepDurationMinutes: 0,
                fallAsleepBufferMinutes: 0,
                numberOfCycles: 0,
                targetWakeLocalTime: arrivalTime,
                sleepStartLocalDeparture: takeoff,
                sleepEndLocalDeparture: takeoff,
                arrivalLocalTime: arrivalTime,
                departureTime: takeoff,
                flightDurationMinutes: flight.flightDurationMinutes,
                departureTimeZone: depTZ,
                arrivalTimeZone: arrTZ,
                scheduledMeals: []
            )

            // Calculate meals even for short flights
            let meals = MealServiceCalculator.calculateMealServices(
                for: flight,
                schedule: preliminarySchedule
            )

            return SleepSchedule(
                sleepStartAfterTakeoff: 0,
                sleepEndAfterTakeoff: 0,
                sleepDurationMinutes: 0,
                fallAsleepBufferMinutes: 0,
                numberOfCycles: 0,
                targetWakeLocalTime: arrivalTime,
                sleepStartLocalDeparture: takeoff,
                sleepEndLocalDeparture: takeoff,
                arrivalLocalTime: arrivalTime,
                departureTime: takeoff,
                flightDurationMinutes: flight.flightDurationMinutes,
                departureTimeZone: depTZ,
                arrivalTimeZone: arrTZ,
                scheduledMeals: meals
            )
        }

        let sleepDuration = TimeInterval(cycles) * cycleLength
        let totalSleepBlock = sleepDuration + fallAsleepBuffer

        // Position the sleep block so wake aligns with target
        var sleepEnd = targetWakeAfterTakeoff
        var sleepStart = sleepEnd - totalSleepBlock

        // Clamp to available window
        if sleepStart < windowStart {
            sleepStart = windowStart
            sleepEnd = sleepStart + totalSleepBlock
        }
        if sleepEnd > windowEnd {
            sleepEnd = windowEnd
            sleepStart = max(windowStart, sleepEnd - totalSleepBlock)
        }

        // Ensure we don't have negative values
        sleepStart = max(0, sleepStart)
        sleepEnd = max(sleepStart + cycleLength, sleepEnd)
        sleepEnd = min(sleepEnd, flightDuration)

        let actualSleepMinutes = Int((sleepEnd - sleepStart - fallAsleepBuffer) / 60)
        let clampedSleepMinutes = max(actualSleepMinutes, Int(cycleLength / 60))

        let sleepStartDate = takeoff.addingTimeInterval(sleepStart)
        let sleepEndDate = takeoff.addingTimeInterval(sleepEnd)

        // Create preliminary schedule for meal calculation
        let preliminarySchedule = SleepSchedule(
            sleepStartAfterTakeoff: sleepStart,
            sleepEndAfterTakeoff: sleepEnd,
            sleepDurationMinutes: clampedSleepMinutes,
            fallAsleepBufferMinutes: Int(fallAsleepBuffer / 60),
            numberOfCycles: cycles,
            targetWakeLocalTime: targetWake,
            sleepStartLocalDeparture: sleepStartDate,
            sleepEndLocalDeparture: sleepEndDate,
            arrivalLocalTime: arrivalTime,
            departureTime: takeoff,
            flightDurationMinutes: flight.flightDurationMinutes,
            departureTimeZone: depTZ,
            arrivalTimeZone: arrTZ,
            scheduledMeals: []  // Temporary empty meals
        )

        // Calculate meal services based on flight and sleep schedule
        let meals = MealServiceCalculator.calculateMealServices(
            for: flight,
            schedule: preliminarySchedule
        )

        // Return final schedule with meals
        return SleepSchedule(
            sleepStartAfterTakeoff: sleepStart,
            sleepEndAfterTakeoff: sleepEnd,
            sleepDurationMinutes: clampedSleepMinutes,
            fallAsleepBufferMinutes: Int(fallAsleepBuffer / 60),
            numberOfCycles: cycles,
            targetWakeLocalTime: targetWake,
            sleepStartLocalDeparture: sleepStartDate,
            sleepEndLocalDeparture: sleepEndDate,
            arrivalLocalTime: arrivalTime,
            departureTime: takeoff,
            flightDurationMinutes: flight.flightDurationMinutes,
            departureTimeZone: depTZ,
            arrivalTimeZone: arrTZ,
            scheduledMeals: meals
        )
    }


    private static func selectTargetWakeTime(
        arrivalTime: Date,
        arrivalTimeZone: TimeZone
    ) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = arrivalTimeZone

        let hour = calendar.component(.hour, from: arrivalTime)

        if hour >= 6 && hour < 16 {
            // Daytime arrival: wake 90 min before landing
            return arrivalTime.addingTimeInterval(-90 * 60)
        } else if hour >= 16 && hour < 22 {
            // Evening arrival: wake 3 hours before landing
            return arrivalTime.addingTimeInterval(-3 * 60 * 60)
        } else {
            // Late night / early morning arrival: target 7:00 AM next day
            var components = calendar.dateComponents([.year, .month, .day], from: arrivalTime)
            components.hour = 7
            components.minute = 0
            components.second = 0

            if hour >= 22 {
                // Past midnight target: next day
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: arrivalTime) {
                    components = calendar.dateComponents([.year, .month, .day], from: nextDay)
                    components.hour = 7
                    components.minute = 0
                }
            }

            if let targetDate = calendar.date(from: components) {
                return targetDate
            }
            // Fallback: wake 90 min before arrival
            return arrivalTime.addingTimeInterval(-90 * 60)
        }
    }

    private static func chooseSleepCycles(
        availableWindow: TimeInterval,
        targetWakeAfterTakeoff: TimeInterval,
        windowStart: TimeInterval,
        windowEnd: TimeInterval
    ) -> Int {
        // Minimum sleep block is 1 cycle + fall-asleep buffer
        let minimumSleepBlock = cycleLength + fallAsleepBuffer
        guard availableWindow >= minimumSleepBlock else { return 0 }

        for cycles in stride(from: 4, through: 1, by: -1) {
            let sleepNeeded = TimeInterval(cycles) * cycleLength + fallAsleepBuffer
            let sleepEnd = targetWakeAfterTakeoff
            let sleepStart = sleepEnd - sleepNeeded

            if sleepNeeded <= availableWindow &&
               sleepStart >= windowStart &&
               sleepEnd <= windowEnd {
                return cycles
            }
        }

        // If target wake doesn't work, try fitting anywhere in the window
        for cycles in stride(from: 4, through: 1, by: -1) {
            let sleepNeeded = TimeInterval(cycles) * cycleLength + fallAsleepBuffer
            if sleepNeeded <= availableWindow {
                return cycles
            }
        }

        return 0
    }
}
