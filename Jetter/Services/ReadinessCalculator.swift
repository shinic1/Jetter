//
//  ReadinessCalculator.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct ReadinessCalculator {

    static func calculate(
        flight: FlightInfo,
        schedule: SleepSchedule,
        severity: JetLagSeverity
    ) -> TravelReadiness {
        let sleepFactor = sleepQualityScore(schedule: schedule)
        let circadianFactor = circadianAlignmentScore(schedule: schedule, severity: severity)
        let feasibilityFactor = flightFeasibilityScore(flight: flight, schedule: schedule)
        let adaptationFactor = timezoneAdaptationScore(severity: severity)

        let factors = [sleepFactor, circadianFactor, feasibilityFactor, adaptationFactor]

        // Weighted average: sleep 35%, circadian 30%, feasibility 20%, adaptation 15%
        let weighted = Double(sleepFactor.score) * 0.35 +
                       Double(circadianFactor.score) * 0.30 +
                       Double(feasibilityFactor.score) * 0.20 +
                       Double(adaptationFactor.score) * 0.15

        let totalScore = Int(weighted.rounded())

        return TravelReadiness(
            score: totalScore,
            factors: factors,
            overallLabel: TravelReadiness.label(for: totalScore)
        )
    }


    private static func sleepQualityScore(schedule: SleepSchedule) -> TravelReadiness.ReadinessFactor {
        // Target: 6 hours of sleep for long flights
        let idealMinutes = 360.0
        let ratio = min(Double(schedule.sleepDurationMinutes) / idealMinutes, 1.0)
        let score = Int(ratio * 100)

        let tip: String
        if score >= 80 {
            tip = "You'll get excellent rest during this flight."
        } else if score >= 50 {
            tip = "Moderate rest. Consider sleeping shortly after boarding is complete."
        } else {
            tip = "Limited sleep opportunity. Prioritize sleep the night before your flight."
        }

        return TravelReadiness.ReadinessFactor(
            name: "Sleep Quality",
            score: score,
            tip: tip
        )
    }

    private static func circadianAlignmentScore(
        schedule: SleepSchedule,
        severity: JetLagSeverity
    ) -> TravelReadiness.ReadinessFactor {
        // How well does waking up at the target time align with destination rhythm?
        // Lower timezone shift = better alignment
        let shiftPenalty = min(severity.timezoneShiftHours * 8, 80)
        let score = max(100 - shiftPenalty, 20)

        // Bonus if the schedule places wake near a good destination hour
        let tip: String
        if score >= 70 {
            tip = "Your sleep window aligns well with your destination timezone."
        } else {
            tip = "The large timezone shift makes alignment challenging. Follow the schedule closely."
        }

        return TravelReadiness.ReadinessFactor(
            name: "Circadian Alignment",
            score: score,
            tip: tip
        )
    }

    private static func flightFeasibilityScore(
        flight: FlightInfo,
        schedule: SleepSchedule
    ) -> TravelReadiness.ReadinessFactor {
        // Longer flights give more room for rest
        let durationHours = Double(flight.flightDurationMinutes) / 60.0

        let score: Int
        if durationHours >= 10 {
            score = 95
        } else if durationHours >= 7 {
            score = 80
        } else if durationHours >= 5 {
            score = 60
        } else if durationHours >= 3 {
            score = 40
        } else {
            score = 25
        }

        let tip: String
        if durationHours >= 7 {
            tip = "A long flight gives you plenty of time to complete full sleep cycles."
        } else if durationHours >= 4 {
            tip = "Moderate flight length. You'll fit at least one full sleep cycle."
        } else {
            tip = "Short flight — consider a power nap rather than deep sleep."
        }

        return TravelReadiness.ReadinessFactor(
            name: "Flight Duration",
            score: score,
            tip: tip
        )
    }

    private static func timezoneAdaptationScore(
        severity: JetLagSeverity
    ) -> TravelReadiness.ReadinessFactor {
        let score: Int
        switch severity.severityLevel {
        case .none: score = 100
        case .mild: score = 75
        case .moderate: score = 45
        case .severe: score = 20
        }

        let tip: String
        switch severity.severityLevel {
        case .none:
            tip = "No significant jet lag expected."
        case .mild:
            tip = "Mild jet lag — you should adjust within a couple of days."
        case .moderate:
            tip = "Moderate jet lag. Seek natural light at your destination to speed recovery."
        case .severe:
            tip = "Severe timezone shift. Plan lighter activities for your first days."
        }

        return TravelReadiness.ReadinessFactor(
            name: "Timezone Shift",
            score: score,
            tip: tip
        )
    }
}
