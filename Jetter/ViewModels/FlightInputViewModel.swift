//
//  FlightInputViewModel.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

enum FlightLookupError: LocalizedError {
    case flightNotFound
    case networkUnavailable
    case rateLimited
    case invalidFlightNumber
    case airportNotInDatabase(String)
    case serverError

    var errorDescription: String? {
        switch self {
        case .flightNotFound:
            return "Flight not found for this date"
        case .networkUnavailable:
            return "No internet connection"
        case .rateLimited:
            return "Too many lookups. Please wait a moment"
        case .invalidFlightNumber:
            return "Invalid flight number format"
        case .airportNotInDatabase(let code):
            return "Airport \(code) not recognized"
        case .serverError:
            return "Flight lookup temporarily unavailable"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .flightNotFound:
            return "Check the flight number and date, or enter details manually"
        case .networkUnavailable:
            return "Check your connection or enter details manually"
        case .rateLimited:
            return "Try again shortly or enter details manually"
        case .invalidFlightNumber:
            return "Use format like BA117 or AA100"
        case .airportNotInDatabase:
            return "Select the airport manually"
        case .serverError:
            return "Try again later or enter details manually"
        }
    }
}

@Observable
final class FlightInputViewModel {
    enum EntryMode: String, CaseIterable {
        case flightNumber = "Flight Number"
        case manual = "Manual Entry"
    }

    var flightInfo = FlightInfo()

    var showDeparturePicker = false
    var showArrivalPicker = false

    // Entry mode
    var entryMode: EntryMode = .flightNumber

    // Flight lookup state
    var flightNumberText: String = ""
    var flightDate: Date = Date()
    var isLookingUp: Bool = false
    var lookupError: FlightLookupError? = nil
    var lookupResult: FlightLookupResult? = nil
    var hasAutoFilled: Bool = false

    private var flightStore: FlightStore?
    private var flightLookupService: FlightLookupServiceProtocol?
    private var lookupCache: [String: FlightLookupResult] = [:]

    var hasBothAirports: Bool {
        flightInfo.departureAirport != nil && flightInfo.arrivalAirport != nil
    }

    var timezoneShiftDescription: String? {
        guard let dep = flightInfo.departureAirport,
              let arr = flightInfo.arrivalAirport else { return nil }
        let shift = JetLagCalculator.timezoneShift(
            from: dep.timeZone,
            to: arr.timeZone,
            on: flightInfo.departureDate
        )
        let absShift = abs(shift)
        if absShift == 0 { return "Same timezone" }
        let direction = shift > 0 ? "ahead" : "behind"
        return "\(absShift)h \(direction)"
    }

    var routeSummary: String? {
        guard let dep = flightInfo.departureAirport,
              let arr = flightInfo.arrivalAirport else { return nil }
        return "\(dep.iataCode) → \(arr.iataCode)"
    }

    var estimatedFlightMinutes: Int? {
        guard let dep = flightInfo.departureAirport,
              let arr = flightInfo.arrivalAirport else { return nil }
        return FlightTimeEstimator.estimate(from: dep, to: arr)
    }

    var normalizedFlightNumber: String {
        flightNumberText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .uppercased()
    }

    var isValidFlightNumber: Bool {
        let pattern = "^[A-Z]{2,3}\\d{1,4}$"
        return normalizedFlightNumber.range(of: pattern, options: .regularExpression) != nil
    }

    func applyEstimateIfNeeded() {
        if flightInfo.flightDurationMinutes == 0, let est = estimatedFlightMinutes {
            flightInfo.flightDurationMinutes = est
        }
    }

    func configure(store: FlightStore, lookupService: FlightLookupServiceProtocol? = nil) {
        self.flightStore = store
        self.flightLookupService = lookupService
    }

    func lookupFlight() async {
        let flightNumber = normalizedFlightNumber

        guard isValidFlightNumber else {
            lookupError = .invalidFlightNumber
            return
        }

        guard let service = flightLookupService else {
            lookupError = .serverError
            return
        }

        // Check cache
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let cacheKey = "\(flightNumber)-\(dateFormatter.string(from: flightDate))"

        if let cached = lookupCache[cacheKey] {
            applyLookupResult(cached)
            return
        }

        isLookingUp = true
        lookupError = nil

        do {
            let result = try await service.lookupFlight(number: flightNumber, date: flightDate)
            lookupCache[cacheKey] = result
            applyLookupResult(result)
            HapticManager.success()
        } catch let error as FlightLookupError {
            lookupError = error
            HapticManager.warning()
        } catch {
            if (error as NSError).domain == NSURLErrorDomain {
                lookupError = .networkUnavailable
            } else {
                lookupError = .serverError
            }
            HapticManager.warning()
        }

        isLookingUp = false
    }

    private func applyLookupResult(_ result: FlightLookupResult) {
        lookupResult = result

        let db = AirportDatabase.shared
        let dep = result.departureAirport
        let arr = result.arrivalAirport
        flightInfo.departureAirport = db.airportOrCreate(
            iata: dep.iata, name: dep.name, city: dep.city, country: dep.country,
            timezoneIdentifier: dep.timezoneIdentifier, latitude: dep.latitude, longitude: dep.longitude
        )
        flightInfo.arrivalAirport = db.airportOrCreate(
            iata: arr.iata, name: arr.name, city: arr.city, country: arr.country,
            timezoneIdentifier: arr.timezoneIdentifier, latitude: arr.latitude, longitude: arr.longitude
        )
        flightInfo.departureDate = result.scheduledDeparture
        flightInfo.flightDurationMinutes = result.durationMinutes

        hasAutoFilled = true
    }

    func clearLookup() {
        lookupResult = nil
        lookupError = nil
        hasAutoFilled = false
        flightNumberText = ""
    }

    func calculate() {
        guard flightInfo.isComplete else {
            print("FlightInputViewModel: Flight info not complete")
            return
        }

        if let store = flightStore {
            store.add(flightInfo)
            print("FlightInputViewModel: Flight added to store")
        } else {
            print("FlightInputViewModel: No flight store configured!")
        }
    }
}
