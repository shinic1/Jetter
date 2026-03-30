import SwiftUI

struct FlightCardView: View {
    let flight: SavedFlight

    private var severity: JetLagSeverity {
        let depTZ = flight.flightInfo.departureAirport?.timeZone ?? .current
        let arrTZ = flight.flightInfo.arrivalAirport?.timeZone ?? .current
        return JetLagCalculator.calculate(
            departureTimeZone: depTZ,
            arrivalTimeZone: arrTZ,
            departureDate: flight.flightInfo.departureDate
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            // Top row: route codes + severity badge
            HStack {
                if let dep = flight.flightInfo.departureAirport,
                   let arr = flight.flightInfo.arrivalAirport {
                    Text("\(dep.iataCode) → \(arr.iataCode)")
                        .font(JetterTypography.monoTime)
                        .foregroundStyle(.primary)
                }

                Spacer()

                JetterBadge(
                    text: severity.severityLevel.label,
                    color: severity.severityLevel.color
                )
            }

            Divider()
                .background(JetterColors.amberGold.opacity(0.2))

            // Bottom row: city names, date, duration
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let dep = flight.flightInfo.departureAirport,
                       let arr = flight.flightInfo.arrivalAirport {
                        Text("\(dep.city) to \(arr.city)")
                            .font(JetterTypography.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        Label(formattedDate, systemImage: "calendar")
                            .font(JetterTypography.caption)
                            .foregroundStyle(.tertiary)

                        Label(flight.flightInfo.totalFlightDurationInHoursAndMinutes, systemImage: "clock")
                            .font(JetterTypography.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: flight.flightInfo.departureDate)
    }
}
