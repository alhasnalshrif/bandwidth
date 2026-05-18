# Contributing

Thanks for helping improve Bandwidth Guard.

## Local Setup

Install the pinned project tools and open the generated workspace:

```bash
mise install
tuist generate run
open BandwidthGuard.xcworkspace
```

Install formatting and linting tools if they are not already available:

```bash
brew install swiftformat swiftlint
```

## Checks

Run these before opening a pull request:

```bash
swiftformat --lint .
swiftlint --strict
swift test
tuist generate run --no-open
tuist xcodebuild build -workspace BandwidthGuard.xcworkspace -scheme BandwidthGuard -configuration Debug CODE_SIGNING_ALLOWED=NO
```

## Git Hooks

Optional local pre-commit hooks are included in `.githooks`.

```bash
./Scripts/install-git-hooks.sh
```

The hook runs SwiftFormat in lint mode, SwiftLint in strict mode, and SwiftPM tests.

## Pull Requests

- Keep changes focused and small where possible
- Include tests for behavior changes in `Modules/Core`
- Keep UI changes aligned with the existing SwiftUI style
- Do not add abstractions unless there is a concrete reuse or boundary benefit
- Update documentation when commands, release behavior, or architecture changes
