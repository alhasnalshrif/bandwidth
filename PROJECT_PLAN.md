# Bandwidth Guard Project Plan

## Current State

Bandwidth Guard is a native macOS menu bar app built with Swift 6, SwiftUI, Swift Package Manager, and Tuist.

Current structure:

```text
Apps/
  BandwidthGuard/

Extensions/
  BandwidthGuardNetworkExtension/

Modules/
  Core/
  Discovery/
  UI/

Tests/
  BandwidthGuardCoreTests/

Scripts/
.github/workflows/
Package.swift
Project.swift
Workspace.swift
Tuist.swift
mise.toml
```

Completed foundation:

- Swift 6 package and Tuist project graph
- Modular `Core`, `Discovery`, and `UI` targets
- macOS menu bar app using `MenuBarExtra`
- Background/menu bar behavior with no Dock icon
- App icon and menu bar logo generated from `logo.png`
- AppKit-backed running app discovery
- Local persistence for app state, profiles, rules, and history models
- Profile/rule UI
- Reports, networks, apps, overview, and settings screens
- Settings page for install location, launch at login, and permission status
- Launch at login toggle using `SMAppService`
- Network Extension scaffold target that builds as `.appex`
- Embedded Network Extension target in the app build
- Basic `NEFilterDataProvider` scaffold that currently allows all flows
- CI workflow for format, lint, tests, workspace generation, app build, and extension build
- Release workflow for tag-based GitHub releases
- Local release packaging script that creates `.zip` and `.sha256`
- MIT license, README, contributing guide, architecture docs, and Claude Code guidance
- Core unit tests for categories and traffic model totals
- SwiftFormat and SwiftLint passing locally

Main missing product capability:

- Real per-app traffic measurement and blocking is not implemented yet.

Important current limitation:

- Release builds are unsigned and not notarized.
- The Network Extension scaffold builds, but macOS will not load it for real traffic filtering without Apple Network Extension entitlements, Developer ID signing, provisioning, and user approval.

## Missing Or Incomplete Features

### 1. Real Traffic Monitoring

Status: not implemented.

Needed:

- Dedicated `Modules/Monitoring` target
- `TrafficSample` and `TrafficSnapshot` models
- `TrafficMonitoringProvider` protocol
- Development/mock provider for UI and persistence testing
- Production provider fed by the Network Extension
- Per-app downloaded/uploaded byte updates
- Blocked-byte updates based on rules
- Daily aggregation from real samples

### 2. Network Extension Production Integration

Status: scaffold only.

Current target:

```text
Extensions/BandwidthGuardNetworkExtension/
```

Current behavior:

- Builds as an app extension
- Contains `FilterDataProvider`
- Allows all flows
- Does not enforce rules
- Does not report real traffic samples back to the app

Needed:

- Apple Developer Program account with Network Extension entitlement approval
- Correct `.entitlements` files for app and extension
- App Group for shared data between containing app and extension
- Signed and provisioned extension build
- `NEFilterManager` activation flow that succeeds on signed builds
- User approval handling in System Settings
- Rule synchronization from app to extension
- Flow metadata mapping to bundle identifiers
- Allow/drop verdict logic
- Traffic sample reporting back to app
- Error recovery if the extension is disabled or approval is revoked

### 3. Permissions And Onboarding

Status: partial.

Completed:

- Settings page shows install location
- Settings page shows launch at login status
- Settings page exposes Network Extension approval action
- App can open Login Items settings

Still needed:

- First-run onboarding flow from the menu bar
- Clear explanation for unsigned builds versus production signed builds
- Network Extension approval status detection after install
- System Settings deep link for Network Extension approval if available
- Health indicator for extension loaded, disabled, needs approval, or failed
- User-facing recovery actions

### 4. Installation And Distribution

Status: local zip only.

Completed:

- `Scripts/package-release.sh v0.1.0`
- `.dmg` release artifact
- `.sha256` checksum
- GitHub release workflow

Still needed:

