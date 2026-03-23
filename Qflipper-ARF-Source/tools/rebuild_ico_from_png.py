"""
Rebuild application/assets/icons/qFlipper.ico and qFlipper.png.

- Optional master: qFlipper_source.png (if present, used as input instead of qFlipper.png) so you can keep a clean source in git.
- Smooth ARF recolor, soft vertical gradient, light color/contrast boost.
- ICO: PNG-encoded multi-resolution (needs a 256×256 master for Pillow to embed all sizes).

Requires Pillow. Run: python tools/rebuild_ico_from_png.py
"""
from __future__ import annotations

import os
import sys

from PIL import Image, ImageEnhance, ImageFilter


def _lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def _smoothstep(edge0: float, edge1: float, x: float) -> float:
    if edge1 <= edge0:
        return 1.0 if x >= edge0 else 0.0
    t = max(0.0, min(1.0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3.0 - 2.0 * t)


def derpurple_smooth(img: Image.Image) -> Image.Image:
    """Blend blue/lavender UI tones toward ARF red."""
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    ar = (210, 52, 48)
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 6:
                continue
            cold = max(0.0, (b - max(r, g)) / 85.0)
            lav = max(0.0, min(1.0, (r + g + b) / 750.0)) * max(0.0, (b - 130) / 90.0)
            s = _smoothstep(0.0, 1.0, min(1.0, cold * 1.15 + lav * 1.1))
            if s <= 0.001:
                continue
            lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            lum = max(0.15, min(1.0, lum))
            tr = int(_lerp(r, ar[0] * lum, s))
            tg = int(_lerp(g, ar[1] * lum * 0.95, s))
            tb = int(_lerp(b, ar[2] * lum * 0.85, s))
            px[x, y] = (max(0, min(255, tr)), max(0, min(255, tg)), max(0, min(255, tb)), a)
    return img


def gradient_background_rgba(
    size: tuple[int, int],
    top: tuple[int, int, int] = (14, 5, 6),
    bottom: tuple[int, int, int] = (52, 16, 18),
) -> Image.Image:
    w, h = size
    base = Image.new("RGBA", (w, h))
    px = base.load()
    for y in range(h):
        t = y / max(1, h - 1)
        r = int(_lerp(top[0], bottom[0], t))
        g = int(_lerp(top[1], bottom[1], t))
        b = int(_lerp(top[2], bottom[2], t))
        for x in range(w):
            px[x, y] = (r, g, b, 255)
    return base


def composite_on_bg(img_rgba: Image.Image, bg_rgba: Image.Image) -> Image.Image:
    return Image.alpha_composite(bg_rgba.convert("RGBA"), img_rgba.convert("RGBA"))


def build_master(src_rgba: Image.Image) -> Image.Image:
    img = derpurple_smooth(src_rgba)
    bg = gradient_background_rgba(img.size)
    out = composite_on_bg(img, bg)
    out = ImageEnhance.Color(out).enhance(1.06)
    out = ImageEnhance.Contrast(out).enhance(1.04)
    return out.convert("RGBA")


def save_ico(master: Image.Image, ico_path: str) -> None:
    """
    Pillow only embeds up to max(source) sizes; upscale to 256 so 256×256 is included.
    Multi-size ICO uses one image + sizes= (append_images does not work for this).
    """
    ico_base = master.resize((256, 256), Image.Resampling.LANCZOS)
    ico_base = ImageEnhance.Sharpness(ico_base).enhance(1.07)
    ico_base = ico_base.filter(ImageFilter.UnsharpMask(radius=0.6, percent=110, threshold=2))
    sizes = [
        (16, 16),
        (24, 24),
        (32, 32),
        (48, 48),
        (64, 64),
        (128, 128),
        (256, 256),
    ]
    ico_base.save(
        ico_path,
        format="ICO",
        sizes=sizes,
        bitmap_format="png",
    )


def main() -> int:
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    icons = os.path.join(root, "application", "assets", "icons")
    png_path = os.path.join(icons, "qFlipper.png")
    source_path = os.path.join(icons, "qFlipper_source.png")
    ico_path = os.path.join(icons, "qFlipper.ico")

    if not os.path.isfile(png_path):
        print("Missing:", png_path)
        return 1

    src_path = source_path if os.path.isfile(source_path) else png_path
    if src_path == source_path:
        print("Using master:", source_path)
    src = Image.open(src_path).convert("RGBA")
    master = build_master(src)
    master.save(png_path, "PNG", optimize=True)
    print("Updated", png_path)

    save_ico(master, ico_path)
    print("Wrote", ico_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
