//
//  FlightTimeEstimator.swift
//  Jetter
//
//  Created by Nico Bourel on 1/30/26.
//

import Foundation

struct FlightTimeEstimator {

    static func estimate(from departure: Airport, to arrival: Airport) -> Int {
        let distanceKm = haversineDistance(
            lat1: departure.latitude, lon1: departure.longitude,
            lat2: arrival.latitude, lon2: arrival.longitude
        )

        let cruisingSpeedKmh = 850.0
        let overheadMinutes = 45.0

        let flightMinutes = (distanceKm / cruisingSpeedKmh) * 60.0 + overheadMinutes
        let rounded = (Int(flightMinutes) / 5) * 5

        return max(rounded, 30)
    }


    private static func haversineDistance(
        lat1: Double, lon1: Double,
        lat2: Double, lon2: Double
    ) -> Double {
        let earthRadiusKm = 6371.0

        let dLat = toRadians(lat2 - lat1)
        let dLon = toRadians(lon2 - lon1)

        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(toRadians(lat1)) * cos(toRadians(lat2)) *
                sin(dLon / 2) * sin(dLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusKm * c
    }

    private static func toRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180.0
    }
}
