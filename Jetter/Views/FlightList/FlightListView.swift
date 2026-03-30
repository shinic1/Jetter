import SwiftUI

struct FlightListView: View {
    @Environment(FlightStore.self) private var flightStore

    @State private var showCards = false

    var body: some View {
        ZStack {
            JetterColors.background.ignoresSafeArea()

            if flightStore.flights.isEmpty {
                emptyState
            } else {
                flightList
            }
        }
        .navigationTitle("My Flights")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: "flightInput") {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(JetterColors.amberGold)
                }
            }
        }
    }


    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "airplane.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(JetterColors.amberGold.opacity(0.6))

            Text("No Flights Yet")
                .font(JetterTypography.title2)
                .foregroundStyle(.primary)

            Text("Add your first flight to get a\npersonalized sleep schedule")
                .font(JetterTypography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            NavigationLink(value: "flightInput") {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Add Flight")
                        .font(JetterTypography.headline)
                }
                .frame(maxWidth: 280)
                .padding(.vertical, 16)
                .background(JetterColors.amberGold)
                .foregroundStyle(JetterColors.deepNavy)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: JetterColors.amberGold.opacity(0.3), radius: 8, y: 4)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
    }


    private var flightList: some View {
        List {
            ForEach(Array(flightStore.flights.enumerated()), id: \.element.id) { index, flight in
                ZStack {
                    NavigationLink(value: flight.flightInfo) {
                        EmptyView()
                    }
                    .opacity(0)

                    FlightCardView(flight: flight)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        withAnimation {
                            flightStore.delete(flight)
                        }
                    } label: {
                        Label("Delete Flight", systemImage: "trash")
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 15)
                .animation(
                    .easeOut(duration: 0.5).delay(Double(index) * 0.08),
                    value: showCards
                )
            }
            .onDelete { offsets in
                flightStore.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onAppear {
            print("FlightListView: Showing \(flightStore.flights.count) flights")
            withAnimation {
                showCards = true
            }
        }
    }
}
