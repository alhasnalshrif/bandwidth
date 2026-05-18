#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
VERSION="${1:-local}"

APP_PATH="$($ROOT_DIR/Scripts/build-app.sh)"
APP_NAME="$(basename "$APP_PATH" .app)"
ARCHIVE_NAME="$APP_NAME-$VERSION-macOS.zip"
ARCHIVE_PATH="$DIST_DIR/$ARCHIVE_NAME"
CHECKSUM_PATH="$ARCHIVE_PATH.sha256"

rm -f "$ARCHIVE_PATH" "$CHECKSUM_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ARCHIVE_PATH"

(
    cd "$DIST_DIR"
    shasum -a 256 "$ARCHIVE_NAME" >"$CHECKSUM_PATH"
)

echo "$ARCHIVE_PATH"
