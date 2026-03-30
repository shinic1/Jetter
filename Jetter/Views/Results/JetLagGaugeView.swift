import SwiftUI

struct JetLagGaugeView: View {
    let severity: JetLagSeverity

    @State private var gaugeProgress: Double = 0

    var body: some View {
        VStack(spacing: 14) {
            Label("Jet Lag Estimate", systemImage: "globe.americas.fill")
                .font(JetterTypography.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 24) {
                // Gauge
                ZStack {
                    // Background arc
                    Circle()
                        .trim(from: 0.25, to: 0.75)
                        .stroke(
                            JetterColors.deepNavy.opacity(0.15),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(180))

                    // Filled arc
                    Circle()
                        .trim(from: 0.25, to: 0.25 + gaugeProgress * 0.5)
                        .stroke(
                            severity.severityLevel.color,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(180))

                    // Center content
                    VStack(spacing: 2) {
                        Text("\(severity.timezoneShiftHours)h")
                            .font(JetterTypography.monoLarge)
                            .foregroundStyle(.primary)

                        Text(severity.severityLevel.label)
                            .font(JetterTypography.caption)
                            .foregroundStyle(severity.severityLevel.color)

                        if severity.direction != .none {
                            Text(severity.direction.rawValue.capitalized)
                                .font(JetterTypography.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .frame(width: 140, height: 90)

                // Details
                VStack(alignment: .leading, spacing: 10) {
                    detailRow(
                        label: "Direction",
                        value: severity.direction == .none
                            ? "No shift"
                            : "\(severity.direction.rawValue.capitalized)ward"
                    )

                    detailRow(
                        label: "Recovery",
                        value: severity.estimatedRecoveryDays == 0
                            ? "None needed"
                            : "~\(severity.estimatedRecoveryDays) day\(severity.estimatedRecoveryDays == 1 ? "" : "s")"
                    )
                }
            }

            Text(severity.description)
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .onAppear {
            let normalized = min(Double(severity.timezoneShiftHours) / 12.0, 1.0)
            withAnimation(.easeOut(duration: 1.0).delay(0.8)) {
                gaugeProgress = normalized
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(JetterTypography.caption2)
                .foregroundStyle(.tertiary)
            Text(value)
                .font(JetterTypography.subheadline)
                .foregroundStyle(.primary)
        }
    }
}
