#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="$ROOT_DIR/dist/Quit Other Apps.app"
DMG_PATH="$ROOT_DIR/dist/quit-other-apps.dmg"

"$ROOT_DIR/scripts/build-dmg.sh" >/dev/null

codesign --verify --deep --strict --verbose=2 "$APP_PATH"
hdiutil verify "$DMG_PATH"

echo "Verified: $DMG_PATH"
