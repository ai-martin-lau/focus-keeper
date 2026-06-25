#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
DESKTOP = Path.home() / "Desktop"

FONT = "/System/Library/Fonts/SFNS.ttf"
MONO = "/System/Library/Fonts/SFNSMono.ttf"


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT, size=size)


def mono(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(MONO, size=size)


def draw_text(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, fill: str, size: int) -> None:
    draw.text(xy, text, font=font(size), fill=fill)


def draw_app_row(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    w: int,
    name: str,
    detail: str,
    color: str,
    selected: bool = False,
) -> None:
    bg = "#eef5ff" if selected else "#ffffff"
    outline = "#cfe2ff" if selected else "#e6e8eb"
    draw.rounded_rectangle((x, y, x + w, y + 82), radius=18, fill=bg, outline=outline, width=2)
    draw.rounded_rectangle((x + 24, y + 18, x + 70, y + 64), radius=12, fill=color)
    draw_text(draw, (x + 92, y + 15), name, "#101318", 26)
    draw.text((x + 92, y + 48), detail, font=mono(16), fill="#737982")
    if selected:
        cx, cy = x + w - 42, y + 41
        draw.ellipse((cx - 14, cy - 14, cx + 14, cy + 14), fill="#1473e6")
        draw.line((cx - 7, cy, cx - 2, cy + 6, cx + 8, cy - 8), fill="#ffffff", width=4)


def render(path: Path, width: int, height: int) -> None:
    scale = width / 2560
    im = Image.new("RGB", (width, height), "#f6f7f8")
    draw = ImageDraw.Draw(im)

    def s(value: int) -> int:
        return int(value * scale)

    # Background bands
    draw.rectangle((0, 0, width, height), fill="#f6f7f8")
    draw.rounded_rectangle((s(120), s(120), width - s(120), height - s(120)), radius=s(42), fill="#ffffff")
    draw.rectangle((s(120), height - s(250), width - s(120), height - s(120)), fill="#f1f4f7")

    # Product text
    draw_text(draw, (s(190), s(210)), "Quit Other Apps", "#101318", s(96))
    draw_text(draw, (s(198), s(330)), "Protect what stays open. Close the rest.", "#4d535c", s(42))

    badge_x, badge_y = s(196), s(424)
    draw.rounded_rectangle((badge_x, badge_y, badge_x + s(382), badge_y + s(62)), radius=s(18), fill="#101318")
    draw.text((badge_x + s(26), badge_y + s(16)), "macOS utility", font=mono(s(24)), fill="#ffffff")

    badge2_x = badge_x + s(410)
    draw.rounded_rectangle((badge2_x, badge_y, badge2_x + s(430), badge_y + s(62)), radius=s(18), fill="#f0f4f8")
    draw.text((badge2_x + s(26), badge_y + s(16)), "No code whitelist", font=mono(s(24)), fill="#101318")

    # Mock macOS window
    x0, y0 = s(1140), s(210)
    ww, wh = s(1060), s(720)
    draw.rounded_rectangle((x0, y0, x0 + ww, y0 + wh), radius=s(36), fill="#ffffff", outline="#d9dde3", width=s(2))
    draw.rounded_rectangle((x0, y0, x0 + ww, y0 + s(94)), radius=s(36), fill="#f0f2f5")
    draw.rectangle((x0, y0 + s(50), x0 + ww, y0 + s(94)), fill="#f0f2f5")

    for i, c in enumerate(["#ff5f57", "#ffbd2e", "#28c840"]):
        cx = x0 + s(38 + i * 36)
        cy = y0 + s(47)
        draw.ellipse((cx - s(10), cy - s(10), cx + s(10), cy + s(10)), fill=c)

    draw.text((x0 + s(156), y0 + s(30)), "Applications", font=font(s(28)), fill="#101318")
    draw.text((x0 + s(614), y0 + s(30)), "Protected apps", font=font(s(28)), fill="#101318")
    draw.line((x0 + s(530), y0 + s(94), x0 + s(530), y0 + wh), fill="#e1e4e8", width=s(2))

    row_w = s(418)
    draw_app_row(draw, x0 + s(58), y0 + s(140), row_w, "Safari", "com.apple.Safari", "#30b0c7")
    draw_app_row(draw, x0 + s(58), y0 + s(242), row_w, "Terminal", "com.apple.Terminal", "#3a3f45", selected=True)
    draw_app_row(draw, x0 + s(58), y0 + s(344), row_w, "Music", "com.apple.Music", "#fa233b")
    draw_app_row(draw, x0 + s(58), y0 + s(446), row_w, "Notes", "com.apple.Notes", "#ffd60a")

    protected_x = x0 + s(586)
    draw.rounded_rectangle((protected_x, y0 + s(140), protected_x + s(408), y0 + s(210)), radius=s(18), fill="#fff7ed", outline="#ffd7a8", width=s(2))
    draw_text(draw, (protected_x + s(24), y0 + s(157)), "Finder", "#101318", s(26))
    draw.text((protected_x + s(24), y0 + s(188)), "windows close, app keeps running", font=mono(s(15)), fill="#8a5a18")

    draw.rounded_rectangle((protected_x, y0 + s(232), protected_x + s(408), y0 + s(302)), radius=s(18), fill="#eef5ff", outline="#cfe2ff", width=s(2))
    draw_text(draw, (protected_x + s(24), y0 + s(249)), "Terminal", "#101318", s(26))
    draw.text((protected_x + s(24), y0 + s(280)), "protected by the user", font=mono(s(15)), fill="#315f9a")

    draw.rounded_rectangle((protected_x, y0 + s(340), protected_x + s(408), y0 + s(430)), radius=s(18), fill="#f8fafc", outline="#cfd6df", width=s(2))
    draw.text((protected_x + s(92), y0 + s(371)), "Drop apps to protect", font=font(s(28)), fill="#59616b")
    draw.rounded_rectangle((protected_x + s(30), y0 + s(365), protected_x + s(68), y0 + s(403)), radius=s(10), fill="#1473e6")

    draw.rounded_rectangle((protected_x, y0 + s(548), protected_x + s(408), y0 + s(620)), radius=s(20), fill="#ffebe9")
    draw.text((protected_x + s(76), y0 + s(566)), "Quit apps", font=font(s(30)), fill="#a21c14")
    draw.ellipse((protected_x + s(28), y0 + s(560), protected_x + s(62), y0 + s(594)), fill="#d92d20")

    # Footer proof points
    foot_y = height - s(205)
    points = [
        ("Finder-safe", "closes windows, never quits Finder"),
        ("Drag-and-drop", "protect apps without editing code"),
        ("Normal quit", "no force kill, no background service"),
    ]
    for i, (title, detail) in enumerate(points):
        px = s(190 + i * 690)
        draw.text((px, foot_y), title, font=font(s(34)), fill="#101318")
        draw.text((px, foot_y + s(48)), detail, font=font(s(24)), fill="#59616b")

    im.save(path, "PNG", optimize=True, compress_level=9)


def main() -> None:
    ASSETS.mkdir(parents=True, exist_ok=True)
    render(ASSETS / "cover.png", 2560, 1280)
    render(ASSETS / "social-preview.png", 1280, 640)
    desktop_target = DESKTOP / "quit-other-apps-social-preview.png"
    render(desktop_target, 1280, 640)
    print(ASSETS / "cover.png")
    print(ASSETS / "social-preview.png")
    print(desktop_target)


if __name__ == "__main__":
    main()
