//
//  TravelReadiness.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct TravelReadiness {
    let score: Int
    let factors: [ReadinessFactor]
    let overallLabel: String

    struct ReadinessFactor: Identifiable {
        let id = UUID()
        let name: String
        let score: Int
        let tip: String
    }

    static func label(for score: Int) -> String {
        switch score {
        case 80...100: return "Well Prepared"
        case 60..<80: return "Good"
        case 40..<60: return "Fair"
        default: return "Challenging"
        }
    }
}
