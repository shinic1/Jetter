import SwiftUI

struct DurationPickerView: View {
    @Binding var totalMinutes: Int

    @State private var hours: Int
    @State private var minuteSegment: Int

    init(totalMinutes: Binding<Int>) {
        self._totalMinutes = totalMinutes
        let initial = totalMinutes.wrappedValue
        self._hours = State(initialValue: initial / 60)
        self._minuteSegment = State(initialValue: (initial % 60) / 15)
    }

    var body: some View {
        HStack(spacing: 0) {
            Picker("Hours", selection: $hours) {
                ForEach(0..<25) { h in
                    Text("\(h)h").tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()

            Picker("Minutes", selection: $minuteSegment) {
                Text("0m").tag(0)
                Text("15m").tag(1)
                Text("30m").tag(2)
                Text("45m").tag(3)
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .onChange(of: hours) { _, _ in
            totalMinutes = hours * 60 + minuteSegment * 15
        }
        .onChange(of: minuteSegment) { _, _ in
            totalMinutes = hours * 60 + minuteSegment * 15
        }
    }
}
