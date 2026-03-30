//
//  PopularRoutesCard.swift
//  Jetter
//
//  Created by Nico Bourel on 2/28/26.
//

import SwiftUI

struct PopularRoutesCard: View {
    @Binding var flightInfo: FlightInfo
    let onSelect: () -> Void

    @State private var animateIn = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(JetterColors.amberGold)

                Text("Popular Routes")
                    .font(JetterTypography.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text("Tap to select")
                    .font(JetterTypography.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 4)

            // Route options
            VStack(spacing: 8) {
                ForEach(Array(popularRoutes.enumerated()), id: \.offset) { index, route in
                    routeButton(route)
                        .opacity(animateIn ? 1 : 0)
                        .offset(x: animateIn ? 0 : -20)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1),
                            value: animateIn
                        )
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    JetterColors.cardBackground,
                    JetterColors.amberGold.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(JetterColors.amberGold.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateIn = true
            }
        }
    }


    private func routeButton(_ route: PopularRoute) -> some View {
        Button {
            selectRoute(route)
        } label: {
            HStack(spacing: 12) {
                // Route icon
                Image(systemName: route.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(route.color)
                    .frame(width: 24)

                // Route info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(route.from)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)

                        Text(route.to)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))

                        Spacer()

                        // Duration badge
                        Text(route.durationLabel)
                            .font(JetterTypography.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    Text(route.description)
                        .font(JetterTypography.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(route.color.opacity(0.3))
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }


    private func selectRoute(_ route: PopularRoute) {
        HapticManager.selection()

        // Get airports from database
        let database = AirportDatabase.shared
        guard let depAirport = database.airport(forCode: route.from),
              let arrAirport = database.airport(forCode: route.to) else { return }

        // Update flight info
        flightInfo.departureAirport = depAirport
        flightInfo.arrivalAirport = arrAirport
        flightInfo.flightDurationMinutes = route.durationMinutes

        // Set appropriate departure time based on route
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())

        // Set departure time based on route type
        switch route.type {
        case .short:
            components.hour = 8
            components.minute = 0
        case .medium:
            components.hour = 14
            components.minute = 30
        case .long:
            components.hour = 22
            components.minute = 15
        }

        if let departureDate = calendar.date(from: components) {
            // If the time is in the past, add one day
            if departureDate < Date() {
                flightInfo.departureDate = calendar.date(byAdding: .day, value: 1, to: departureDate) ?? Date()
            } else {
                flightInfo.departureDate = departureDate
            }
        }

        onSelect()
    }


    private var popularRoutes: [PopularRoute] {
        [
            PopularRoute(
                type: .short,
                from: "JFK",
                to: "LHR",
                fromCity: "New York",
                toCity: "London",
                durationMinutes: 420, // 7 hours
                durationLabel: "7h",
                description: "Classic transatlantic • 5 hour time shift",
                icon: "airplane.circle.fill",
                color: .blue
            ),
            PopularRoute(
                type: .medium,
                from: "SFO",
                to: "HND",
                fromCity: "San Francisco",
                toCity: "Tokyo",
                durationMinutes: 660, // 11 hours
                durationLabel: "11h",
                description: "Pacific crossing • 8 hour time shift",
                icon: "globe.americas.fill",
                color: .green
            ),
            PopularRoute(
                type: .long,
                from: "JFK",
                to: "SIN",
                fromCity: "New York",
                toCity: "Singapore",
                durationMinutes: 1110, // 18.5 hours
                durationLabel: "18.5h",
                description: "Ultra long-haul • 13 hour time shift",
                icon: "moon.stars.circle.fill",
                color: .purple
            )
        ]
    }
}


private struct PopularRoute {
    enum RouteType {
        case short, medium, long
    }

    let type: RouteType
    let from: String
    let to: String
    let fromCity: String
    let toCity: String
    let durationMinutes: Int
    let durationLabel: String
    let description: String
    let icon: String
    let color: Color
}

#Preview {
    @Previewable @State var flightInfo = FlightInfo()

    return PopularRoutesCard(
        flightInfo: $flightInfo,
        onSelect: {}
    )
    .padding()
    .background(JetterColors.background)
}