<p align="center">
  <a href="README.md">English</a> · 简体中文 · <a href="README_JA.md">日本語</a> · <a href="README_KO.md">한국어</a> · <a href="README_ES.md">Español</a>
</p>

<p align="center">
  <img src="assets/cover.png" alt="Quit Other Apps" width="100%">
</p>

# Quit Other Apps

Quit Other Apps 是一个原生 macOS 小工具，用来关闭其他干扰 App，同时保留你指定的 App。

你不需要再编辑 AppleScript 白名单。打开 App，扫描 Applications，把不想关闭的 App 加入保护列表即可。

## 下载

下载最新版本：[`quit-other-apps.dmg`](https://github.com/ai-martin-lau/quit-other-apps-ui/releases/latest/download/quit-other-apps.dmg)

## 工作方式

- 扫描 `/Applications`、`~/Applications` 和 `/System/Applications`。
- 可以从列表加入保护 App，也可以把 Finder 里的 `.app` 拖进保护区。
- 保护列表会用 `UserDefaults` 保存在本机。
- 执行时先关闭 Finder 窗口。
- 永远不会退出 Finder 本身。
- 只发送正常退出请求，不强制杀进程。

## 安装

1. 打开 DMG。
2. 把 `Quit Other Apps.app` 拖到 Applications。
3. 打开 App，选择你想保护的 App。

第一次关闭 Finder 窗口时，macOS 可能会请求自动化权限。允许后，App 才能在不退出 Finder 的前提下关闭 Finder 窗口。

## 签名

本地构建默认使用 ad-hoc 签名。用户仍然可以打开，但首次启动时 macOS 可能会提示开发者来源无法验证。

公开分发时，可以使用 Developer ID 证书签名并 notarize：

```sh
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/build-dmg.sh
NOTARY_PROFILE=quit-other-apps-notary ./scripts/notarize-dmg.sh
```

## 构建

```sh
./scripts/build-dmg.sh
./scripts/verify-release.sh
```

DMG 会生成到 `dist/quit-other-apps.dmg`。
