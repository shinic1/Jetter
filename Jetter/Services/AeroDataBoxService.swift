//
//  AeroDataBoxService.swift
//  Jetter
//

import Foundation

struct AeroDataBoxService: FlightLookupServiceProtocol {
    private let networkClient = NetworkClient()

    func lookupFlight(number: String, date: Date) async throws -> FlightLookupResult {
        let dateString = Self.dateFormatter.string(from: date)

        guard let apiKey = APIKeyProvider.apiKey(for: .aeroDataBox) else {
            throw FlightLookupError.serverError
        }

        let endpoint = Endpoint(
            baseURL: "https://aerodatabox.p.rapidapi.com",
            path: "/flights/number/\(number)/\(dateString)",
            headers: [
                "X-RapidAPI-Key": apiKey,
                "X-RapidAPI-Host": "aerodatabox.p.rapidapi.com"
            ]
        )

        let flights: [AeroDataBoxFlight]
        do {
            flights = try await networkClient.request(endpoint)
        } catch let error as NetworkError {
            throw Self.mapNetworkError(error)
        } catch {
            throw FlightLookupError.networkUnavailable
        }

        // Find the best matching flight (prefer exact flight number match)
        let normalizedQuery = number.uppercased().replacingOccurrences(of: " ", with: "")
        let matchingFlight = flights.first { flight in
            flight.number.replacingOccurrences(of: " ", with: "").uppercased() == normalizedQuery
        } ?? flights.first

        guard let flight = matchingFlight,
              let result = FlightLookupResult(from: flight) else {
            throw FlightLookupError.flightNotFound
        }

        return result
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static func mapNetworkError(_ error: NetworkError) -> FlightLookupError {
        switch error {
        case .rateLimited:
            return .rateLimited
        case .unauthorized:
            return .serverError
        case .httpError(let statusCode) where statusCode == 404:
            return .flightNotFound
        case .noData:
            return .flightNotFound
        case .invalidURL, .decodingError, .httpError:
            return .serverError
        }
    }
}
