"""
Generate BMP side images for Inno Setup (ARF dark-red theme).
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
    return (min(255, r + bump), min(255, gr + bump // 2), min(255, b + bump // 2))


def make_large(path: str, w: int = 164, h: int = 314) -> None:
    img = Image.new("RGB", (w, h))
    pix = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        # Dark red / near-black (sidebar reads as “dark theme” next to Windows)
        base = (int(8 + t * 22), int(3 + t * 10), int(3 + t * 10))
        for x in range(w):
            pix[x, y] = _grid_tint(x, y, base)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w - 1, h - 1], outline=(160, 45, 45), width=2)
    d.line([8, 96, w - 8, 96], fill=(90, 30, 30), width=1)
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
    d.text((10, 108), "ARF", fill=(255, 95, 95), font=font_title)
    d.text((10, 138), "Firmware", fill=(255, 228, 228), font=font_sub)
    d.text((10, 248), "qFlipper", fill=(230, 170, 170), font=font_sub)
    img.save(path, "BMP")


def make_small(path: str, w: int = 55, h: int = 58) -> None:
    img = Image.new("RGB", (w, h))
    pix = img.load()
    for y in range(h):
        for x in range(w):
            pix[x, y] = _grid_tint(x, y, (22, 8, 8))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w - 1, h - 1], outline=(200, 60, 60), width=1)
    try:
        f = ImageFont.truetype(os.path.join(os.environ.get("WINDIR", "C:\\Windows"), "Fonts", "segoeuib.ttf"), 14)
    except OSError:
        f = ImageFont.load_default()
    d.text((4, 18), "ARF", fill=(255, 80, 80), font=f)
    img.save(path, "BMP")


def main() -> int:
    here = os.path.dirname(os.path.abspath(__file__))
    large = os.path.join(here, "arf_wizard_large.bmp")
    small = os.path.join(here, "arf_wizard_small.bmp")
    make_large(large)
    make_small(small)
    print("Wrote:", large)
    print("Wrote:", small)
    return 0


if __name__ == "__main__":
    sys.exit(main())
