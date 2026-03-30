import SwiftUI

struct AirportPickerView: View {
    @Binding var selectedAirport: Airport?
    let title: String

    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filteredAirports: [Airport] {
        AirportDatabase.shared.search(query: searchText)
    }

    var body: some View {
        NavigationStack {
            List(filteredAirports) { airport in
                Button {
                    selectedAirport = airport
                    dismiss()
                } label: {
                    AirportRow(airport: airport, isSelected: airport == selectedAirport)
                }
                .listRowBackground(JetterColors.cardBackground)
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "City, airport, or code")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(JetterColors.amberGold)
                }
            }
        }
    }
}


private struct AirportRow: View {
    let airport: Airport
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text(airport.iataCode)
                .font(JetterTypography.monoTime)
                .foregroundStyle(JetterColors.amberGold)
                .frame(width: 50, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(airport.city)
                    .font(JetterTypography.headline)
                    .foregroundStyle(.primary)

                Text(airport.country)
                    .font(JetterTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(JetterColors.amberGold)
            }
        }
        .contentShape(Rectangle())
    }
}
