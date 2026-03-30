//
//  MealService.swift
//  Jetter
//
//  Created by Nico Bourel on 2/28/26.
//

import Foundation


enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var icon: String {
        switch self {
        case .breakfast:
            return "cup.and.saucer.fill"
        case .lunch, .dinner:
            return "fork.knife"
        case .snack:
            return "carrot.fill"
        }
    }

    var color: String {
        switch self {
        case .breakfast:
            return "orange"
        case .lunch:
            return "green"
        case .dinner:
            return "purple"
        case .snack:
            return "blue"
        }
    }
}


struct MealService: Codable, Identifiable, Hashable {
    let id = UUID()
    let type: MealType
    let scheduledTime: Date
    let timeAfterTakeoff: TimeInterval
    let durationMinutes: Int

    var formattedTimeAfterTakeoff: String {
        let hours = Int(timeAfterTakeoff / 3600)
        let minutes = Int((timeAfterTakeoff.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m after takeoff"
        } else if hours > 0 {
            return "\(hours)h after takeoff"
        } else {
            return "\(minutes)m after takeoff"
        }
    }

    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case type
        case scheduledTime
        case timeAfterTakeoff
        case durationMinutes
    }
}


struct MealPreference: Codable, Hashable {
    var willEatBreakfast: Bool = true
    var willEatLunch: Bool = true
    var willEatDinner: Bool = true
    var willEatSnacks: Bool = false

    func willEat(_ type: MealType) -> Bool {
        switch type {
        case .breakfast:
            return willEatBreakfast
        case .lunch:
            return willEatLunch
        case .dinner:
            return willEatDinner
        case .snack:
            return willEatSnacks
        }
    }

    mutating func setWillEat(_ type: MealType, value: Bool) {
        switch type {
        case .breakfast:
            willEatBreakfast = value
        case .lunch:
            willEatLunch = value
        case .dinner:
            willEatDinner = value
        case .snack:
            willEatSnacks = value
        }
    }
}