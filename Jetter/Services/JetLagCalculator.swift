//
//  JetLagCalculator.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct JetLagCalculator {

    static func calculate(
        departureTimeZone: TimeZone,
        arrivalTimeZone: TimeZone,
        departureDate: Date
    ) -> JetLagSeverity {
        let shiftHours = timezoneShift(
            from: departureTimeZone,
            to: arrivalTimeZone,
            on: departureDate
        )

        let absShift = abs(shiftHours)
        let direction = determineDirection(shiftHours: shiftHours)
        let level = severityLevel(hoursShift: absShift)
        let recovery = estimateRecovery(hoursShift: absShift, direction: direction)
        let desc = buildDescription(shift: absShift, direction: direction, level: level)

        return JetLagSeverity(
            timezoneShiftHours: absShift,
            direction: direction,
            severityLevel: level,
            estimatedRecoveryDays: recovery,
            description: desc
        )
    }

    static func timezoneShift(
        from departure: TimeZone,
        to arrival: TimeZone,
        on date: Date
    ) -> Int {
        let depOffset = departure.secondsFromGMT(for: date)
        let arrOffset = arrival.secondsFromGMT(for: date)
        var diffHours = (arrOffset - depOffset) / 3600

        // Normalize to shortest path around the globe
        if diffHours > 12 {
            diffHours -= 24
        } else if diffHours < -12 {
            diffHours += 24
        }

        return diffHours
    }


    private static func determineDirection(shiftHours: Int) -> JetLagSeverity.ShiftDirection {
        if shiftHours == 0 {
            return .none
        } else if shiftHours > 0 {
            return .east
        } else {
            return .west
        }
    }

    private static func severityLevel(hoursShift: Int) -> JetLagSeverity.SeverityLevel {
        switch hoursShift {
        case 0: return .none
        case 1...3: return .mild
        case 4...6: return .moderate
        default: return .severe
        }
    }

    private static func estimateRecovery(
        hoursShift: Int,
        direction: JetLagSeverity.ShiftDirection
    ) -> Int {
        guard hoursShift > 0 else { return 0 }

        let baseDays = Double(hoursShift) / 1.5
        let adjusted: Double
        switch direction {
        case .east:
            adjusted = baseDays * 1.25
        case .west:
            adjusted = baseDays
        case .none:
            return 0
        }

        return max(1, Int(adjusted.rounded(.up)))
    }

    private static func buildDescription(
        shift: Int,
        direction: JetLagSeverity.ShiftDirection,
        level: JetLagSeverity.SeverityLevel
    ) -> String {
        switch level {
        case .none:
            return "Minimal timezone adjustment needed. You should feel mostly normal."
        case .mild:
            return "A \(shift)-hour \(direction.rawValue)ward shift. Expect mild fatigue for 1–2 days."
        case .moderate:
            return "A \(shift)-hour \(direction.rawValue)ward shift. Plan for 3–5 days of adjustment."
        case .severe:
            return "A \(shift)-hour \(direction.rawValue)ward shift. Full adjustment may take a week or more."
        }
    }
}
