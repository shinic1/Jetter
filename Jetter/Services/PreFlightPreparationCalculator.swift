//
//  PreFlightPreparationCalculator.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct PreFlightPreparationCalculator {


    static func generate(
        for flightInfo: FlightInfo,
        severity: JetLagSeverity
    ) -> [PreparationDay] {
        // No preparation needed for minimal timezone shifts
        guard severity.timezoneShiftHours > 2 else {
            return []
        }

        // Determine number of preparation days based on severity
        let prepDays = determinePrepDays(for: severity)

        // Calculate daily shift amount (in hours)
        let totalShiftHours = Double(severity.timezoneShiftHours)
        let dailyShiftHours = totalShiftHours / Double(prepDays)

        var timeline: [PreparationDay] = []

        // Generate each day's recommendations
        for daysBefore in stride(from: prepDays, through: 1, by: -1) {
            let cumulativeShift = dailyShiftHours * Double(prepDays - daysBefore + 1)

            let day = generateDay(
                daysBeforeFlight: daysBefore,
                cumulativeShiftHours: cumulativeShift,
                direction: severity.direction,
                flightInfo: flightInfo,
                userBedtime: flightInfo.normalBedtime,
                userWakeTime: flightInfo.normalWakeTime
            )

            timeline.append(day)
        }

        return timeline
    }


    private static func determinePrepDays(for severity: JetLagSeverity) -> Int {
        switch severity.severityLevel {
        case .none:
            return 0
        case .mild: // 3-5 hours
            return 3
        case .moderate: // 6-9 hours
            return 5
        case .severe: // 10+ hours
            return 7
        }
    }

    private static func generateDay(
        daysBeforeFlight: Int,
        cumulativeShiftHours: Double,
        direction: JetLagSeverity.ShiftDirection,
        flightInfo: FlightInfo,
        userBedtime: Date,
        userWakeTime: Date
    ) -> PreparationDay {
        let calendar = Calendar.current

        // Extract user's normal bedtime and wake time hours/minutes
        let userBedtimeHour = calendar.component(.hour, from: userBedtime)
        let userBedtimeMinute = calendar.component(.minute, from: userBedtime)
        let userWakeHour = calendar.component(.hour, from: userWakeTime)
        let userWakeMinute = calendar.component(.minute, from: userWakeTime)

        // Get the target date (X days before flight)
        let targetDate = calendar.date(
            byAdding: .day,
            value: -daysBeforeFlight,
            to: flightInfo.departureDate
        ) ?? flightInfo.departureDate

        // Create base times for this date using user's normal schedule
        var baseBedtime = calendar.date(
            bySettingHour: userBedtimeHour,
            minute: userBedtimeMinute,
            second: 0,
            of: targetDate
        ) ?? targetDate

        var baseWakeTime = calendar.date(
            bySettingHour: userWakeHour,
            minute: userWakeMinute,
            second: 0,
            of: targetDate.addingTimeInterval(86400)
        ) ?? targetDate

        // Apply cumulative shift based on direction
        let shiftSeconds = cumulativeShiftHours * 3600

        switch direction {
        case .east:
            // Shift earlier (subtract time)
            baseBedtime = baseBedtime.addingTimeInterval(-shiftSeconds)
            baseWakeTime = baseWakeTime.addingTimeInterval(-shiftSeconds)
        case .west:
            // Shift later (add time)
            baseBedtime = baseBedtime.addingTimeInterval(shiftSeconds)
            baseWakeTime = baseWakeTime.addingTimeInterval(shiftSeconds)
        case .none:
            break
        }

        // Generate description
        let shiftDescription = generateShiftDescription(
            shiftHours: cumulativeShiftHours,
            direction: direction
        )

        let description = generateDescription(
            daysBeforeFlight: daysBeforeFlight,
            direction: direction
        )

        return PreparationDay(
            daysBeforeFlight: daysBeforeFlight,
            recommendedBedtime: baseBedtime,
            recommendedWakeTime: baseWakeTime,
            shiftAmount: shiftDescription,
            description: description
        )
    }

    private static func generateShiftDescription(
        shiftHours: Double,
        direction: JetLagSeverity.ShiftDirection
    ) -> String {
        let hours = Int(shiftHours)
        let minutes = Int((shiftHours - Double(hours)) * 60)

        let timeString: String
        if minutes > 0 {
            timeString = "\(hours)h \(minutes)m"
        } else {
            timeString = "\(hours)h"
        }

        switch direction {
        case .east:
            return "\(timeString) earlier"
        case .west:
            return "\(timeString) later"
        case .none:
            return "No change"
        }
    }

    private static func generateDescription(
        daysBeforeFlight: Int,
        direction: JetLagSeverity.ShiftDirection
    ) -> String {
        let action = direction == .east ? "earlier" : "later"

        if daysBeforeFlight == 1 {
            return "Final adjustment before your flight. Go to bed \(action) tonight."
        } else {
            return "Gradually shift your sleep schedule \(action)."
        }
    }
}
