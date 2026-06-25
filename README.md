<p align="center">
  English · <a href="README_ZH.md">简体中文</a> · <a href="README_JA.md">日本語</a> · <a href="README_KO.md">한국어</a> · <a href="README_ES.md">Español</a>
</p>

<p align="center">
  <img src="assets/cover.png" alt="Quit Other Apps" width="100%">
</p>

# Quit Other Apps

Quit Other Apps is a small native macOS utility for closing distractions while keeping the apps you choose.

Instead of editing an AppleScript whitelist, open the app, scan Applications, and protect the apps that should stay open.

## Download

Download the latest version: [`quit-other-apps.dmg`](https://github.com/ai-martin-lau/quit-other-apps-ui/releases/latest/download/quit-other-apps.dmg)

## How It Works

- Scans `/Applications`, `~/Applications`, and `/System/Applications`.
- Adds protected apps from the list or by dropping `.app` bundles from Finder.
- Saves the protected app list locally with `UserDefaults`.
- Closes Finder windows before quitting other apps.
- Never quits Finder itself.
- Sends normal quit requests and does not force-kill processes.

## Installation

1. Open the DMG.
2. Drag `Quit Other Apps.app` into Applications.
3. Open the app and choose the apps you want to protect.

The first time the app closes Finder windows, macOS may ask for Automation permission. Allow it so the app can close Finder windows while keeping Finder running.

## Signing

The local build is ad-hoc signed by default. Users can still open it, but macOS may show an unidentified-developer warning on first launch.

To reduce that warning for public distribution, sign with a Developer ID certificate and notarize the DMG:

```sh
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/build-dmg.sh
NOTARY_PROFILE=quit-other-apps-notary ./scripts/notarize-dmg.sh
```

## Build

```sh
./scripts/build-dmg.sh
./scripts/verify-release.sh
```

The DMG is written to `dist/quit-other-apps.dmg`.
