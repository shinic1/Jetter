//
//  JetterComponents.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI


struct JetterCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(JetterColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}


struct AirportSelectionCard: View {
    let label: String
    let airport: Airport?
    let sfSymbol: String
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.selection()
            onTap()
        }) {
            HStack(spacing: 16) {
                Image(systemName: sfSymbol)
                    .font(.system(size: 24))
                    .foregroundStyle(JetterColors.amberGold)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(JetterTypography.caption)
                        .foregroundStyle(.secondary)

                    if let airport {
                        Text(airport.displayName)
                            .font(JetterTypography.headline)
                            .foregroundStyle(.primary)
                    } else {
                        Text("Select Airport")
                            .font(JetterTypography.headline)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(JetterColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}


struct DateTimeCard: View {
    let label: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: "calendar")
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)

            DatePicker(
                "",
                selection: $date,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}


struct DurationCard: View {
    let label: String
    @Binding var minutes: Int
    var estimatedMinutes: Int? = nil

    @State private var isExpanded = false
    @State private var selectedHours: Int = 0
    @State private var selectedMinuteBlock: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isExpanded.toggle() } }) {
                HStack {
                    Label(label, systemImage: "clock")
                        .font(JetterTypography.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(minutes > 0 ? formattedDuration : "Set Duration")
                        .font(JetterTypography.headline)
                        .foregroundStyle(minutes > 0 ? .primary : .tertiary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)

            // Estimate label
            if let est = estimatedMinutes {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text("Est. \(formatMinutes(est))")
                        .font(JetterTypography.caption)

                    if minutes != est {
                        Button {
                            applyEstimate(est)
                        } label: {
                            Text("Use estimate")
                                .font(JetterTypography.caption)
                                .underline()
                        }
                    }
                }
                .foregroundStyle(JetterColors.amberGold)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if isExpanded {
                HStack(spacing: 0) {
                    Picker("Hours", selection: $selectedHours) {
                        ForEach(0..<25) { h in
                            Text("\(h)h").tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    .clipped()

                    Picker("Minutes", selection: $selectedMinuteBlock) {
                        ForEach(0..<12) { i in
                            Text("\(i * 5)m").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
                .frame(height: 150)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .onChange(of: selectedHours) { _, _ in
                    minutes = selectedHours * 60 + selectedMinuteBlock * 5
                }
                .onChange(of: selectedMinuteBlock) { _, _ in
                    minutes = selectedHours * 60 + selectedMinuteBlock * 5
                }
            }
        }
        .padding(16)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .onAppear {
            syncPickers()
        }
        .onChange(of: minutes) { _, _ in
            syncPickers()
        }
    }

    private func syncPickers() {
        selectedHours = minutes / 60
        selectedMinuteBlock = (minutes % 60) / 5
    }

    private func applyEstimate(_ est: Int) {
        minutes = est
        syncPickers()
    }

    private var formattedDuration: String {
        formatMinutes(minutes)
    }

    private func formatMinutes(_ value: Int) -> String {
        let h = value / 60
        let m = value % 60
        if m > 0 {
            return "\(h)h \(m)m"
        }
        return "\(h)h"
    }
}


struct SleepScheduleCard: View {
    @Binding var bedtime: Date
    @Binding var wakeTime: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Your Normal Sleep Schedule", systemImage: "bed.double.fill")
                .font(JetterTypography.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                // Bedtime picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "moon.fill")
                            .font(.caption2)
                            .foregroundStyle(JetterColors.amberGold)
                        Text("Bedtime")
                            .font(JetterTypography.caption)
                            .foregroundStyle(.secondary)
                    }

                    DatePicker(
                        "",
                        selection: $bedtime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }

                Divider()
                    .frame(height: 40)

                // Wake time picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "sun.max.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("Wake Time")
                            .font(JetterTypography.caption)
                            .foregroundStyle(.secondary)
                    }

                    DatePicker(
                        "",
                        selection: $wakeTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }
            }
        }
        .padding(16)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}


struct JetterBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(JetterTypography.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
    }
}
