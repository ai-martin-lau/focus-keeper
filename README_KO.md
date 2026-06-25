<p align="center">
  <a href="README.md">English</a> · <a href="README_ZH.md">简体中文</a> · <a href="README_JA.md">日本語</a> · 한국어 · <a href="README_ES.md">Español</a>
</p>

<p align="center">
  <img src="assets/cover.png" alt="Quit Other Apps" width="100%">
</p>

# Quit Other Apps

Quit Other Apps는 사용자가 보호한 앱은 그대로 두고, 다른 일반 전면 앱에 정상 종료 요청을 보내는 작은 네이티브 macOS 유틸리티입니다.

이제 AppleScript의 화이트리스트를 직접 수정할 필요가 없습니다. 앱을 열고 Applications를 스캔한 뒤, 종료하지 않을 앱을 보호 목록에 추가하면 됩니다.

## 다운로드

최신 버전 다운로드: [`focus-keeper.dmg`](https://github.com/ai-martin-lau/focus-keeper/releases/latest/download/focus-keeper.dmg)

## 동작 방식

- `/Applications`, `~/Applications`, `/System/Applications`를 스캔합니다.
- 목록에서 추가하거나 Finder에서 `.app` 번들을 드롭해 보호할 수 있습니다.
- 보호 목록은 `UserDefaults`로 로컬에 저장됩니다.
- 다른 앱을 종료하기 전에 Finder 창을 먼저 닫습니다.
- Finder 자체는 절대 종료하지 않습니다.
- 강제 종료가 아니라 정상 종료 요청만 보냅니다.

## 설치

1. DMG를 엽니다.
2. `Quit Other Apps.app`을 Applications로 드래그합니다.
3. 앱을 열고 보호할 앱을 선택합니다.

처음 실행할 때 macOS가 앱을 차단하는 경우:

1. 시스템 설정을 엽니다.
2. 개인정보 보호 및 보안으로 이동합니다.
3. 보안 섹션까지 스크롤한 뒤 `Quit Other Apps.app`의 Open Anyway를 클릭합니다.
4. macOS가 다시 물으면 Open을 확인합니다.

처음 Finder 창을 닫을 때 macOS가 자동화 권한을 요청할 수 있습니다. Finder를 종료하지 않고 창만 닫으려면 허용해야 합니다.

## 소스에서 빌드

```sh
./scripts/build-dmg.sh
./scripts/verify-release.sh
```

DMG는 `dist/focus-keeper.dmg`에 생성됩니다.
