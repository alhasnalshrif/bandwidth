# Bandwidth Guard

Bandwidth Guard is a menu bar app for macOS that shows where your internet is going, app by app, in real time.

If your Mac feels slow, one glance tells you who is eating your data.

## Why People Share It

- Instant clarity: see top network-hungry apps in seconds
- Zero dashboard fatigue: everything lives in your menu bar
- Daily history: track spikes and spot patterns over time
- Profile-based controls: switch monitoring behavior fast
- Built for focus: lightweight, fast, and privacy-first on-device

## One-Line Pitch

"Finally, Activity Monitor for your bandwidth."

## Features

- Live traffic monitoring per app
- Overview metrics for used and blocked traffic
- Reports with daily summaries
- Network profiles and app categories
- macOS-native SwiftUI interface

## Screens in the App

- Overview
- Apps
- Reports
- Networks
- Settings

## Tech Stack

- Swift 6
- SwiftUI
- AppKit integration for menu bar behavior
- Swift Package Manager
- Tuist-generated Xcode project setup
- Mise-pinned developer tooling
- SwiftFormat and SwiftLint configuration

## Run Locally

```bash
swift run
```

## Generate the Xcode Project

Tuist is now the source of truth for the Xcode project graph.

```bash
tuist generate run
open BandwidthGuard.xcworkspace
```

If Mise is not installed yet, install it first from the official Mise instructions. Then install the pinned project tools:

```bash
mise install
```

Tuist is pinned in `mise.toml` so every machine uses the same project generator version.

## Build and Test

```bash
tuist generate run --no-open
tuist xcodebuild build -workspace BandwidthGuard.xcworkspace -scheme BandwidthGuard -configuration Debug
tuist xcodebuild test -workspace BandwidthGuard.xcworkspace -scheme BandwidthGuard -configuration Debug
```

SwiftPM still works for package-level checks:

```bash
swift test
```

## Format and Lint

```bash
swiftformat .
swiftlint
```

## Build a .app Bundle

```bash
./Scripts/build-app.sh
```

The script requires Tuist, generates the workspace, and outputs the app bundle under `dist/`.

## Project Structure

- `Apps/BandwidthGuard` macOS app entry point and app resources
- `Modules/Core` models, persistence, state, and core protocols
- `Modules/Discovery` AppKit-backed running-app discovery
- `Modules/UI` SwiftUI feature screens and reusable components
- `Project.swift` Tuist project definition
- `Workspace.swift` Tuist workspace definition
- `Tuist.swift` Tuist generation options
- `mise.toml` pinned Tuist version
- `Tests` unit tests
- `Scripts` helper build scripts

## Roadmap

- Signed Network Extension integration for real traffic blocking
- Advanced filtering rules and alerts
- Exportable usage reports

## License

Private/internal project (add a license if you plan to open source).
