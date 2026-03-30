import SwiftUI

struct TimezoneShiftIndicator: View {
    let severity: JetLagSeverity
    let animate: Bool

    @State private var animationProgress: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            // Direction arrow
            directionArrow

            // Shift information
            VStack(spacing: 4) {
                Text(shiftDescription)
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)

                Text("\(abs(severity.timezoneShiftHours))h \(directionText)")
                    .font(JetterTypography.monoTime)
                    .foregroundStyle(directionColor)
            }
        }
        .padding(12)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .scaleEffect(animationProgress)
        .opacity(animationProgress)
        .onAppear {
            if animate {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                    animationProgress = 1.0
                }
            } else {
                animationProgress = 1.0
            }
        }
    }


    private var directionArrow: some View {
        ZStack {
            Circle()
                .fill(directionColor.opacity(0.2))
                .frame(width: 50, height: 50)

            Image(systemName: arrowIcon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(directionColor)
                .rotationEffect(.degrees(severity.direction == .east ? 0 : 180))
        }
    }


    private var arrowIcon: String {
        switch severity.direction {
        case .east:
            return "arrow.right.circle.fill"
        case .west:
            return "arrow.left.circle.fill"
        case .none:
            return "circle.fill"
        }
    }

    private var directionColor: Color {
        switch severity.direction {
        case .east:
            return .blue
        case .west:
            return .orange
        case .none:
            return .gray
        }
    }

    private var directionText: String {
        switch severity.direction {
        case .east:
            return "East"
        case .west:
            return "West"
        case .none:
            return "No Shift"
        }
    }

    private var shiftDescription: String {
        if severity.timezoneShiftHours == 0 {
            return "Same timezone"
        }
        return "Timezone shift"
    }
}

#Preview {
    VStack(spacing: 20) {
        TimezoneShiftIndicator(
            severity: JetLagSeverity(
                timezoneShiftHours: 5,
                direction: .east,
                severityLevel: .moderate,
                estimatedRecoveryDays: 4,
                description: "5-hour eastward shift"
            ),
            animate: true
        )

        TimezoneShiftIndicator(
            severity: JetLagSeverity(
                timezoneShiftHours: 3,
                direction: .west,
                severityLevel: .mild,
                estimatedRecoveryDays: 2,
                description: "3-hour westward shift"
            ),
            animate: true
        )

        TimezoneShiftIndicator(
            severity: JetLagSeverity(
                timezoneShiftHours: 0,
                direction: .none,
                severityLevel: .none,
                estimatedRecoveryDays: 0,
                description: "No shift"
            ),
            animate: true
        )
    }
    .padding()
    .background(JetterColors.background)
}
