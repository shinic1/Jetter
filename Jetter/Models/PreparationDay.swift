//
//  PreparationDay.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct PreparationDay: Identifiable {
    let id = UUID()
    let daysBeforeFlight: Int
    let recommendedBedtime: Date
    let recommendedWakeTime: Date
    let shiftAmount: String
    let description: String

    var dayLabel: String {
        if daysBeforeFlight == 0 {
            return "Day of flight"
        } else if daysBeforeFlight == 1 {
            return "1 day before"
        } else {
            return "\(daysBeforeFlight) days before"
        }
    }

    var bedtimeString: String {
        formatTime(recommendedBedtime)
    }

    var wakeTimeString: String {
        formatTime(recommendedWakeTime)
    }


    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
