#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Focus Keeper"
EXECUTABLE_NAME="QuitOtherApps"
BUNDLE_ID="${BUNDLE_ID:-com.martinlau.FocusKeeper}"
VERSION="${VERSION:-0.1.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
CONFIGURATION="${CONFIGURATION:-release}"
ARCH="${ARCH:-$(uname -m)}"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
ICON_SOURCE="$ROOT_DIR/assets/focus-keeper-icon.png"
ICON_FILE="AppIcon.icns"
ICON_TMP_DIR=""
ICONSET_DIR=""

cleanup() {
    if [[ -n "$ICON_TMP_DIR" ]]; then
        rm -rf "$ICON_TMP_DIR"
    fi
}
trap cleanup EXIT

cd "$ROOT_DIR"

swift build -c "$CONFIGURATION" --arch "$ARCH" >&2
BIN_DIR="$(swift build -c "$CONFIGURATION" --arch "$ARCH" --show-bin-path)"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BIN_DIR/$EXECUTABLE_NAME" "$APP_DIR/Contents/MacOS/$EXECUTABLE_NAME"

sed \
    -e "s/__BUNDLE_ID__/$BUNDLE_ID/g" \
    -e "s/__VERSION__/$VERSION/g" \
    -e "s/__BUILD__/$BUILD_NUMBER/g" \
    "$ROOT_DIR/packaging/Info.plist.in" > "$APP_DIR/Contents/Info.plist"

if [[ ! -f "$ICON_SOURCE" ]]; then
    echo "Missing app icon source: $ICON_SOURCE" >&2
    exit 1
fi

ICON_TMP_DIR="$(mktemp -d)"
ICONSET_DIR="$ICON_TMP_DIR/AppIcon.iconset"
mkdir -p "$ICONSET_DIR"
for icon in \
    "16 icon_16x16.png" \
    "32 icon_16x16@2x.png" \
    "32 icon_32x32.png" \
    "64 icon_32x32@2x.png" \
    "128 icon_128x128.png" \
    "256 icon_128x128@2x.png" \
    "256 icon_256x256.png" \
    "512 icon_256x256@2x.png" \
    "512 icon_512x512.png" \
    "1024 icon_512x512@2x.png"
do
    size="${icon%% *}"
    name="${icon#* }"
    sips -z "$size" "$size" "$ICON_SOURCE" --out "$ICONSET_DIR/$name" >/dev/null
done
iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/$ICON_FILE"

if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
    codesign --force --deep --options runtime --sign "$CODESIGN_IDENTITY" "$APP_DIR" >&2
else
    codesign --force --deep --sign - "$APP_DIR" >&2
fi

echo "$APP_DIR"
