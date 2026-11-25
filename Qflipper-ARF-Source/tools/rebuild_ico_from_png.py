"""
Rebuild application/assets/icons/qFlipper.ico and qFlipper.png.

- Optional master: qFlipper_source.png (if present, used as input instead of qFlipper.png).
- Enforces neutral grayscale ARF icon styling (no red tint).
- ICO: PNG-encoded multi-resolution (needs a 256x256 master for Pillow to embed all sizes).

Requires Pillow. Run: python tools/rebuild_ico_from_png.py
"""
from __future__ import annotations

import os
import sys

from PIL import Image, ImageEnhance, ImageFilter, ImageOps


def _lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def _smoothstep(edge0: float, edge1: float, x: float) -> float:
    if edge1 <= edge0:
        return 1.0 if x >= edge0 else 0.0
    t = max(0.0, min(1.0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3.0 - 2.0 * t)


def to_grayscale_preserve_alpha(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA")
    alpha = img.getchannel("A")
    gray = ImageOps.grayscale(img.convert("RGB"))
    gray = ImageEnhance.Contrast(gray).enhance(1.18)
    return Image.merge("RGBA", (gray, gray, gray, alpha))


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
    out = to_grayscale_preserve_alpha(src_rgba)
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
