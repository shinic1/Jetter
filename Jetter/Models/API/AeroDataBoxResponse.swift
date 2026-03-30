//
//  AeroDataBoxResponse.swift
//  Jetter
//

import Foundation

struct AeroDataBoxFlight: Decodable {
    let departure: AeroDataBoxEndpoint
    let arrival: AeroDataBoxEndpoint
    let number: String
    let airline: AeroDataBoxAirline?
}

struct AeroDataBoxEndpoint: Decodable {
    let airport: AeroDataBoxAirport
    let scheduledTime: AeroDataBoxTime?
}

struct AeroDataBoxTime: Decodable {
    let utc: String?
    let local: String?
}

struct AeroDataBoxLocation: Decodable {
    let lat: Double?
    let lon: Double?
}

struct AeroDataBoxAirport: Decodable {
    let iata: String?
    let name: String?
    let municipalityName: String?
    let countryCode: String?
    let timeZone: String?
    let location: AeroDataBoxLocation?
}

struct AeroDataBoxAirline: Decodable {
    let name: String?
}
