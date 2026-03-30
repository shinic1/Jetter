//
//  Airport.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation
import SwiftUI

struct Airport: Codable, Identifiable, Hashable {
    let iataCode: String
    let name: String
    let city: String
    let country: String
    let timezoneIdentifier: String
    let latitude: Double
    let longitude: Double

    var id: String { iataCode }

    var timeZone: TimeZone {
        TimeZone(identifier: timezoneIdentifier)!
    }

    var displayName: String {
        "\(city) (\(iataCode))"
    }

    var fullDisplayName: String {
        "\(name) — \(city), \(country)"
    }
}
