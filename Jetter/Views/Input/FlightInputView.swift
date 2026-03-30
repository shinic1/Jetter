import SwiftUI

struct FlightInputView: View {
    @Environment(FlightStore.self) private var flightStore
    @State private var viewModel = FlightInputViewModel()
    @Binding var navigationPath: NavigationPath
    @FocusState private var isFlightNumberFocused: Bool

    /// Whether to show the full flight details form
    private var showFlightDetails: Bool {
        viewModel.entryMode == .manual || viewModel.hasAutoFilled
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                entryModePicker

                if viewModel.entryMode == .flightNumber {
                    flightNumberCard
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if showFlightDetails {
                    if viewModel.entryMode == .manual {
                        PopularRoutesCard(
                            flightInfo: $viewModel.flightInfo,
                            onSelect: {
                                withAnimation(.spring()) {
                                    // Force update
                                }
                            }
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if viewModel.hasAutoFilled {
                        routeSummaryBadge
                            .transition(.opacity.combined(with: .scale))

                        flightDetailsCard
                    } else {
                        AirportSelectionCard(
                            label: "From",
                            airport: viewModel.flightInfo.departureAirport,
                            sfSymbol: "airplane.departure",
                            onTap: { viewModel.showDeparturePicker = true }
                        )

                        AirportSelectionCard(
                            label: "To",
                            airport: viewModel.flightInfo.arrivalAirport,
                            sfSymbol: "airplane.arrival",
                            onTap: { viewModel.showArrivalPicker = true }
                        )

                        if viewModel.hasBothAirports {
                            routeSummaryBadge
                                .transition(.opacity.combined(with: .scale))
                        }
                        DateTimeCard(
                            label: "Departure Date & Time",
                            date: $viewModel.flightInfo.departureDate
                        )

                        DurationCard(
                            label: "Flight Duration",
                            minutes: $viewModel.flightInfo.flightDurationMinutes,
                            estimatedMinutes: viewModel.estimatedFlightMinutes
                        )
                    }

                    SleepScheduleCard(
                        bedtime: $viewModel.flightInfo.normalBedtime,
                        wakeTime: $viewModel.flightInfo.normalWakeTime
                    )

                    calculateButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
            .animation(.spring(duration: 0.35), value: viewModel.entryMode)
            .animation(.spring(duration: 0.35), value: viewModel.hasAutoFilled)
        }
        .background(JetterColors.background.ignoresSafeArea())
        .navigationTitle("Plan Your Flight")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showDeparturePicker) {
            AirportPickerView(
                selectedAirport: $viewModel.flightInfo.departureAirport,
                title: "Departure Airport"
            )
        }
        .sheet(isPresented: $viewModel.showArrivalPicker) {
            AirportPickerView(
                selectedAirport: $viewModel.flightInfo.arrivalAirport,
                title: "Destination Airport"
            )
        }
        .onAppear {
            viewModel.configure(store: flightStore, lookupService: AeroDataBoxService())
            print("FlightInputView: Configured with store")
        }
        .onChange(of: viewModel.flightInfo.departureAirport) { _, _ in
            viewModel.applyEstimateIfNeeded()
        }
        .onChange(of: viewModel.flightInfo.arrivalAirport) { _, _ in
            viewModel.applyEstimateIfNeeded()
        }
    }


    // MARK: - Entry Mode Picker

    private var entryModePicker: some View {
        Picker("Entry Mode", selection: $viewModel.entryMode) {
            ForEach(FlightInputViewModel.EntryMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }


    // MARK: - Flight Number Card

    private var flightNumberCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Flight Number", systemImage: "magnifyingglass")
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)

            TextField("e.g. BA117", text: $viewModel.flightNumberText)
                .font(JetterTypography.monoTime)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isFlightNumberFocused)
                .onSubmit {
                    isFlightNumberFocused = false
                    Task { await viewModel.lookupFlight() }
                }
                .onChange(of: viewModel.flightNumberText) { _, _ in
                    if viewModel.lookupResult != nil || viewModel.lookupError != nil {
                        viewModel.lookupResult = nil
                        viewModel.lookupError = nil
                        viewModel.hasAutoFilled = false
                    }
                }

            Label("Flight Date", systemImage: "calendar")
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            DatePicker(
                "",
                selection: $viewModel.flightDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .labelsHidden()

            lookupButton

            if let result = viewModel.lookupResult {
                autoFilledBadge(result)
                    .transition(.opacity.combined(with: .scale))
            }

            if let error = viewModel.lookupError {
                errorBanner(error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .animation(.easeInOut(duration: 0.25), value: viewModel.lookupResult != nil)
        .animation(.easeInOut(duration: 0.25), value: viewModel.lookupError != nil)
    }

    @ViewBuilder
    private var lookupButton: some View {
        Button {
            isFlightNumberFocused = false
            Task { await viewModel.lookupFlight() }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isLookingUp {
                    ProgressView()
                        .tint(JetterColors.deepNavy)
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Look Up Flight")
                        .font(JetterTypography.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                viewModel.isValidFlightNumber
                    ? JetterColors.amberGold
                    : JetterColors.amberGold.opacity(0.3)
            )
            .foregroundStyle(JetterColors.deepNavy)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(!viewModel.isValidFlightNumber || viewModel.isLookingUp)
    }

    private func autoFilledBadge(_ result: FlightLookupResult) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(result.airlineName ?? result.flightNumber)
                .font(JetterTypography.caption)
            Text("\(result.departureIATA) \u{2192} \(result.arrivalIATA)")
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func errorBanner(_ error: FlightLookupError) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.system(size: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(error.localizedDescription)
                    .font(JetterTypography.caption)
                    .foregroundStyle(.primary)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }


    // MARK: - Flight Details (API-filled)

    private var flightDetailsCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Departure", systemImage: "clock")
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.flightInfo.departureDate, style: .date)
                    .font(JetterTypography.headline)
                Text(viewModel.flightInfo.departureDate, style: .time)
                    .font(JetterTypography.monoTime)
                    .foregroundStyle(JetterColors.amberGold)
            }

            Spacer()

            Divider()
                .frame(height: 40)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Label("Duration", systemImage: "hourglass")
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.flightInfo.totalFlightDurationInHoursAndMinutes)
                    .font(JetterTypography.headline)
            }
        }
        .padding(16)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }


