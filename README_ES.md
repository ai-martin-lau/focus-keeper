<p align="center">
  <a href="README.md">English</a> · <a href="README_ZH.md">简体中文</a> · <a href="README_JA.md">日本語</a> · <a href="README_KO.md">한국어</a> · Español
</p>

<p align="center">
  <img src="assets/cover.png" alt="Quit Other Apps" width="100%">
</p>

# Quit Other Apps

Quit Other Apps es una pequeña utilidad nativa para macOS que cierra distracciones y mantiene abiertas las apps que elijas.

Ya no hace falta editar una lista blanca en AppleScript. Abre la app, escanea Applications y protege las apps que deben permanecer abiertas.

## Descargar

Descarga la última versión: [`quit-other-apps.dmg`](https://github.com/ai-martin-lau/quit-other-apps-ui/releases/latest/download/quit-other-apps.dmg)

## Cómo Funciona

- Escanea `/Applications`, `~/Applications` y `/System/Applications`.
- Permite proteger apps desde la lista o soltando paquetes `.app` desde Finder.
- Guarda la lista protegida localmente con `UserDefaults`.
- Cierra las ventanas de Finder antes de cerrar otras apps.
- Nunca cierra Finder como proceso.
- Envía solicitudes normales de cierre y no fuerza la terminación de procesos.

## Instalación

1. Abre el DMG.
2. Arrastra `Quit Other Apps.app` a Applications.
3. Abre la app y elige las apps que quieres proteger.

La primera vez que la app cierre ventanas de Finder, macOS puede pedir permiso de Automatización. Permítelo para que la app pueda cerrar ventanas sin cerrar Finder.

## Firma

La compilación local usa firma ad-hoc por defecto. Los usuarios pueden abrirla, pero macOS puede mostrar una advertencia de desarrollador no identificado en el primer inicio.

Para distribución pública, firma con un certificado Developer ID y notariza el DMG:

```sh
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/build-dmg.sh
NOTARY_PROFILE=quit-other-apps-notary ./scripts/notarize-dmg.sh
```

## Compilar

```sh
./scripts/build-dmg.sh
./scripts/verify-release.sh
```

El DMG se genera en `dist/quit-other-apps.dmg`.
