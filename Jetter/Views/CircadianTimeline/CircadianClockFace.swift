import SwiftUI

struct CircadianClockFace: View {
    let schedule: SleepSchedule
    let severity: JetLagSeverity
    let currentAngle: Double
    let sleepWindowAngles: (start: Double, end: Double)
    let timezoneShiftAngle: Double

    @Binding var isInteracting: Bool

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(JetterColors.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

            // Hour markers and labels
            hourMarkers

            // Sleep window arc
            sleepWindowArc

            // Timezone shift indicator
            if abs(timezoneShiftAngle) > 0 {
                timezoneShiftArc
            }

            // Current time indicator
            currentTimeIndicator

            // Center dot
            Circle()
                .fill(JetterColors.amberGold)
                .frame(width: 12, height: 12)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }


    private var hourMarkers: some View {
        ZStack {
            // Subtle marker lines for all hours
            ForEach(0..<24, id: \.self) { hour in
                VStack {
                    if hour % 6 == 0 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 10)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 1, height: 4)
                    }
                    Spacer()
                }
                .rotationEffect(.degrees(Double(hour) * 15.0))
            }

            // Time labels at key hours (0, 6, 12, 18)
            ForEach([0, 6, 12, 18], id: \.self) { hour in
                VStack {
                    Text("\(hour)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(JetterColors.amberGold)
                        .offset(y: -8)

                    Spacer()
                }
                .rotationEffect(.degrees(Double(hour) * 15.0))
            }
        }
    }


    private var sleepWindowArc: some View {
        SleepArc(
            startAngle: sleepWindowAngles.start,
            endAngle: sleepWindowAngles.end
        )
        .stroke(
            JetterColors.amberGold.opacity(0.3),
            style: StrokeStyle(lineWidth: 30, lineCap: .round)
        )
        .padding(40)
    }


    private var timezoneShiftArc: some View {
        TimezoneShiftArc(shiftAngle: timezoneShiftAngle)
            .stroke(
                severity.direction == .east
                    ? Color.blue.opacity(0.4)
                    : Color.orange.opacity(0.4),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 4])
            )
            .padding(25)
    }


    private var currentTimeIndicator: some View {
        VStack {
            Circle()
                .fill(JetterColors.amberGold)
                .frame(width: 16, height: 16)
                .shadow(color: JetterColors.amberGold.opacity(0.6), radius: 8)

            Rectangle()
                .fill(JetterColors.amberGold)
                .frame(width: 3, height: 80)

            Spacer()
        }
        .rotationEffect(.degrees(currentAngle))
        .animation(isInteracting ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: currentAngle)
    }
}


struct SleepArc: Shape {
    let startAngle: Double
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        // Convert our angles (0° = top/midnight) to SwiftUI angles (0° = right/3 o'clock)
        // Our system: 0° = top (12 o'clock), clockwise
        // SwiftUI system: 0° = right (3 o'clock), counter-clockwise is positive

        // To convert: rotate by -90° to align coordinate systems
        let startSwiftUI = Angle(degrees: startAngle - 90)
        let endSwiftUI = Angle(degrees: endAngle - 90)

        // Draw the arc counter-clockwise (which appears clockwise in our rotated system)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startSwiftUI,
            endAngle: endSwiftUI,
            clockwise: false
        )

        return path
    }
}


struct TimezoneShiftArc: Shape {
    let shiftAngle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        // Draw arc showing the timezone shift
        let start = Angle(degrees: -90) // Start at top (midnight)
        let end = Angle(degrees: shiftAngle - 90)

        path.addArc(
            center: center,
            radius: radius,
            startAngle: start,
            endAngle: end,
            clockwise: shiftAngle > 0
        )

        return path
    }
}

#Preview {
    CircadianClockFace(
        schedule: FlightInfo.preview.sleepSchedule,
        severity: FlightInfo.preview.jetLagSeverity,
        currentAngle: 90,
        sleepWindowAngles: (120, 240),
        timezoneShiftAngle: 45,
        isInteracting: .constant(false)
    )
    .frame(width: 300, height: 300)
    .padding()
}


extension FlightInfo {
    static var preview: FlightInfo {
        var info = FlightInfo()
        info.departureAirport = Airport(
            iataCode: "JFK",
            name: "John F. Kennedy International",
            city: "New York",
            country: "United States",
            timezoneIdentifier: "America/New_York",
            latitude: 40.6413,
            longitude: -73.7781
        )
        info.arrivalAirport = Airport(
            iataCode: "LHR",
            name: "London Heathrow",
            city: "London",
            country: "United Kingdom",
            timezoneIdentifier: "Europe/London",
            latitude: 51.4700,
            longitude: -0.4543
        )
        info.departureDate = Date()
        info.flightDurationMinutes = 420
        return info
    }

    var sleepSchedule: SleepSchedule {
        SleepCalculator.calculate(for: self)
    }

    var jetLagSeverity: JetLagSeverity {
        guard let dep = departureAirport, let arr = arrivalAirport else {
            return JetLagSeverity(
                timezoneShiftHours: 0,
                direction: .none,
                severityLevel: .none,
                estimatedRecoveryDays: 0,
                description: ""
            )
        }
        return JetLagCalculator.calculate(
            departureTimeZone: dep.timeZone,
            arrivalTimeZone: arr.timeZone,
            departureDate: departureDate
        )
    }
}
