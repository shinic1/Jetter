import SwiftUI

struct SleepCycleView: View {
    let numberOfCycles: Int

    @State private var animatedCycles = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Sleep Cycles", systemImage: "waveform.path")
                .font(JetterTypography.headline)
                .foregroundStyle(.primary)

            if numberOfCycles == 0 {
                VStack(spacing: 10) {
                    Image(systemName: "powersleep")
                        .font(.system(size: 28))
                        .foregroundStyle(JetterColors.sleepBlue)

                    Text("No Sleep Cycles")
                        .font(JetterTypography.headline)
                        .foregroundStyle(.primary)

                    Text("This flight is too short for a full sleep cycle. Focus on resting well before departure.")
                        .font(JetterTypography.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                HStack(spacing: 6) {
                    ForEach(0..<numberOfCycles, id: \.self) { index in
                        SingleCycleWave(
                            isAnimated: index < animatedCycles,
                            cycleNumber: index + 1
                        )
                    }
                }
                .frame(height: 70)

                // Stage labels
                HStack(spacing: 0) {
                    stageLabel("Light", color: .cyan.opacity(0.7))
                    Spacer()
                    stageLabel("Deep", color: JetterColors.sleepBlue)
                    Spacer()
                    stageLabel("REM", color: .purple.opacity(0.7))
                }
                .font(JetterTypography.caption2)

                Text("Each cycle is approximately 90 minutes")
                    .font(JetterTypography.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .onAppear {
            for i in 0..<numberOfCycles {
                withAnimation(.easeOut(duration: 0.6).delay(Double(i) * 0.3 + 0.5)) {
                    animatedCycles = i + 1
                }
            }
        }
    }

    private func stageLabel(_ text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}


private struct SingleCycleWave: View {
    let isAnimated: Bool
    let cycleNumber: Int

    var body: some View {
        VStack(spacing: 4) {
            SleepWaveShape()
                .trim(from: 0, to: isAnimated ? 1 : 0)
                .stroke(
                    LinearGradient(
                        colors: [.cyan.opacity(0.6), JetterColors.sleepBlue, .purple.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )

            Text("\(cycleNumber)")
                .font(JetterTypography.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
