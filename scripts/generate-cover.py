#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import shutil

from PIL import Image, ImageDraw, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
DESKTOP = Path.home() / "Desktop"
SOURCE = ASSETS / "source" / "social-preview-option-04-base.png"

FONT = "/System/Library/Fonts/SFNS.ttf"
MONO = "/System/Library/Fonts/SFNSMono.ttf"


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT, size=size)


def mono(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(MONO, size=size)


def fit_base(width: int, height: int) -> Image.Image:
    source = Image.open(SOURCE).convert("RGB")
    return ImageOps.fit(source, (width, height), method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))


def left_luma(image: Image.Image) -> float:
    r, g, b = image.crop((0, 0, int(image.width * 0.45), image.height)).resize((1, 1)).getpixel((0, 0))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def text_shadow(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, typeface: ImageFont.FreeTypeFont, fill: str, shadow: str) -> None:
    x, y = xy
    for dx, dy in ((0, 3), (1, 3), (-1, 3)):
        draw.text((x + dx, y + dy), text, font=typeface, fill=shadow)
    draw.text((x, y), text, font=typeface, fill=fill)


def render(width: int, height: int) -> Image.Image:
    image = fit_base(width, height).convert("RGBA")
    scale = width / 1280
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)

    dark_text = left_luma(image.convert("RGB")) > 132
    gradient_width = int(width * 0.58)

    if dark_text:
        for x in range(gradient_width):
            alpha = int(230 * max(0, 1 - x / gradient_width))
            od.line((x, 0, x, height), fill=(255, 255, 255, alpha))
        title_fill = "#0c1118"
        body_fill = "#2f3845"
        chip_fill = "#0c1118"
        chip_text = "#ffffff"
        shadow = "#ffffff"
    else:
        for x in range(gradient_width):
            alpha = int(185 * max(0, 1 - x / gradient_width))
            od.line((x, 0, x, height), fill=(0, 0, 0, alpha))
        title_fill = "#ffffff"
        body_fill = "#e8eef6"
        chip_fill = "#ffffff"
        chip_text = "#0c1118"
        shadow = "#101820"

    image = Image.alpha_composite(image, overlay)
    draw = ImageDraw.Draw(image)

    left = int(72 * scale)
    top = int(90 * scale)
    chip_h = int(42 * scale)
    chip_w = int(184 * scale)
    draw.rounded_rectangle((left, top, left + chip_w, top + chip_h), radius=int(12 * scale), fill=chip_fill)
    draw.text((left + int(22 * scale), top + int(12 * scale)), "macOS utility", font=mono(int(18 * scale)), fill=chip_text)

    text_shadow(draw, (left, int(166 * scale)), "Quit Other Apps", font(int(70 * scale)), title_fill, shadow)
    text_shadow(draw, (left + int(4 * scale), int(258 * scale)), "Protect what stays open.", font(int(32 * scale)), body_fill, shadow)
    text_shadow(draw, (left + int(4 * scale), int(304 * scale)), "Close the rest.", font(int(32 * scale)), body_fill, shadow)

    proof_y = height - int(92 * scale)
    proofs = ["Finder-safe", "Drag-and-drop", "Normal quit"]
    x = left
    for proof in proofs:
        w = int((draw.textlength(proof, font=font(int(20 * scale))) + 34 * scale))
        draw.rounded_rectangle((x, proof_y, x + w, proof_y + int(38 * scale)), radius=int(12 * scale), fill=(255, 255, 255, 215) if dark_text else (12, 17, 24, 205))
        draw.text((x + int(17 * scale), proof_y + int(9 * scale)), proof, font=font(int(20 * scale)), fill="#1b2430" if dark_text else "#ffffff")
        x += w + int(14 * scale)

    return image.convert("RGB")


def save_under_1mb_jpeg(image: Image.Image, path: Path) -> None:
    quality = 96
    while True:
        image.save(path, "JPEG", quality=quality, optimize=True, progressive=True)
        if path.stat().st_size < 1024 * 1024 or quality <= 82:
            return
        quality -= 3


def main() -> None:
    ASSETS.mkdir(parents=True, exist_ok=True)

    cover = render(2560, 1280)
    cover.save(ASSETS / "cover.png", "PNG", optimize=True, compress_level=9)

    social = render(1280, 640)
    social.save(ASSETS / "social-preview.png", "PNG", optimize=True, compress_level=9)
    save_under_1mb_jpeg(social, ASSETS / "social-preview.jpg")

    desktop_target = DESKTOP / "quit-other-apps-social-preview.jpg"
    shutil.copy2(ASSETS / "social-preview.jpg", desktop_target)

    print(ASSETS / "cover.png")
    print(ASSETS / "social-preview.png")
    print(ASSETS / "social-preview.jpg")
    print(desktop_target)


if __name__ == "__main__":
    main()
