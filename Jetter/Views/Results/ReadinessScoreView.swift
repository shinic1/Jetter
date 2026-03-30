import SwiftUI

struct ReadinessScoreView: View {
    let readiness: TravelReadiness

    @State private var ringProgress: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            Label("Travel Readiness", systemImage: "checkmark.seal.fill")
                .font(JetterTypography.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 24) {
                // Score ring
                ZStack {
                    Circle()
                        .stroke(JetterColors.deepNavy.opacity(0.15), lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            readinessColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(readiness.score)")
                            .font(JetterTypography.monoLarge)
                            .foregroundStyle(.primary)

                        Text(readiness.overallLabel)
                            .font(JetterTypography.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 100, height: 100)

                // Factor breakdown
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(readiness.factors) { factor in
                        HStack {
                            Text(factor.name)
                                .font(JetterTypography.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(factor.score)")
                                .font(JetterTypography.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(factorColor(factor.score))
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) {
                ringProgress = Double(readiness.score) / 100.0
            }
        }
    }

    private var readinessColor: Color {
        factorColor(readiness.score)
    }

    private func factorColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return JetterColors.amberGold
        case 40..<60: return .orange
        default: return .red
        }
    }
}
