<p align="center">
  <a href="README.md">English</a> · <a href="README_ZH.md">简体中文</a> · 日本語 · <a href="README_KO.md">한국어</a> · <a href="README_ES.md">Español</a>
</p>

<p align="center">
  <img src="assets/cover.png" alt="Quit Other Apps" width="100%">
</p>

# Quit Other Apps

Quit Other Apps は、指定したアプリを残したまま、ほかの前面アプリに通常の終了リクエストを送る小さなネイティブ macOS ユーティリティです。

AppleScript のホワイトリストを編集する必要はありません。アプリを開き、Applications をスキャンして、閉じたくないアプリを保護リストに追加します。

## ダウンロード

最新バージョン：[`quit-other-apps.dmg`](https://github.com/ai-martin-lau/focus-keeper/releases/latest/download/quit-other-apps.dmg)

## 動作

- `/Applications`、`~/Applications`、`/System/Applications` をスキャンします。
- 一覧から追加するか、Finder から `.app` バンドルをドロップして保護できます。
- 保護リストは `UserDefaults` にローカル保存されます。
- ほかのアプリを終了する前に Finder ウィンドウを閉じます。
- Finder 自体は終了しません。
- 強制終了ではなく、通常の終了リクエストだけを送ります。

## インストール

1. DMG を開きます。
2. `Quit Other Apps.app` を Applications にドラッグします。
3. アプリを開き、残しておきたいアプリを選びます。

初回起動時に macOS がアプリをブロックした場合：

1. システム設定を開きます。
2. プライバシーとセキュリティに移動します。
3. セキュリティまでスクロールし、`Quit Other Apps.app` の Open Anyway をクリックします。
4. macOS の確認ダイアログで Open を選びます。

初回に Finder ウィンドウを閉じるとき、macOS が自動化権限を求める場合があります。Finder を終了せずにウィンドウだけを閉じるために許可してください。

## ソースからビルド

```sh
./scripts/build-dmg.sh
./scripts/verify-release.sh
```

DMG は `dist/quit-other-apps.dmg` に生成されます。
