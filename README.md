# Bandwidth Guard

> A privacy-first macOS menu bar app for understanding where your internet bandwidth goes, app by app.

[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://www.swift.org)
[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue.svg)](https://developer.apple.com/macos/)
[![Built with Tuist](https://img.shields.io/badge/Built%20with-Tuist-6E56CF.svg)](https://tuist.io)
[![CI](https://github.com/alhasnalshrif/bandwidth/actions/workflows/ci.yml/badge.svg)](https://github.com/alhasnalshrif/bandwidth/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Bandwidth Guard brings an Activity Monitor-style view of network usage to your menu bar. It is designed to help you spot noisy apps, understand daily traffic patterns, and build toward profile-based bandwidth control without sending usage data off your Mac.

## Highlights

- See network-heavy apps from a lightweight menu bar interface
- Browse app-level usage, categories, reports, network profiles, and settings
- Keep data local with a privacy-first architecture
- Use a modular Swift 6 codebase split into Core, Discovery, and UI packages
- Generate a reproducible Xcode workspace with Tuist and pinned tooling
- Run package-level tests with Swift Package Manager

## Project Status

Bandwidth Guard is in active early development.

The current app includes the macOS shell, SwiftUI screens, app discovery, persistence models, profile/rule UI, and basic tests. Real per-app traffic monitoring and blocking are planned next and will require a signed macOS Network Extension plus Apple Developer provisioning.

## Screens

The app is organized around five focused areas:

- **Overview**: quick totals and current network activity
- **Apps**: app-by-app usage and categorization
- **Reports**: daily summaries and usage history
- **Networks**: profile-based monitoring and control concepts
- **Settings**: app preferences and local behavior

## Tech Stack

- Swift 6
- SwiftUI
- AppKit integration for menu bar behavior and running app discovery
- Network Extension scaffold for future traffic filtering
- Swift Package Manager
- Tuist-generated Xcode workspace
- Mise-pinned developer tooling
- SwiftFormat and SwiftLint

## Requirements

- macOS 14 or newer
- Xcode 16 or newer with Swift 6 support
- Swift Package Manager
- Tuist, preferably installed through Mise

## Quick Start

Clone the repository, install pinned tools, generate the workspace, and open it in Xcode:

```bash
mise install
tuist generate run
open BandwidthGuard.xcworkspace
```

You can also run package-level checks directly with SwiftPM:

```bash
swift test
```

## Build

Generate the workspace without opening Xcode:

```bash
tuist generate run --no-open
```

Build the app scheme:

```bash
tuist xcodebuild build -workspace BandwidthGuard.xcworkspace -scheme BandwidthGuard -configuration Debug
```

Run the test suite:

```bash
tuist xcodebuild test -workspace BandwidthGuard.xcworkspace -scheme BandwidthGuard -configuration Debug
```

Build a local `.app` bundle into `dist/`:

```bash
./Scripts/build-app.sh
```

Build the Network Extension scaffold:

```bash
tuist xcodebuild build -workspace BandwidthGuard.xcworkspace -scheme BandwidthGuardNetworkExtension -configuration Debug CODE_SIGNING_ALLOWED=NO
```

Package a local DMG release artifact with a SHA-256 checksum:

```bash
./Scripts/package-release.sh v0.1.0
```

## Format and Lint

```bash
swiftformat .
swiftlint
```

CI runs formatting, linting, SwiftPM tests, Tuist workspace generation, and an unsigned Debug app build on pull requests and pushes to `main`.

## Architecture

```text
Apps/
  BandwidthGuard/          macOS app entry point and resources

Modules/
  Core/                    models, persistence, state, and app logic
  Discovery/               AppKit-backed running app discovery
  UI/                      SwiftUI screens and shared components

Tests/
  BandwidthGuardCoreTests/ unit tests for core behavior

Scripts/                   helper scripts for local builds
```

Tuist owns the Xcode project graph through `Project.swift`, `Workspace.swift`, and `Tuist.swift`. SwiftPM remains available for package-level development and tests through `Package.swift`.

See `ARCHITECTURE.md` for module boundaries, dependency rules, and testing strategy.

## Roadmap

- Add a dedicated monitoring module and development traffic provider
- Connect traffic snapshots to app state and daily history
- Integrate a signed Network Extension for real traffic monitoring and blocking
- Expand unit coverage for formatting, persistence, reporting, and rules
- Add exportable usage reports
- Add release packaging, signing, notarization, and distribution automation

## Release

Releases are published from version tags that start with `v`.

```bash
git tag v0.1.0
git push origin v0.1.0
```

The release workflow builds the macOS app on GitHub Actions, packages `Bandwidth Guard.app` as a DMG, writes a `.sha256.txt` checksum, and attaches both files to the GitHub release.

Current release builds are unsigned and not notarized. Users may need to allow the app manually in macOS Gatekeeper until signing and notarization are added.

The Network Extension target is scaffolded for development, but real installation and packet filtering require Apple Network Extension entitlements, signing, and user approval in System Settings.

## Contributing

Contributions are welcome.

Good first areas include tests, UI polish, reporting improvements, documentation, and development-only traffic simulation. Before opening a pull request, please format the project and run the relevant checks:

```bash
swiftformat .
swiftlint
swift test
```

See `CONTRIBUTING.md` for the full local workflow and optional pre-commit hooks.

## Privacy

Bandwidth Guard is designed around local-first behavior. Usage and profile data should remain on device unless an explicit export or sharing feature is added in the future.

## macOS Integration

The Settings window shows whether the app is running from `/Applications`, lets users enable or disable launch at login, and explains the current Network Extension permission state.

Launch at login uses Apple's `SMAppService`. Real traffic filtering still requires the Network Extension target to be signed with the correct Apple entitlements and approved by the user in System Settings.

## License

Bandwidth Guard is released under the MIT License. See `LICENSE` for details.
