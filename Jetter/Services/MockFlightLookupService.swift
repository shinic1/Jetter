//
//  MockFlightLookupService.swift
//  Jetter
//

import Foundation

struct MockFlightLookupService: FlightLookupServiceProtocol {
    var result: Result<FlightLookupResult, Error> = .success(.sample)

    func lookupFlight(number: String, date: Date) async throws -> FlightLookupResult {
        try await Task.sleep(for: .seconds(1))
        return try result.get()
    }
}
