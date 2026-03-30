//
//  ContentView.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @State private var navigationPath = NavigationPath()

    var body: some View {
        ZStack {
            NavigationStack(path: $navigationPath) {
                FlightListView()
                    .navigationDestination(for: String.self) { _ in
                        FlightInputView(navigationPath: $navigationPath)
                    }
                    .navigationDestination(for: FlightInfo.self) { flightInfo in
                        ResultsView(viewModel: SleepResultViewModel(flightInfo: flightInfo))
                    }
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView(isPresented: $showSplash)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
    }
}

#Preview {
    ContentView()
        .environment(FlightStore())
}
