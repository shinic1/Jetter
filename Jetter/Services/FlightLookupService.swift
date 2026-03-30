//
//  FlightLookupService.swift
//  Jetter
//

import Foundation

protocol FlightLookupServiceProtocol {
    func lookupFlight(number: String, date: Date) async throws -> FlightLookupResult
}
