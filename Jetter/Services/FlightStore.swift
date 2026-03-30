//
//  FlightStore.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

@Observable
final class FlightStore {
    private(set) var flights: [SavedFlight] = []

    static let appGroupIdentifier = "group.com.jetter.flightdata"

    private let fileURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("saved_flights.json")
        print("FlightStore: Using file URL: \(url.path)")
        return url
    }()

    init() {
        print("FlightStore: Initializing...")
        load()
        print("FlightStore: Loaded \(flights.count) flights")

        // Add sample flights if empty
        if flights.isEmpty {
            addSampleFlights()
        }
    }


    @discardableResult
    func add(_ flightInfo: FlightInfo) -> SavedFlight {
        let saved = SavedFlight(flightInfo: flightInfo)
        flights.insert(saved, at: 0)
        print("FlightStore: Adding flight. Total flights: \(flights.count)")
        save()
        return saved
    }

    func delete(at offsets: IndexSet) {
        flights.remove(atOffsets: offsets)
        save()
    }

    func delete(_ flight: SavedFlight) {
        flights.removeAll { $0.id == flight.id }
        save()
    }


    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("FlightStore: No saved flights file found")
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            print("FlightStore: Read \(data.count) bytes from file")
            flights = try JSONDecoder().decode([SavedFlight].self, from: data)
            print("FlightStore: Successfully decoded \(flights.count) flights")
        } catch {
            print("FlightStore: Failed to load flights: \(error)")
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(flights)
            try data.write(to: fileURL, options: .atomic)
            print("FlightStore: Saved \(flights.count) flights to \(fileURL.path)")
        } catch {
            print("FlightStore: Failed to save flights: \(error)")
        }
    }


    private func addSampleFlights() {
        print("FlightStore: Creating sample flights...")

        // Create airports directly
        let jfk = Airport(
            iataCode: "JFK",
            name: "John F Kennedy Intl",
            city: "New York",
            country: "United States",
            timezoneIdentifier: "America/New_York",
            latitude: 40.6413,
            longitude: -73.7781
        )

        let lhr = Airport(
            iataCode: "LHR",
            name: "Heathrow",
            city: "London",
            country: "United Kingdom",
            timezoneIdentifier: "Europe/London",
            latitude: 51.470,
            longitude: -0.454
        )

        let sfo = Airport(
            iataCode: "SFO",
            name: "San Francisco Intl",
            city: "San Francisco",
            country: "United States",
            timezoneIdentifier: "America/Los_Angeles",
            latitude: 37.6213,
            longitude: -122.3790
        )

        let dxb = Airport(
            iataCode: "DXB",
            name: "Dubai Intl",
            city: "Dubai",
            country: "United Arab Emirates",
            timezoneIdentifier: "Asia/Dubai",
            latitude: 25.2532,
            longitude: 55.3657
        )

        // Moderate jet lag: NYC to London (5-hour time difference going east)
        let moderateFlight = FlightInfo(
            departureAirport: jfk,
            arrivalAirport: lhr,
            departureDate: Date().addingTimeInterval(86400 * 3), // 3 days from now
            flightDurationMinutes: 420 // 7 hours
        )

        // Severe jet lag: LA to Singapore (15-hour time difference)
        let severeFlight1 = FlightInfo(
            departureAirport: Airport(
                iataCode: "LAX",
                name: "Los Angeles Intl",
                city: "Los Angeles",
                country: "United States",
                timezoneIdentifier: "America/Los_Angeles",
                latitude: 33.9425,
                longitude: -118.4081
            ),
            arrivalAirport: Airport(
                iataCode: "SIN",
                name: "Singapore Changi",
                city: "Singapore",
                country: "Singapore",
                timezoneIdentifier: "Asia/Singapore",
                latitude: 1.3644,
                longitude: 103.9915
            ),
            departureDate: Date().addingTimeInterval(86400 * 7), // 1 week from now
            flightDurationMinutes: 1080 // 18 hours
        )

        // Severe jet lag: SF to Dubai (11-hour time difference)
        let severeFlight2 = FlightInfo(
            departureAirport: sfo,
            arrivalAirport: dxb,
            departureDate: Date().addingTimeInterval(86400 * 14), // 2 weeks from now
            flightDurationMinutes: 960 // 16 hours
        )

        // Add all three flights
        flights = [
            SavedFlight(flightInfo: moderateFlight),
            SavedFlight(flightInfo: severeFlight1),
            SavedFlight(flightInfo: severeFlight2)
        ]

        save()

        print("FlightStore: Added \(flights.count) sample flights")
    }
}
