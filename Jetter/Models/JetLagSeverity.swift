//
//  JetLagSeverity.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

struct JetLagSeverity {
    let timezoneShiftHours: Int
    let direction: ShiftDirection
    let severityLevel: SeverityLevel
    let estimatedRecoveryDays: Int
    let description: String

    enum ShiftDirection: String {
        case east, west, none
    }

    enum SeverityLevel: String, CaseIterable {
        case none
        case mild
        case moderate
        case severe

        var color: Color {
            switch self {
            case .none: return JetterColors.severityNone
            case .mild: return JetterColors.severityMild
            case .moderate: return JetterColors.severityModerate
            case .severe: return JetterColors.severitySevere
            }
        }

        var label: String {
            switch self {
            case .none: return "Minimal"
            case .mild: return "Mild"
            case .moderate: return "Moderate"
            case .severe: return "Severe"
            }
        }
    }
}
