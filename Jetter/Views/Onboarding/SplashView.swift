import SwiftUI

struct SplashView: View {
    @Binding var isPresented: Bool

    @State private var planeOffset: CGFloat = -120
    @State private var planeOpacity: Double = 0
    @State private var arcProgress: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var backgroundScale: Double = 1.05

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.043, green: 0.102, blue: 0.180),
                    Color(red: 0.075, green: 0.169, blue: 0.290)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .scaleEffect(backgroundScale)
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Flight arc + airplane
                ZStack {
                    ArcPath()
                        .trim(from: 0, to: arcProgress)
                        .stroke(
                            Color(red: 0.961, green: 0.651, blue: 0.137).opacity(0.35),
                            style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                        )
                        .frame(width: 200, height: 80)

                    Image(systemName: "airplane")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            Color(red: 0.961, green: 0.651, blue: 0.137)
                        )
                        .offset(x: planeOffset)
                        .opacity(planeOpacity)
                        .rotationEffect(.degrees(-20))
                }
                .frame(height: 100)

                // Title
                Text("Jetter")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        Color(red: 0.961, green: 0.651, blue: 0.137)
                    )
                    .opacity(titleOpacity)

                // Tagline
                Text("Sleep smarter. Land fresher.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
                    .opacity(subtitleOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                planeOpacity = 1
                planeOffset = 0
                arcProgress = 1.0
                backgroundScale = 1.0
            }

            withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                titleOpacity = 1
            }

            withAnimation(.easeIn(duration: 0.4).delay(0.8)) {
                subtitleOpacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.4)) {
                    isPresented = false
                }
            }
        }
    }
}
