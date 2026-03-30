//
//  MealServiceCalculator.swift
//  Jetter
//
//  Created by Nico Bourel on 2/28/26.
//

import Foundation

struct MealServiceCalculator {


    // Typical meal service timing
    private static let dinnerServiceAfterTakeoff: TimeInterval = 60 * 60 // 1 hour
    private static let breakfastBeforeLanding: TimeInterval = 90 * 60 // 1.5 hours
    private static let lunchServiceAfterTakeoff: TimeInterval = 60 * 60 // 1 hour
    private static let snackServiceMidFlight: TimeInterval = 4 * 60 * 60 // 4 hours

    // Service durations
    private static let mealServiceDuration: Int = 30 // 30 minutes typical
    private static let snackServiceDuration: Int = 15 // 15 minutes for snacks

    // Minimum flight durations for meal service
    private static let minimumFlightForDinner: TimeInterval = 3 * 60 * 60 // 3 hours
    private static let minimumFlightForBreakfast: TimeInterval = 5 * 60 * 60 // 5 hours
    private static let minimumFlightForLunch: TimeInterval = 2 * 60 * 60 // 2 hours
    private static let minimumFlightForSnack: TimeInterval = 8 * 60 * 60 // 8 hours


    static func calculateMealServices(
        for flight: FlightInfo,
        schedule: SleepSchedule
    ) -> [MealService] {
        var meals: [MealService] = []

        guard let depAirport = flight.departureAirport,
              let arrAirport = flight.arrivalAirport else {
            return meals
        }

        let flightDuration = flight.flightDuration
        let departureTime = flight.departureDate
        let arrivalTime = departureTime.addingTimeInterval(flightDuration)

        // Get departure and arrival hours in local time
        var depCalendar = Calendar.current
        depCalendar.timeZone = depAirport.timeZone
        let depHour = depCalendar.component(.hour, from: departureTime)

        var arrCalendar = Calendar.current
        arrCalendar.timeZone = arrAirport.timeZone
        let arrHour = arrCalendar.component(.hour, from: arrivalTime)

        // DINNER SERVICE
        // Serve dinner if departing in evening (5 PM - 11 PM)
        if depHour >= 17 && depHour < 23 && flightDuration >= minimumFlightForDinner {
            let dinnerTime = departureTime.addingTimeInterval(dinnerServiceAfterTakeoff)

            // Check if dinner conflicts with sleep start
            let dinnerEnd = dinnerTime.addingTimeInterval(TimeInterval(mealServiceDuration * 60))
            if dinnerEnd <= schedule.sleepStartLocalDeparture || schedule.isTooShortForSleep {
                meals.append(MealService(
                    type: .dinner,
                    scheduledTime: dinnerTime,
                    timeAfterTakeoff: dinnerServiceAfterTakeoff,
                    durationMinutes: mealServiceDuration
                ))
            }
        }

        // LUNCH SERVICE
        // Serve lunch if departing midday (11 AM - 2 PM)
        if depHour >= 11 && depHour < 14 && flightDuration >= minimumFlightForLunch {
            let lunchTime = departureTime.addingTimeInterval(lunchServiceAfterTakeoff)
            meals.append(MealService(
                type: .lunch,
                scheduledTime: lunchTime,
                timeAfterTakeoff: lunchServiceAfterTakeoff,
                durationMinutes: mealServiceDuration
            ))
        }

        // BREAKFAST SERVICE
        // Serve breakfast if arriving in morning (6 AM - 11 AM) on overnight/long flights
        if arrHour >= 6 && arrHour < 11 && flightDuration >= minimumFlightForBreakfast {
            let breakfastTime = arrivalTime.addingTimeInterval(-breakfastBeforeLanding)
            let breakfastAfterTakeoff = breakfastTime.timeIntervalSince(departureTime)

            // Check if breakfast comes after sleep window or if no sleep scheduled
            if schedule.isTooShortForSleep || breakfastTime >= schedule.sleepEndLocalDeparture {
                meals.append(MealService(
                    type: .breakfast,
                    scheduledTime: breakfastTime,
                    timeAfterTakeoff: breakfastAfterTakeoff,
                    durationMinutes: mealServiceDuration
                ))
            }
        }

        // SNACK SERVICE
        // On very long flights (8+ hours), add mid-flight snack
        if flightDuration >= minimumFlightForSnack {
            let midpoint = flightDuration / 2
            let snackTime = departureTime.addingTimeInterval(midpoint)

            // Only add if not during sleep window
            if schedule.isTooShortForSleep ||
               snackTime < schedule.sleepStartLocalDeparture ||
               snackTime > schedule.sleepEndLocalDeparture {
                meals.append(MealService(
                    type: .snack,
                    scheduledTime: snackTime,
                    timeAfterTakeoff: midpoint,
                    durationMinutes: snackServiceDuration
                ))
            }
        }

        return meals.sorted { $0.timeAfterTakeoff < $1.timeAfterTakeoff }
    }

    static func mealConflictsWithSleep(
        _ meal: MealService,
        schedule: SleepSchedule
    ) -> Bool {
        // No conflict if flight is too short for sleep
        if schedule.isTooShortForSleep {
            return false
        }

        let mealEnd = meal.scheduledTime.addingTimeInterval(
            TimeInterval(meal.durationMinutes * 60)
        )

        // Meal conflicts if it overlaps with sleep window or prevents
        // getting to sleep on time (30 min buffer before sleep)
        let sleepPrepTime = schedule.sleepStartLocalDeparture.addingTimeInterval(-30 * 60)

        return meal.scheduledTime < schedule.sleepEndLocalDeparture &&
               mealEnd > sleepPrepTime
    }

    static func formatMealTime(_ meal: MealService) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: meal.scheduledTime)
    }
}