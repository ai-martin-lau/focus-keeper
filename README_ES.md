<p align="center">
  <a href="README.md">English</a> · <a href="README_ZH.md">简体中文</a> · <a href="README_JA.md">日本語</a> · <a href="README_KO.md">한국어</a> · Español
</p>

<p align="center">
  <img src="assets/cover.png" alt="Focus Keeper" width="100%">
</p>

# Focus Keeper

Focus Keeper es una pequeña utilidad nativa para macOS que cierra distracciones y mantiene abiertas las apps que elijas.

Ya no hace falta editar una lista blanca en AppleScript. Abre la app, escanea Applications y protege las apps que deben permanecer abiertas.

## Descargar

Descarga la última versión: [`focus-keeper.dmg`](https://github.com/ai-martin-lau/focus-keeper/releases/latest/download/focus-keeper.dmg)

## Cómo Funciona

- Escanea `/Applications`, `~/Applications` y `/System/Applications`.
- Permite proteger apps desde la lista o soltando paquetes `.app` desde Finder.
- Guarda la lista protegida localmente con `UserDefaults`.
- Cierra las ventanas de Finder antes de cerrar otras apps.
- Nunca cierra Finder como proceso.
- Envía solicitudes normales de cierre y no fuerza la terminación de procesos.

## Instalación

1. Abre el DMG.
2. Arrastra `Focus Keeper.app` a Applications.
3. Abre la app y elige las apps que quieres proteger.

Si macOS bloquea la app en el primer inicio:

1. Abre System Settings.
2. Ve a Privacy & Security.
3. Baja hasta Security y haz clic en Open Anyway para `Focus Keeper.app`.
4. Confirma Open cuando macOS lo pida.

La primera vez que la app cierre ventanas de Finder, macOS puede pedir permiso de Automatización. Permítelo para que la app pueda cerrar ventanas sin cerrar Finder.

## Compilar desde el código fuente

```sh
./scripts/build-dmg.sh
./scripts/verify-release.sh
```

El DMG se genera en `dist/focus-keeper.dmg`.
