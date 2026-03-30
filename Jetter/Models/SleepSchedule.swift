//
//  SleepSchedule.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct SleepSchedule {
    let sleepStartAfterTakeoff: TimeInterval
    let sleepEndAfterTakeoff: TimeInterval
    let sleepDurationMinutes: Int
    let fallAsleepBufferMinutes: Int
    let numberOfCycles: Int

    let targetWakeLocalTime: Date
    let sleepStartLocalDeparture: Date
    let sleepEndLocalDeparture: Date
    let arrivalLocalTime: Date

    let departureTime: Date
    let flightDurationMinutes: Int
    let departureTimeZone: TimeZone
    let arrivalTimeZone: TimeZone

    // Meal services
    let scheduledMeals: [MealService]

    var isTooShortForSleep: Bool { numberOfCycles == 0 }


    var sleepDurationFormatted: String {
        let hours = sleepDurationMinutes / 60
        let mins = sleepDurationMinutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        }
        return "\(mins)m"
    }

    var hoursAfterTakeoffStart: String {
        formatInterval(sleepStartAfterTakeoff)
    }

    var hoursAfterTakeoffEnd: String {
        formatInterval(sleepEndAfterTakeoff)
    }

    var awakeBeforeSleepMinutes: Int {
        Int(sleepStartAfterTakeoff / 60)
    }

    var awakeBeforeSleepFormatted: String {
        formatInterval(sleepStartAfterTakeoff)
    }

    var awakeAfterSleepMinutes: Int {
        let totalFlight = TimeInterval(flightDurationMinutes * 60)
        return Int((totalFlight - sleepEndAfterTakeoff) / 60)
    }

    var awakeAfterSleepFormatted: String {
        let totalFlight = TimeInterval(flightDurationMinutes * 60)
        return formatInterval(totalFlight - sleepEndAfterTakeoff)
    }

    var departureTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeZone = departureTimeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: departureTime)
    }

    var arrivalTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeZone = arrivalTimeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: arrivalLocalTime)
    }


    var awakeStartProportion: Double {
        let total = TimeInterval(flightDurationMinutes * 60)
        guard total > 0 else { return 0 }
        return sleepStartAfterTakeoff / total
    }

    var sleepProportion: Double {
        let total = TimeInterval(flightDurationMinutes * 60)
        guard total > 0 else { return 0 }
        return (sleepEndAfterTakeoff - sleepStartAfterTakeoff) / total
    }

    var awakeEndProportion: Double {
        let total = TimeInterval(flightDurationMinutes * 60)
        guard total > 0 else { return 0 }
        return (total - sleepEndAfterTakeoff) / total
    }


    private func formatInterval(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval / 60)
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        }
        return "\(mins)m"
    }
}
