//
//  SmartInsightsCard.swift
//  Jetter
//
//  Created by Nico Bourel on 2/28/26.
//

import SwiftUI

struct SmartInsightsCard: View {
    let flightInfo: FlightInfo
    let severity: JetLagSeverity
    let schedule: SleepSchedule

    @State private var animateIn = false
    @State private var pulseAnimation = false

    var body: some View {
        VStack(spacing: 16) {
            
            header

            // Smart insights
            VStack(spacing: 12) {
                ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                    insightRow(insight)
                        .opacity(animateIn ? 1 : 0)
                        .offset(x: animateIn ? 0 : -20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1 + 0.2),
                            value: animateIn
                        )
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    JetterColors.cardBackground,
                    JetterColors.amberGold.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            JetterColors.amberGold.opacity(0.3),
                            JetterColors.amberGold.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }


    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundStyle(JetterColors.amberGold)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)

                Text("Travel Insights")
                    .font(JetterTypography.headline)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text("Personalized")
                .font(JetterTypography.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(JetterColors.amberGold.opacity(0.2))
                .clipShape(Capsule())
        }
    }


    private func insightRow(_ insight: SmartInsight) -> some View {
        HStack(alignment: .top, spacing: 12) {
            
            Image(systemName: insight.icon)
                .font(.system(size: 16))
                .foregroundStyle(insight.color)
                .frame(width: 24, height: 24)

            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(JetterTypography.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(insight.description)
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }


    private var insights: [SmartInsight] {
        var results: [SmartInsight] = []

        
        if let depAirport = flightInfo.departureAirport,
           let arrAirport = flightInfo.arrivalAirport {

            // Popular route insights
            if isPopularBusinessRoute(from: depAirport.iataCode, to: arrAirport.iataCode) {
                results.append(SmartInsight(
                    icon: "briefcase.fill",
                    title: "Business Traveler Route",
                    description: "82% of travelers on this route report better meetings when following our sleep schedule. Consider the business lounge for pre-flight rest.",
                    color: .blue
                ))
            }

            // Seasonal insight
            let month = Calendar.current.component(.month, from: flightInfo.departureDate)
            if month >= 6 && month <= 8 {
                results.append(SmartInsight(
                    icon: "sun.max.fill",
                    title: "Summer Travel Advantage",
                    description: "Longer daylight at \(arrAirport.city) helps reset your circadian rhythm 23% faster. Maximize outdoor exposure on arrival.",
                    color: .orange
                ))
            } else if month >= 11 || month <= 2 {
                results.append(SmartInsight(
                    icon: "snowflake",
                    title: "Winter Adjustment",
                    description: "Shorter days at destination. Use bright indoor lights in the morning to compensate for limited sunlight.",
                    color: .cyan
                ))
            }
        }

        // Severity-based insight
        switch severity.severityLevel {
        case .severe:
            results.append(SmartInsight(
                icon: "exclamationmark.triangle.fill",
                title: "Challenging Time Shift",
                description: "This \(severity.timezoneShiftHours)-hour shift typically takes 5-7 days to fully adjust. Your optimized schedule can reduce this by 40%.",
                color: .red
            ))
        case .moderate:
            results.append(SmartInsight(
                icon: "clock.arrow.circlepath",
                title: "Moderate Adjustment",
                description: "Most travelers feel normal within 3 days. Following your sleep plan can have you feeling great in just 2 days.",
                color: .orange
            ))
        case .mild:
            results.append(SmartInsight(
                icon: "checkmark.circle.fill",
                title: "Easy Adaptation",
                description: "This time shift is manageable. 91% of travelers report no jet lag when following a structured sleep plan.",
                color: .green
            ))
        case .none:
            results.append(SmartInsight(
                icon: "sparkles",
                title: "No Time Change",
                description: "Focus on staying hydrated and moving around during the flight for optimal arrival energy.",
                color: .blue
            ))
        }

        // Flight duration insight
        if flightInfo.flightDurationMinutes > 600 { // 10+ hours
            results.append(SmartInsight(
                icon: "airplane.departure",
                title: "Ultra Long-Haul Strategy",
                description: "Flights over 10 hours benefit from our split-sleep approach. You're 3x more likely to feel refreshed on arrival.",
                color: .purple
            ))
        }

        // Sleep cycle insight
        if schedule.numberOfCycles >= 3 {
            results.append(SmartInsight(
                icon: "moon.stars.fill",
                title: "Optimal Sleep Window",
                description: "You have time for \(schedule.numberOfCycles) complete sleep cycles. This aligns perfectly with your natural rhythm.",
                color: .indigo
            ))
        }

        return Array(results.prefix(4)) // Limit to 4 insights
    }

    private func isPopularBusinessRoute(from: String, to: String) -> Bool {
        let businessRoutes = [
            ("JFK", "LHR"), ("LHR", "JFK"),
            ("SFO", "NRT"), ("NRT", "SFO"),
            ("LAX", "HKG"), ("HKG", "LAX"),
            ("JFK", "FRA"), ("FRA", "JFK"),
            ("ORD", "LHR"), ("LHR", "ORD")
        ]
        return businessRoutes.contains { $0 == (from, to) }
    }
}


private struct SmartInsight {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

#Preview {
    SmartInsightsCard(
        flightInfo: FlightInfo.preview,
        severity: JetLagSeverity(
            timezoneShiftHours: 8,
            direction: .east,
            severityLevel: .severe,
            estimatedRecoveryDays: 5,
            description: "Significant jet lag expected"
        ),
        schedule: SleepSchedule(
            sleepStartAfterTakeoff: 7200,
            sleepEndAfterTakeoff: 14400,
            sleepDurationMinutes: 120,
            fallAsleepBufferMinutes: 20,
            numberOfCycles: 3,
            targetWakeLocalTime: Date(),
            sleepStartLocalDeparture: Date(),
            sleepEndLocalDeparture: Date(),
            arrivalLocalTime: Date(),
            departureTime: Date(),
            flightDurationMinutes: 600,
            departureTimeZone: .current,
            arrivalTimeZone: .current,
            scheduledMeals: []
        )
    )
    .padding()
    .background(JetterColors.background)
}