# Bandwidth Guard Project Plan

## Current State

Bandwidth Guard is now structured as a modern native macOS Swift project:

```text
Apps/
  BandwidthGuard/

Modules/
  Core/
  Discovery/
  UI/

Tests/
  BandwidthGuardCoreTests/

Package.swift
Project.swift
Workspace.swift
Tuist.swift
mise.toml
```

The app currently has:

- Swift 6
- SwiftPM modules
- Tuist project generation manifests
- SwiftUI menu bar UI
- AppKit-backed running app discovery
- Local persistence
- Profile/rule UI
- Basic unit test coverage
- SwiftFormat and SwiftLint config

The main missing product capability is real per-app network traffic monitoring and blocking.

## Immediate Priorities

### 1. Verify Tooling

Install the pinned tools and verify the generated project:

```bash
mise install
tuist generate run --no-open
tuist xcodebuild build -workspace BandwidthGuard.xcworkspace -scheme BandwidthGuard -configuration Debug
swift test
```

If Git is not available in this folder, restore the original `.git` directory or initialize a new repository before larger changes.

### 2. Add Monitoring Module

Create a dedicated monitoring module:

```text
Modules/
  Monitoring/
    Sources/
```

Core types:

```swift
struct TrafficSample
struct TrafficSnapshot
protocol TrafficMonitoringService
protocol TrafficMonitoringProvider
```

This module should own traffic data contracts without depending on UI or AppKit discovery.

### 3. Add Development Traffic Provider

Before implementing Network Extension support, add a development provider that emits realistic sample traffic.

Purpose:

- Exercise the UI
- Test reports
- Validate persistence
- Avoid blocking progress on Apple entitlements

### 4. Connect AppStore to Monitoring

Update `AppStore` so it consumes monitoring snapshots instead of only managing discovered apps.

Expected behavior:

- Merge running app discovery with traffic samples
- Update downloaded/uploaded totals
- Track blocked bytes
- Persist daily history
- Respect selected network profile rules

### 5. Expand Tests

Add tests for:

- Byte formatting
- Profile rule application
- Traffic aggregation
- Daily report filtering
- Persistence save/load
- Invalid persistence recovery

## Medium-Term Plan

### 6. Reporting Module

If reporting logic grows, extract it:

```text
Modules/
  Reporting/
```

Responsibilities:

- Daily totals
- App summaries
- Date-range filtering
- Export-ready report models

### 7. Network Extension Integration

After the app works with the development provider, add real macOS traffic control.

Targets:

```text
Apps/
  BandwidthGuardNetworkExtension/
```

Likely APIs:

- `NEFilterDataProvider`
- `NEFilterControlProvider`
- App Groups
- Shared rule store
- Signed Network Extension entitlements

Important: this requires Apple Developer Program access and correct provisioning.

### 8. Packaging and Release

Add release automation:

- Code signing
- Hardened runtime
- Notarization
- `.dmg` or `.pkg` packaging
- Release build script
- CI checks

## Product Polish

Later product improvements:

- First-run onboarding
- Permission/status screen
- Monitoring health indicator
- Export reports
- Reset rules/history controls
- Profile auto-detection
- Better empty/loading/error states

## Recommended Next Task

Start with `Modules/Monitoring` and a development provider.

That gives the app real data flow quickly, lets the UI become useful, and keeps the architecture ready for Network Extension support later.
