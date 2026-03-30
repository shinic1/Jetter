//
//  AirportDatabase.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

final class AirportDatabase {
    static let shared = AirportDatabase()

    let airports: [Airport]

    private init() {
        guard let url = Bundle.main.url(forResource: "airports", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("airports.json not found in bundle")
        }
        self.airports = try! JSONDecoder().decode([Airport].self, from: data)
    }

    func search(query: String) -> [Airport] {
        guard !query.isEmpty else { return airports }
        let lowered = query.lowercased()
        return airports.filter { airport in
            airport.iataCode.lowercased().contains(lowered) ||
            airport.city.lowercased().contains(lowered) ||
            airport.name.lowercased().contains(lowered) ||
            airport.country.lowercased().contains(lowered)
        }
    }

    func airport(forCode code: String) -> Airport? {
        airports.first { $0.iataCode == code }
    }

    /// Returns the bundled airport for the given IATA code, or creates a minimal
    /// Airport from the provided API data if not found in the database.
    func airportOrCreate(iata: String, name: String? = nil, city: String? = nil, country: String? = nil, timezoneIdentifier: String? = nil, latitude: Double? = nil, longitude: Double? = nil) -> Airport {
        if let existing = airport(forCode: iata) {
            return existing
        }
        return Airport(
            iataCode: iata,
            name: name ?? iata,
            city: city ?? iata,
            country: country ?? "",
            timezoneIdentifier: timezoneIdentifier ?? TimeZone.current.identifier,
            latitude: latitude ?? 0,
            longitude: longitude ?? 0
        )
    }
}
