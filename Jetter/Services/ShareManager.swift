//
//  ShareManager.swift
//  Jetter
//
//  Created by Nico Bourel on 2/28/26.
//

import SwiftUI
import UIKit

struct ShareManager {


    static func createShareContent(
        for flightInfo: FlightInfo,
        schedule: SleepSchedule,
        severity: JetLagSeverity
    ) -> ShareContent {

        let title = "✈️ My Jet Lag Battle Plan"

        var message = """
        I'm conquering jet lag on my flight!

        📍 Route: \(flightInfo.departureAirport?.city ?? "Unknown") → \(flightInfo.arrivalAirport?.city ?? "Unknown")
        ⏰ Time shift: \(severity.timezoneShiftHours) hours \(severity.direction == .east ? "ahead" : "behind")
        """

        if !schedule.isTooShortForSleep {
            message += """


            💤 My optimized sleep strategy:
            • Stay awake: First \(schedule.awakeBeforeSleepFormatted)
            • Sleep: \(schedule.sleepDurationFormatted) (\(schedule.numberOfCycles) cycles)
            • Wake up: \(schedule.hoursAfterTakeoffEnd) into flight
            """
        } else {
            message += """


            ☀️ Strategy: Stay awake and adjust on arrival
            """
        }

        message += """


        📱 Get your personalized jet lag plan with Jetter
        Beat jet lag with science-backed sleep optimization!
        """

        return ShareContent(
            title: title,
            message: message,
            image: createShareImage(flightInfo: flightInfo, schedule: schedule, severity: severity)
        )
    }


    static func createShareImage(
        flightInfo: FlightInfo,
        schedule: SleepSchedule,
        severity: JetLagSeverity
    ) -> UIImage? {
        let shareView = ShareImageView(
            flightInfo: flightInfo,
            schedule: schedule,
            severity: severity
        )

        let controller = UIHostingController(rootView: shareView)
        let view = controller.view!

        let targetSize = CGSize(width: 400, height: 500)
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }


    static func share(
        flightInfo: FlightInfo,
        schedule: SleepSchedule,
        severity: JetLagSeverity
    ) {
        let content = createShareContent(
            for: flightInfo,
            schedule: schedule,
            severity: severity
        )

        var items: [Any] = [content.message]
        if let image = content.image {
            items.append(image)
        }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {

            // iPad support
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            rootVC.present(activityVC, animated: true)
            HapticManager.selection()
        }
    }
}


struct ShareContent {
    let title: String
    let message: String
    let image: UIImage?
}


private struct ShareImageView: View {
    let flightInfo: FlightInfo
    let schedule: SleepSchedule
    let severity: JetLagSeverity

    var body: some View {
        VStack(spacing: 20) {
            
            VStack(spacing: 8) {
                Image(systemName: "airplane.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(JetterColors.amberGold)

                Text("Jetter")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Smart Jet Lag Recovery")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            // Route
            VStack(spacing: 4) {
                Text("My Flight")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Text(flightInfo.departureAirport?.iataCode ?? "???")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)

                    Text(flightInfo.arrivalAirport?.iataCode ?? "???")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(.primary)
            }

            // Stats
            HStack(spacing: 24) {
                StatBadge(
                    icon: "clock.fill",
                    value: "\(abs(severity.timezoneShiftHours))h",
                    label: "Time Shift"
                )

                if !schedule.isTooShortForSleep {
                    StatBadge(
                        icon: "moon.zzz.fill",
                        value: "\(schedule.numberOfCycles)",
                        label: "Sleep Cycles"
                    )
                }

                StatBadge(
                    icon: "airplane",
                    value: "\(flightInfo.flightDurationMinutes / 60)h",
                    label: "Duration"
                )
            }

            // Footer
            VStack(spacing: 4) {
                Text("Beat jet lag with science")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Text("Download Jetter")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(JetterColors.amberGold)
            }
        }
        .padding(32)
        .frame(width: 400, height: 500)
        .background(
            LinearGradient(
                colors: [
                    JetterColors.background,
                    JetterColors.amberGold.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

private struct StatBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(JetterColors.amberGold)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}