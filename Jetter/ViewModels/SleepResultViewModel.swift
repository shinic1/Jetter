//
//  SleepResultViewModel.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation
import SwiftUI

@Observable
final class SleepResultViewModel {
    let flightInfo: FlightInfo
    let schedule: SleepSchedule
    let severity: JetLagSeverity
    let readiness: TravelReadiness
    let tips: [TipItem]
    let preparationTimeline: [PreparationDay]

    var flightDurationMinutes: Int { flightInfo.flightDurationMinutes }

    var daysUntilFlight: Int {
        let interval = flightInfo.departureDate.timeIntervalSince(Date())
        return max(0, Int(interval / 86400))
    }

    var routeDisplay: String {
        guard let dep = flightInfo.departureAirport,
              let arr = flightInfo.arrivalAirport else { return "" }
        return "\(dep.iataCode) → \(arr.iataCode)"
    }

    var routeDetail: String {
        guard let dep = flightInfo.departureAirport,
              let arr = flightInfo.arrivalAirport else { return "" }
        return "\(dep.city) to \(arr.city)"
    }

    init(flightInfo: FlightInfo) {
        self.flightInfo = flightInfo

        self.schedule = SleepCalculator.calculate(for: flightInfo)

        let depTZ = flightInfo.departureAirport?.timeZone ?? .current
        let arrTZ = flightInfo.arrivalAirport?.timeZone ?? .current

        self.severity = JetLagCalculator.calculate(
            departureTimeZone: depTZ,
            arrivalTimeZone: arrTZ,
            departureDate: flightInfo.departureDate
        )

        self.readiness = ReadinessCalculator.calculate(
            flight: flightInfo,
            schedule: self.schedule,
            severity: self.severity
        )

        self.tips = TipsGenerator.generate(
            flight: flightInfo,
            schedule: self.schedule,
            severity: self.severity
        )

        self.preparationTimeline = PreFlightPreparationCalculator.generate(
            for: flightInfo,
            severity: self.severity
        )
    }
}
