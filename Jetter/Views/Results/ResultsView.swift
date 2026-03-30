import SwiftUI

struct ResultsView: View {
    let viewModel: SleepResultViewModel

    @State private var animateTimeline = false
    @State private var showCards = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Route header with share button
                ZStack {
                    routeHeader
                        .opacity(showCards ? 1 : 0)
                        .offset(y: showCards ? 0 : 10)

                    HStack {
                        Spacer()
                        Button(action: shareFlightPlan) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundStyle(JetterColors.amberGold)
                                .padding(8)
                                .background(JetterColors.cardBackground)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        }
                    }
                    .padding(.trailing, 20)
                    .opacity(showCards ? 1 : 0)
                }

                // Flight timeline (hero)
                FlightTimelineView(
                    schedule: viewModel.schedule,
                    flightDuration: viewModel.flightDurationMinutes,
                    animate: $animateTimeline
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 15)

                // Meal Service Card (only show if meals are scheduled)
                if !viewModel.schedule.scheduledMeals.isEmpty {
                    MealServiceCard(
                        meals: viewModel.schedule.scheduledMeals,
                        schedule: viewModel.schedule,
                        mealPreference: .constant(viewModel.flightInfo.mealPreference)
                    )
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 16)
                }

                // AI-Powered Insights
                SmartInsightsCard(
                    flightInfo: viewModel.flightInfo,
                    severity: viewModel.severity,
                    schedule: viewModel.schedule
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 17)

                // Circadian Rhythm Timeline
                CircadianTimelineCard(
                    schedule: viewModel.schedule,
                    severity: viewModel.severity
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 18)

                // Pre-Flight Preparation (only show if flight is at least 1 day away)
                if viewModel.daysUntilFlight >= 1 {
                    PreFlightPreparationCard(
                        timeline: viewModel.preparationTimeline,
                        daysUntilFlight: viewModel.daysUntilFlight
                    )
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 19)
                }

                // Sleep window card
                SleepWindowCard(schedule: viewModel.schedule)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 20)

                // Sleep cycles
                SleepCycleView(numberOfCycles: viewModel.schedule.numberOfCycles)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 25)

                // Jet lag gauge
                JetLagGaugeView(severity: viewModel.severity)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 30)

                // Readiness score
                ReadinessScoreView(readiness: viewModel.readiness)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 35)

                // Tips
                TipsListView(tips: viewModel.tips)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(JetterColors.background.ignoresSafeArea())
        .navigationTitle("Your Sleep Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Flights")
                    }
                    .foregroundStyle(JetterColors.amberGold)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showCards = true
            }
            withAnimation(.easeOut(duration: 1.2).delay(0.5)) {
                animateTimeline = true
            }
        }
    }


    private var routeHeader: some View {
        VStack(spacing: 6) {
            Text(viewModel.routeDisplay)
                .font(JetterTypography.monoLarge)
                .foregroundStyle(.primary)

            Text(viewModel.routeDetail)
                .font(JetterTypography.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.flightInfo.totalFlightDurationInHoursAndMinutes + " flight")
                .font(JetterTypography.caption)
                .foregroundStyle(JetterColors.amberGold)
        }
        .padding(.top, 8)
    }


    private func shareFlightPlan() {
        HapticManager.selection()
        ShareManager.share(
            flightInfo: viewModel.flightInfo,
            schedule: viewModel.schedule,
            severity: viewModel.severity
        )
    }
}
