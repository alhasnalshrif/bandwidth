# Architecture

Bandwidth Guard uses a small modular architecture to keep product code understandable without adding unnecessary abstraction.

## Modules

```text
Apps/BandwidthGuard
  App entry point, resources, menu bar shell, and dependency wiring.

Modules/Core
  Platform-light models, persistence contracts, app state, report data, and business rules.

Modules/Discovery
  AppKit-backed running app discovery and system-facing app lookup code.

Modules/UI
  SwiftUI screens, feature views, and reusable presentation components.
```

## Dependency Direction

Dependencies should move inward or sideways only when there is a concrete reason.

```text
BandwidthGuard app
  -> Core
  -> Discovery -> Core
  -> UI -> Core
```

Rules:

- `Core` must not import SwiftUI, AppKit, or NetworkExtension
- `UI` can import SwiftUI and `Core`, but should not own persistence details
- `Discovery` can import AppKit and `Core`, but should not depend on `UI`
- The app target wires modules together and owns app lifecycle concerns
- New protocols should be added only when there is a real boundary, test seam, or second implementation

## Planned Modules

Only extract new modules when the behavior exists and the boundary is clear.

- `Monitoring`: traffic sample contracts and development traffic provider
- `Reporting`: report filtering and export models if report logic grows
- `BandwidthGuardNetworkExtension`: signed system extension for real traffic filtering

## State

Prefer modern SwiftUI and Observation patterns for new stateful UI. Keep state transitions in app/core types where they can be tested, and avoid pushing business rules into view bodies.

## Testing Strategy

- Unit test `Core` calculations, persistence behavior, and rule evaluation
- Keep `Discovery` thin and integration-tested where possible because it depends on macOS APIs
- Add UI tests only for stable user flows once the product behavior settles
- CI should stay fast enough to run on every pull request

## Release Strategy

Release builds are currently unsigned and not notarized. Production distribution should add Developer ID signing, hardened runtime validation, notarization, and packaged release notes before wider public distribution.
