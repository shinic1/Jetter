//
//  FlightLookupResult.swift
//  Jetter
//

import Foundation

struct LookupAirportInfo {
    let iata: String
    let name: String?
    let city: String?
    let country: String?
    let timezoneIdentifier: String?
    let latitude: Double?
    let longitude: Double?
}

struct FlightLookupResult {
    let flightNumber: String
    let airlineName: String?
    let departureAirport: LookupAirportInfo
    let arrivalAirport: LookupAirportInfo
    let scheduledDeparture: Date
    let scheduledArrival: Date
    let durationMinutes: Int

    var departureIATA: String { departureAirport.iata }
    var arrivalIATA: String { arrivalAirport.iata }

    static let sample = FlightLookupResult(
        flightNumber: "BA117",
        airlineName: "British Airways",
        departureAirport: LookupAirportInfo(iata: "LHR", name: "Heathrow", city: "London", country: "GB", timezoneIdentifier: "Europe/London", latitude: 51.47, longitude: -0.46),
        arrivalAirport: LookupAirportInfo(iata: "JFK", name: "John F Kennedy", city: "New York", country: "US", timezoneIdentifier: "America/New_York", latitude: 40.64, longitude: -73.78),
        scheduledDeparture: Date(),
        scheduledArrival: Date().addingTimeInterval(8 * 3600 + 30 * 60),
        durationMinutes: 510
    )
}

extension FlightLookupResult {
    /// Parses AeroDataBox date strings like "2026-03-26 12:00Z" or ISO 8601 variants
    private static func parseDate(_ string: String) -> Date? {
        // Normalize literal "Z" to "+0000" for DateFormatter compatibility
        let normalized = string.hasSuffix("Z")
            ? String(string.dropLast()) + "+0000"
            : string

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")

        // AeroDataBox format: "2026-03-26 12:00+0000"
        df.dateFormat = "yyyy-MM-dd HH:mmZ"
        if let date = df.date(from: normalized) { return date }

        // With seconds: "2026-03-26 12:00:00+0000"
        df.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        if let date = df.date(from: normalized) { return date }

        // Fallback to ISO 8601
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        return iso.date(from: string)
    }

    private static func airportInfo(from airport: AeroDataBoxAirport) -> LookupAirportInfo? {
        guard let iata = airport.iata else { return nil }
        return LookupAirportInfo(
            iata: iata,
            name: airport.name,
            city: airport.municipalityName,
            country: airport.countryCode,
            timezoneIdentifier: airport.timeZone,
            latitude: airport.location?.lat,
            longitude: airport.location?.lon
        )
    }

    init?(from flight: AeroDataBoxFlight) {
        guard let depAirport = Self.airportInfo(from: flight.departure.airport),
              let arrAirport = Self.airportInfo(from: flight.arrival.airport),
              let depTimeStr = flight.departure.scheduledTime?.utc,
              let arrTimeStr = flight.arrival.scheduledTime?.utc else {
            return nil
        }

        guard let departure = Self.parseDate(depTimeStr),
              let arrival = Self.parseDate(arrTimeStr) else {
            return nil
        }

        self.flightNumber = flight.number.replacingOccurrences(of: " ", with: "")
        self.airlineName = flight.airline?.name
        self.departureAirport = depAirport
        self.arrivalAirport = arrAirport
        self.scheduledDeparture = departure
        self.scheduledArrival = arrival
        self.durationMinutes = Int(arrival.timeIntervalSince(departure) / 60)
    }
}
