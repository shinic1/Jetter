//
//  SavedFlight.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct SavedFlight: Codable, Identifiable {
    let id: UUID
    let dateCreated: Date
    var flightInfo: FlightInfo

    init(flightInfo: FlightInfo) {
        self.id = UUID()
        self.dateCreated = Date()
        self.flightInfo = flightInfo
    }
}