- Developer ID Application signing
- Hardened runtime validation on signed builds
- Notarization
- Stapling notarization tickets
- `.dmg` installer
- Optional `.pkg` installer if system extension install flow needs it
- Drag-to-Applications installer UI
- Versioned app metadata and release notes
- Sparkle or another update mechanism if auto-update is desired

### 5. Launch At Login And Background Behavior

Status: mostly implemented.

Completed:

- App runs as menu bar/background agent
- No Dock icon
- Launch at login can be toggled through `SMAppService`

Still needed:

- Verify launch at login behavior from an installed `/Applications` build
- Handle `SMAppService.Status.requiresApproval` with clearer UI
- Add automated/manual QA checklist for login item behavior
- Decide whether first launch should open onboarding or stay menu-bar-only

### 6. Real App Rules Enforcement

Status: UI only.

Completed:

- Profiles
- Per-app allow/block toggles
- Default allow behavior
- Rule persistence

Still needed:

- Apply rules in the Network Extension
- Persist shared rules to an App Group container
- Resolve race conditions between UI updates and extension reads
- Add rule conflict handling
- Add tests for rule evaluation
- Add audit logging for blocked flows

### 7. Reporting And Analytics

Status: model/UI scaffold.

Completed:

- Daily total models
- App traffic summary models
- Report range UI

Still needed:

- Reports backed by real traffic samples
- Date-range filtering from persisted data
- Export to CSV or JSON
- Top apps by selected range
- Blocked traffic timeline
- Weekly/monthly rollups
- Empty, loading, and error states backed by real monitoring health

### 8. Persistence Hardening

Status: basic local persistence exists.

Still needed:

- Tests for save/load
- Tests for corrupted persistence recovery
- Versioned persistence schema
- Migration path for future app versions
- App Group persistence layer for extension communication
- Manual reset controls for history and rules

### 9. Testing

Status: basic Core coverage.

Completed:

- Category stability tests
- Traffic total tests
- Byte formatting smoke test

Still needed:

- Profile rule tests
- AppStore filtering tests
- Persistence tests
- Monitoring aggregation tests
- Report range tests
- Network Extension rule evaluation tests
- CI artifact build test for release packaging
- Manual QA checklist for installed app behavior

### 10. CI/CD

Status: useful baseline.

Completed:

- Format check
- SwiftLint
- SwiftPM tests
- Tuist workspace generation
- App build
- Network Extension build
- Tag-based release workflow

Still needed:

- Cache optimization
- Separate release validation job
- Notarization workflow after certificates are available
- Upload signed/notarized artifacts only
- CI check for generated workspace not committed
- CI check for package-release script output

### 11. UI Polish

Status: functional baseline.

Still needed:

- First-run onboarding screen
- Better permission state visuals
- Monitoring health pill in menu bar UI
- Better empty states when no apps are discovered
- Better error messages for extension activation failures
- More polished app icon/menu bar icon variants
- Accessibility labels and VoiceOver review
- Keyboard navigation review

### 12. Product Decisions Still Open

- Should first launch stay menu-bar-only or open onboarding automatically?
- Should the app be App Store distributed, Developer ID distributed, or both?
- Should real blocking be enabled by default or opt-in per profile?
- Should reports store raw samples or aggregated daily records only?
- Should the app support auto-updates?
- Should the extension block traffic or only observe in the first production version?

## Recommended Next Task

Build `Modules/Monitoring` with a development traffic provider before deepening the Network Extension implementation.

Reason:

- The UI can become useful without waiting for Apple entitlements
- Reports and persistence can be tested with realistic data
- AppStore integration can be stabilized before adding system-level complexity
- The Network Extension can later replace the development provider with real samples

## Release Readiness Checklist

Before a public release:

- Confirm app launches as menu-bar-only from `/Applications`
- Confirm launch at login works after install
- Confirm app icon appears in Finder, Dock previews, and menu bar
- Confirm unsigned build warning is documented, or ship a signed/notarized build
- Confirm Network Extension status messaging is honest for unsigned builds
- Run `swiftformat --lint .`
- Run `swiftlint --strict`
- Run `swift test`
- Run Tuist app build
- Run Tuist Network Extension build
- Build release zip and checksum
- Upload release artifact to GitHub