    // MARK: - Existing Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "airplane")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(JetterColors.amberGold)
                .rotationEffect(.degrees(-30))

            Text("Where are you flying?")
                .font(JetterTypography.title2)
                .foregroundStyle(.primary)

            Text("We'll calculate your optimal sleep schedule")
                .font(JetterTypography.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }


    private var routeSummaryBadge: some View {
        HStack(spacing: 12) {
            if let route = viewModel.routeSummary {
                Text(route)
                    .font(JetterTypography.monoTime)
                    .foregroundStyle(.primary)
            }

            if let shift = viewModel.timezoneShiftDescription {
                Text("\u{2022}")
                    .foregroundStyle(.tertiary)
                Text(shift)
                    .font(JetterTypography.caption)
                    .foregroundStyle(JetterColors.amberGold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(JetterColors.cardBackground)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }


    private var calculateButton: some View {
        Button {
            HapticManager.success()
            viewModel.calculate()  // This saves the flight
            let flightInfo = viewModel.flightInfo
            // Navigate to results
            navigationPath.append(flightInfo)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 18))
                Text("Calculate Sleep Schedule")
                    .font(JetterTypography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.flightInfo.isComplete
                    ? JetterColors.amberGold
                    : JetterColors.amberGold.opacity(0.3)
            )
            .foregroundStyle(
                viewModel.flightInfo.isComplete
                    ? JetterColors.deepNavy
                    : JetterColors.deepNavy.opacity(0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(
                color: viewModel.flightInfo.isComplete
                    ? JetterColors.amberGold.opacity(0.3)
                    : .clear,
                radius: 8, y: 4
            )
        }
        .disabled(!viewModel.flightInfo.isComplete)
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.2), value: viewModel.flightInfo.isComplete)
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack {
        FlightInputView(navigationPath: $path)
    }
    .environment(FlightStore())
}
