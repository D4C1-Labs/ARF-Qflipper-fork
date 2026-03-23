"""
Generate BMP side images for Inno Setup (OmniCore dark theme).
Requires Pillow: pip install pillow
"""
from __future__ import annotations

import os
import sys

from PIL import Image, ImageDraw, ImageFont


def _grid_tint(x: int, y: int, base: tuple[int, int, int]) -> tuple[int, int, int]:
    g = ((x // 10) + (y // 10)) % 2
    bump = 10 if g else 0
    r, gr, b = base
    v = min(255, int((r + gr + b) / 3) + bump)
    return (v, v, v)


def make_large(path: str, w: int = 164, h: int = 314) -> None:
    img = Image.new("RGB", (w, h))
    pix = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        # Neutral dark gray / near-black for a modern OmniCore look.
        v = int(20 + t * 28)
        base = (v, v, v)
        for x in range(w):
            pix[x, y] = _grid_tint(x, y, base)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w - 1, h - 1], outline=(120, 120, 120), width=2)
    d.line([8, 96, w - 8, 96], fill=(78, 78, 78), width=1)
    font_title = None
    font_sub = None
    for name, size in (("segoeuib.ttf", 22), ("arialbd.ttf", 20), ("arial.ttf", 18)):
        try:
            font_title = ImageFont.truetype(os.path.join(os.environ.get("WINDIR", "C:\\Windows"), "Fonts", name), size)
            break
        except OSError:
            continue
    for name, size in (("segoeui.ttf", 12), ("arial.ttf", 11)):
        try:
            font_sub = ImageFont.truetype(os.path.join(os.environ.get("WINDIR", "C:\\Windows"), "Fonts", name), size)
            break
        except OSError:
            continue
    if font_title is None:
        font_title = ImageFont.load_default()
    if font_sub is None:
        font_sub = ImageFont.load_default()
    d.text((10, 108), "OmniCore", fill=(232, 232, 232), font=font_title)
    d.text((10, 138), "Firmware", fill=(210, 210, 210), font=font_sub)
    d.text((10, 248), "Installer", fill=(170, 170, 170), font=font_sub)
    img.save(path, "BMP")


def make_small(path: str, w: int = 55, h: int = 58) -> None:
    img = Image.new("RGB", (w, h))
    pix = img.load()
    for y in range(h):
        for x in range(w):
            pix[x, y] = _grid_tint(x, y, (20, 20, 20))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w - 1, h - 1], outline=(150, 150, 150), width=1)
    try:
        f = ImageFont.truetype(os.path.join(os.environ.get("WINDIR", "C:\\Windows"), "Fonts", "segoeuib.ttf"), 14)
    except OSError:
        f = ImageFont.load_default()
    d.text((4, 18), "OCF", fill=(235, 235, 235), font=f)
    img.save(path, "BMP")


def main() -> int:
    here = os.path.dirname(os.path.abspath(__file__))
    large = os.path.join(here, "omnicore_wizard_large.bmp")
    small = os.path.join(here, "omnicore_wizard_small.bmp")
    make_large(large)
    make_small(small)
    print("Wrote:", large)
    print("Wrote:", small)
    return 0


if __name__ == "__main__":
    sys.exit(main())
