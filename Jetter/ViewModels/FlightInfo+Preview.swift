//
//  FlightInfo+Preview.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation
import SwiftUI

extension FlightInfo {
    // Preview-only sample data for SwiftUI previews
    static let previewSample: FlightInfo = {
        let departureAirport = Airport(
            iataCode: "LAX",
            name: "Los Angeles International Airport",
            city: "Los Angeles",
            country: "United States",
            timezoneIdentifier: "America/Los_Angeles",
            latitude: 33.9425,
            longitude: -118.4081
        )
        let arrivalAirport = Airport(
            iataCode: "LHR",
            name: "Heathrow Airport",
            city: "London",
            country: "United Kingdom",
            timezoneIdentifier: "Europe/London",
            latitude: 51.4700,
            longitude: -0.4543
        )
        let departureDate = ISO8601DateFormatter().date(from: "2024-06-15T08:00:00Z") ?? Date()

        return FlightInfo(
            departureAirport: departureAirport,
            arrivalAirport: arrivalAirport,
            departureDate: departureDate,
            flightDurationMinutes: 660
        )
    }()
}
