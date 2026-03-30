import SwiftUI

struct SleepPressureCurve: View {
    let states: [CircadianState]
    let animate: Bool

    @State private var animationProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        JetterColors.amberGold.opacity(0.1),
                        JetterColors.amberGold.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Sleep pressure curve
                SleepPressurePath(states: states, animationProgress: animationProgress)
                    .stroke(
                        LinearGradient(
                            colors: [JetterColors.amberGold, JetterColors.amberGold.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )

                // Filled area under curve
                SleepPressureFilledPath(states: states, animationProgress: animationProgress)
                    .fill(
                        LinearGradient(
                            colors: [
                                JetterColors.amberGold.opacity(0.3),
                                JetterColors.amberGold.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .onAppear {
            if animate {
                withAnimation(.easeInOut(duration: 1.5)) {
                    animationProgress = 1.0
                }
            } else {
                animationProgress = 1.0
            }
        }
    }
}


struct SleepPressurePath: Shape {
    let states: [CircadianState]
    var animationProgress: CGFloat

    var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard !states.isEmpty else { return Path() }

        var path = Path()
        let width = rect.width
        let height = rect.height

        // Calculate points for the curve
        let visibleStates = Int(Double(states.count) * animationProgress)
        guard visibleStates > 0 else { return path }

        for (index, state) in states.prefix(visibleStates).enumerated() {
            let x = CGFloat(index) / CGFloat(states.count - 1) * width
            let y = height - (CGFloat(state.sleepPressure) / 100.0) * height

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                // Use quadratic curves for smoothness
                let previousIndex = index - 1
                let previousState = states[previousIndex]
                let prevX = CGFloat(previousIndex) / CGFloat(states.count - 1) * width
                let prevY = height - (CGFloat(previousState.sleepPressure) / 100.0) * height

                let midX = (prevX + x) / 2
                let controlY = (prevY + y) / 2

                path.addQuadCurve(
                    to: CGPoint(x: x, y: y),
                    control: CGPoint(x: midX, y: controlY)
                )
            }
        }

        return path
    }
}


struct SleepPressureFilledPath: Shape {
    let states: [CircadianState]
    var animationProgress: CGFloat

    var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard !states.isEmpty else { return Path() }

        var path = Path()
        let width = rect.width
        let height = rect.height

        let visibleStates = Int(Double(states.count) * animationProgress)
        guard visibleStates > 0 else { return path }

        // Start at bottom left
        path.move(to: CGPoint(x: 0, y: height))

        // Draw curve
        for (index, state) in states.prefix(visibleStates).enumerated() {
            let x = CGFloat(index) / CGFloat(states.count - 1) * width
            let y = height - (CGFloat(state.sleepPressure) / 100.0) * height

            if index == 0 {
                path.addLine(to: CGPoint(x: x, y: y))
            } else {
                let previousIndex = index - 1
                let previousState = states[previousIndex]
                let prevX = CGFloat(previousIndex) / CGFloat(states.count - 1) * width
                let prevY = height - (CGFloat(previousState.sleepPressure) / 100.0) * height

                let midX = (prevX + x) / 2
                let controlY = (prevY + y) / 2

                path.addQuadCurve(
                    to: CGPoint(x: x, y: y),
                    control: CGPoint(x: midX, y: controlY)
                )
            }
        }

        // Close the path
        let lastX = CGFloat(visibleStates - 1) / CGFloat(states.count - 1) * width
        path.addLine(to: CGPoint(x: lastX, y: height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    let mockStates = (0..<48).map { i in
        CircadianState(
            time: Date().addingTimeInterval(Double(i) * 1800),
            timeZone: .current,
            hoursAwake: Double(i) / 2.0
        )
    }

    return VStack {
        Text("Sleep Pressure Over 24 Hours")
            .font(JetterTypography.headline)

        SleepPressureCurve(states: mockStates, animate: true)
            .frame(height: 200)
            .padding()
            .background(JetterColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
    .background(JetterColors.background)
}
