//
//  FlightInfo.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct FlightInfo: Hashable {
    var departureAirport: Airport?
    var arrivalAirport: Airport?
    var departureDate: Date = Date()
    var flightDurationMinutes: Int = 0

    // User's normal sleep schedule
    var normalBedtime: Date
    var normalWakeTime: Date

    // Meal preferences
    var mealPreference: MealPreference = MealPreference()

    var flightDuration: TimeInterval {
        TimeInterval(flightDurationMinutes * 60)
    }

    var isComplete: Bool {
        departureAirport != nil && arrivalAirport != nil && flightDurationMinutes > 0
    }

    var totalFlightDurationInHoursAndMinutes: String {
        let hours = flightDurationMinutes / 60
        let mins = flightDurationMinutes % 60
        if mins > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(hours)h"
    }


    init(
        departureAirport: Airport? = nil,
        arrivalAirport: Airport? = nil,
        departureDate: Date = Date(),
        flightDurationMinutes: Int = 0,
        normalBedtime: Date? = nil,
        normalWakeTime: Date? = nil
    ) {
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.departureDate = departureDate
        self.flightDurationMinutes = flightDurationMinutes

        
        let calendar = Calendar.current
        self.normalBedtime = normalBedtime ?? (calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date())
        self.normalWakeTime = normalWakeTime ?? (calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date())
    }
}


extension FlightInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case departureAirport
        case arrivalAirport
        case departureDate
        case flightDurationMinutes
        case normalBedtime
        case normalWakeTime
        case mealPreference
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        departureAirport = try container.decodeIfPresent(Airport.self, forKey: .departureAirport)
        arrivalAirport = try container.decodeIfPresent(Airport.self, forKey: .arrivalAirport)
        departureDate = try container.decodeIfPresent(Date.self, forKey: .departureDate) ?? Date()
        flightDurationMinutes = try container.decodeIfPresent(Int.self, forKey: .flightDurationMinutes) ?? 0

        // Provide defaults for sleep times if not present
        let calendar = Calendar.current
        normalBedtime = try container.decodeIfPresent(Date.self, forKey: .normalBedtime)
            ?? (calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date())
        normalWakeTime = try container.decodeIfPresent(Date.self, forKey: .normalWakeTime)
            ?? (calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date())

        // Provide default meal preference if not present
        mealPreference = try container.decodeIfPresent(MealPreference.self, forKey: .mealPreference) ?? MealPreference()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(departureAirport, forKey: .departureAirport)
        try container.encodeIfPresent(arrivalAirport, forKey: .arrivalAirport)
        try container.encode(departureDate, forKey: .departureDate)
        try container.encode(flightDurationMinutes, forKey: .flightDurationMinutes)
        try container.encode(normalBedtime, forKey: .normalBedtime)
        try container.encode(normalWakeTime, forKey: .normalWakeTime)
        try container.encode(mealPreference, forKey: .mealPreference)
    }
}
