#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
VERSION="${1:-local}"

APP_PATH="$($ROOT_DIR/Scripts/build-app.sh)"
APP_NAME="BandwidthGuard"
ARCHIVE_NAME="$APP_NAME-$VERSION-macOS.dmg"
ARCHIVE_PATH="$DIST_DIR/$ARCHIVE_NAME"
CHECKSUM_PATH="$ARCHIVE_PATH.sha256.txt"

rm -f "$ARCHIVE_PATH" "$CHECKSUM_PATH"
hdiutil create \
    -volname "Bandwidth Guard" \
    -srcfolder "$APP_PATH" \
    -ov \
    -format UDZO \
    "$ARCHIVE_PATH" >/dev/null

(
    cd "$DIST_DIR"
    shasum -a 256 "$ARCHIVE_NAME" >"$CHECKSUM_PATH"
)

echo "$ARCHIVE_PATH"
