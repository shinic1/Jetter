//
//  TipsGenerator.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import Foundation

struct TipItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let body: String
}

struct TipsGenerator {

    static func generate(
        flight: FlightInfo,
        schedule: SleepSchedule,
        severity: JetLagSeverity
    ) -> [TipItem] {
        var tips: [TipItem] = []

        // Hydration — always relevant
        tips.append(TipItem(
            icon: "drop.fill",
            title: "Stay Hydrated",
            body: "Drink water every hour. Avoid excessive caffeine and alcohol during the flight."
        ))

        // Direction-based light exposure
        switch severity.direction {
        case .east:
            tips.append(TipItem(
                icon: "sunrise.fill",
                title: "Seek Morning Light",
                body: "After arrival, get bright light in the morning to shift your clock forward."
            ))
        case .west:
            tips.append(TipItem(
                icon: "sunset.fill",
                title: "Stay Up Until Bedtime",
                body: "Resist sleeping early. Stay active until local bedtime to adjust faster."
            ))
        case .none:
            break
        }

        // Sleep preparation
        if schedule.numberOfCycles >= 3 {
            tips.append(TipItem(
                icon: "moon.fill",
                title: "Maximize Your Rest",
                body: "You have room for \(schedule.numberOfCycles) full sleep cycles. Use an eye mask and earplugs."
            ))
        } else {
            tips.append(TipItem(
                icon: "zzz",
                title: "Power Nap Strategy",
                body: "With limited sleep time, focus on one deep cycle. Set an alarm to avoid oversleeping."
            ))
        }

        // Screen avoidance
        tips.append(TipItem(
            icon: "iphone.slash",
            title: "Reduce Blue Light",
            body: "Avoid screens 30 minutes before your planned sleep window. Use night mode if needed."
        ))

        // Movement for long flights
        if flight.flightDurationMinutes > 360 {
            tips.append(TipItem(
                icon: "figure.walk",
                title: "Move Regularly",
                body: "Get up and stretch every 2–3 hours to improve circulation and comfort."
            ))
        }

        // Smart meal timing tips based on actual meal service
        let meals = schedule.scheduledMeals

        if meals.isEmpty {
            // Generic tip if no meals scheduled
            tips.append(TipItem(
                icon: "fork.knife",
                title: "Eat on Destination Time",
                body: "Try to eat meals aligned with your destination timezone to help reset your body clock."
            ))
        } else {
            // Check each meal and provide specific advice
            for meal in meals {
                let conflictsWithSleep = MealServiceCalculator.mealConflictsWithSleep(
                    meal,
                    schedule: schedule
                )

                if conflictsWithSleep {
                    switch meal.type {
                    case .dinner:
                        tips.append(TipItem(
                            icon: "fork.knife.circle.fill",
                            title: "Consider Skipping Dinner",
                            body: "Dinner service may delay your optimal sleep time. Consider a light snack instead to sleep earlier and fight jet lag better."
                        ))
                    case .breakfast:
                        tips.append(TipItem(
                            icon: "cup.and.saucer.fill",
                            title: "Skip Breakfast for More Sleep",
                            body: "Breakfast service may wake you early. Consider declining to complete your sleep cycle for better recovery."
                        ))
                    default:
                        break
                    }
                } else {
                    // Meal aligns well with schedule
                    switch meal.type {
                    case .dinner:
                        tips.append(TipItem(
                            icon: "moon.fill",
                            title: "Eat Light at Dinner",
                            body: "Choose lighter meal options to make it easier to fall asleep after dinner service."
                        ))
                    case .breakfast:
                        tips.append(TipItem(
                            icon: "sunrise.fill",
                            title: "Use Breakfast to Wake Up",
                            body: "Breakfast service aligns with your wake time. Eating helps signal your body it's time to be alert."
                        ))
                    case .lunch:
                        tips.append(TipItem(
                            icon: "sun.max.fill",
                            title: "Stay Awake During Lunch",
                            body: "Use lunch service as an opportunity to stay awake and adjust to the new timezone."
                        ))
                    default:
                        break
                    }
                }
            }
        }

        // Caffeine timing
        if schedule.sleepStartAfterTakeoff > 3 * 60 * 60 {
            tips.append(TipItem(
                icon: "cup.and.saucer.fill",
                title: "Time Your Caffeine",
                body: "Avoid caffeine at least 5 hours before your planned sleep window."
            ))
        }

        return tips
    }
}
