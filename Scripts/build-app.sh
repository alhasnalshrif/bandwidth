#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GENERATED_WORKSPACE_PATH="$ROOT_DIR/BandwidthGuard.xcworkspace"
TUIST_SCHEME="BandwidthGuard"
CONFIGURATION="Release"
SYMROOT_DIR="$ROOT_DIR/.xcodebuild"
DIST_DIR="$ROOT_DIR/dist"

cd "$ROOT_DIR"

if ! command -v tuist >/dev/null 2>&1; then
    echo "Tuist is required. Install the pinned project version with: mise install" >&2
    exit 1
fi

tuist generate run --no-open >&2

XCODE_COMMON_ARGS=(
    -workspace "$GENERATED_WORKSPACE_PATH"
    -scheme "$TUIST_SCHEME"
    -configuration "$CONFIGURATION"
)

tuist xcodebuild build \
    "${XCODE_COMMON_ARGS[@]}" \
    SYMROOT="$SYMROOT_DIR" \
    DEBUG_INFORMATION_FORMAT=dwarf \
    CODE_SIGNING_ALLOWED=NO >&2

BUILD_SETTINGS="$(xcodebuild "${XCODE_COMMON_ARGS[@]}" SYMROOT="$SYMROOT_DIR" -showBuildSettings)"
TARGET_BUILD_DIR="$(echo "$BUILD_SETTINGS" | awk -F ' = ' '/ TARGET_BUILD_DIR = / { print $2; exit }')"
FULL_PRODUCT_NAME="$(echo "$BUILD_SETTINGS" | awk -F ' = ' '/ FULL_PRODUCT_NAME = / { print $2; exit }')"
APP_SOURCE="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"

if [[ ! -d "$APP_SOURCE" ]]; then
    APP_SOURCE="$(find "$SYMROOT_DIR" -type d -name '*.app' | head -n 1)"
fi

if [[ -z "$APP_SOURCE" || ! -d "$APP_SOURCE" ]]; then
    echo "No .app bundle found from Xcode build output" >&2
    exit 1
fi

APP_NAME="$(basename "$APP_SOURCE")"
APP_DIR="$DIST_DIR/$APP_NAME"
mkdir -p "$DIST_DIR"
setopt local_options null_glob
for existing_app in "$DIST_DIR"/*.app; do
    rm -rf "$existing_app"
done
ditto "$APP_SOURCE" "$APP_DIR"

echo "$APP_DIR"
