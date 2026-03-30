# Jetter

Jetter is an iOS app for planning sleep around long-haul travel. It helps you turn a flight into a practical jet-lag strategy by combining route data, timezone math, sleep-cycle timing, meal scheduling, and pre-flight preparation guidance.

The app supports two ways to build a plan:

- Look up a flight by number and date using AeroDataBox via RapidAPI.
- Enter the route and timing manually when you do not want to rely on live flight data.

## What the App Does

- Stores flights locally and shows them in a saved flights list.
- Lets you create a trip from a flight number or from manual airport/time input.
- Searches a bundled airport database for route selection.
- Estimates flight duration when airports are known but a duration has not been entered.
- Calculates an in-flight sleep window based on route, duration, and arrival timezone.
- Scores jet lag severity and estimated recovery time.
- Generates meal timing suggestions, readiness scoring, smart tips, and pre-flight prep guidance.
- Builds a shareable summary image and text snippet for the trip plan.

## Product Flow

1. Open the app to a saved flights list.
2. Add a new trip from the `+` button.
3. Choose `Flight Number` for API-assisted autofill or `Manual Entry` for a fully local workflow.
4. Enter normal bedtime and wake time so the schedule can adapt to the traveler.
5. Review the generated plan in the results screen.

The results experience includes:

- A flight timeline with the recommended sleep block.
- Meal service guidance when the schedule includes meals.
- A circadian timeline view.
- Pre-flight preparation guidance for upcoming trips.
- Sleep window and sleep cycle summaries.
- A jet lag severity gauge.
- A travel readiness score.
- Practical tips for the route and timezone shift.

## Key Features

### Flight Lookup

`Flight Number` mode uses `AeroDataBoxService` to fetch scheduled departure details, airports, and duration for a given flight number and date. Results are cached in memory during the session to avoid repeated lookups for the same flight/date combination.

If live lookup fails, the app surfaces a recovery message and the user can fall back to manual entry.

### Manual Planning

`Manual Entry` mode works without any API key. Users pick departure and arrival airports from the bundled airport database, choose departure date/time, confirm or edit the estimated duration, and then generate a sleep plan.

### Timezone-Aware Recommendations

The planning layer uses the departure and arrival timezones to:

- measure timezone shift
- determine eastbound vs westbound travel
- estimate recovery difficulty
- choose when the traveler should wake relative to landing
- place a realistic sleep block inside the flight window

### Local-First Flight Storage

Saved flights are stored on-device as JSON in the app's documents directory. On a fresh install, the app seeds sample flights so the UI is not empty on first launch.

### Shareable Output

The results screen can generate a share sheet payload with:

- a text summary of the route and sleep strategy
- a rendered share card image built from SwiftUI

## Architecture Overview

Jetter is a SwiftUI app with a fairly clean split between views, view models, domain models, and calculation or networking services.

- `Jetter/Views/` contains the UI flow for flight list, input, onboarding, results, and circadian timeline screens.
- `Jetter/ViewModels/` owns flight input state and result composition.
- `Jetter/Models/` contains route, airport, sleep, meal, readiness, and API response models.
- `Jetter/Services/` contains the calculation and integration layer.
- `Jetter/DesignSystem/` defines the app's colors, typography, components, shapes, and animations.
- `Jetter/Resources/airports.json` provides the bundled airport dataset used for manual search.

Important services:

- `FlightStore`: local persistence for saved trips.
- `AirportDatabase`: bundled airport search and fallback airport creation for API results.
- `AeroDataBoxService`: live flight lookup.
- `SleepCalculator`: core in-flight sleep window calculation.
- `JetLagCalculator`: timezone shift severity and recovery estimate.
- `MealServiceCalculator`: meal scheduling around the sleep plan.
- `ReadinessCalculator`: travel readiness scoring.
- `PreFlightPreparationCalculator`: preparation timeline generation.
- `ShareManager`: share text and image generation.

## Tech Stack

- SwiftUI for the app UI
- Swift observation via `@Observable`
- Foundation networking with a small `NetworkClient`
- Local JSON persistence
- Bundled JSON resource data for airport search
- UIKit interop for the share sheet

## Repository Layout

```text
Jetter/
├── Jetter.xcodeproj
├── Jetter/
│   ├── Assets.xcassets/
│   ├── Configuration/
│   ├── DesignSystem/
│   ├── Models/
│   ├── Resources/
│   ├── Services/
│   ├── ViewModels/
│   └── Views/
└── README.md
```

## Local Development

### Requirements

- macOS with Xcode installed
- The current project is configured with an iOS deployment target of `26.2`

### Run the App

1. Open `Jetter.xcodeproj` in Xcode.
2. Choose an iPhone simulator or device target.
3. Build and run the `Jetter` scheme.

### Enable Live Flight Lookup

Live flight lookup is optional. The app can still be used in manual mode without it.

1. Copy `Jetter/Configuration/APIKeys.plist.example` to `Jetter/Configuration/APIKeys.plist`.
2. Replace `YOUR_RAPIDAPI_KEY` with a valid AeroDataBox RapidAPI key.
3. Build and run the app.

The lookup layer expects a plist key named `AeroDataBoxKey`.

## Secrets and Public Repo Safety

This repository is prepared to be public.

- `Jetter/Configuration/APIKeys.plist` is gitignored.
- `Jetter/Configuration/Secrets.xcconfig` is gitignored.
- Example files are included for local setup.
- The Xcode project excludes those local config files from target membership, so they are not bundled into the built app by default.

If you clone this repo, do not commit real credentials into `Configuration/`.

## Data and Persistence Notes

- Saved flights are written to `saved_flights.json` in the app's documents directory.
- Airport search uses the bundled `airports.json` file.
- If an airport returned by the API is missing from the bundled dataset, the app creates a minimal in-memory fallback airport model from API data.

## Current Scope

What is implemented today:

- saved flights list
- flight lookup by number
- manual route entry
- timezone-aware sleep planning
- meal guidance
- pre-flight preparation timeline
- circadian timeline
- readiness scoring
- shareable plan output

What appears to be scaffolded for future work:

- deep linking into a specific saved flight

## Notes for Contributors

- Manual entry should remain functional even when no API key is configured.
- Public changes should preserve the current secret-handling setup.
- If you add new local config files, update `.gitignore` and the Xcode project membership rules so they cannot be committed or bundled accidentally.
