//
//  JetterApp.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

@main
struct JetterApp: App {
    @State private var flightStore = FlightStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(flightStore)
                .preferredColorScheme(nil)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }


    private func handleDeepLink(_ url: URL) {
        // Expected format: jetter://flight?id=<flight-id>
        // For now, just opening the app is sufficient
        // Future: Navigate to specific flight's ResultsView
        print("Deep link received: \(url)")
    }
}
