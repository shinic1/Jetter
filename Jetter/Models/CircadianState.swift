//
//  CircadianState.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct CircadianState {
    let time: Date

    let timeZone: TimeZone

    let sleepPressure: Double

    let circadianPhase: Double

    var alertness: Double {
        // Alertness is inverse of sleep pressure, modulated by circadian phase
        let baseSleepEffect = 100.0 - sleepPressure
        let circadianModulation = circadianPhase / 100.0

        // Combine the two processes
        let rawAlertness = baseSleepEffect * circadianModulation

        // Clamp to 0-100 range
        return max(0, min(100, rawAlertness))
    }

    var hourOfDay: Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.hour, from: time)
    }

    var minuteOfHour: Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.minute, from: time)
    }

    var clockAngle: Double {
        let totalMinutes = Double(hourOfDay * 60 + minuteOfHour)
        let minutesInDay = 24.0 * 60.0
        return (totalMinutes / minutesInDay) * 360.0
    }

    var isOptimalSleepTime: Bool {
        hourOfDay >= 22 || hourOfDay < 7
    }
}


extension CircadianState {
    init(time: Date, timeZone: TimeZone, hoursAwake: Double) {
        self.time = time
        self.timeZone = timeZone

        // Sleep pressure builds linearly, roughly 6.25 points per hour awake
        // Clamp to 0-100 range (negative hoursAwake = 0 pressure)
        let clampedHoursAwake = max(0, hoursAwake)
        self.sleepPressure = min(clampedHoursAwake * 6.25, 100.0)

        // Circadian phase follows a sinusoidal pattern
        // Peak alertness around 10 AM - 8 PM
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let hour = Double(calendar.component(.hour, from: time))
        let minute = Double(calendar.component(.minute, from: time))
        let timeOfDay = hour + (minute / 60.0)

        // Sinusoidal circadian rhythm: peak at 15:00 (3 PM), lowest at 3:00 AM
        // Using shifted sine wave
        let phase = sin((timeOfDay - 3.0) * .pi / 12.0)
        // Normalize to 0-100 range (sine goes from -1 to +1)
        self.circadianPhase = max(0, min(100, (phase + 1.0) * 50.0))
    }
}
