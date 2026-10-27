#!/usr/bin/env python3
"""Prepara las rocas aprobadas y la H G2 para los recursos de juego de T508.

Fecha: 2026-10-27. Producción: Codex gpt-6.1-sol, esfuerzo medio.
Herramientas: Python 3 y Pillow. Arte derivado únicamente de T504/T505 aprobados.
"""
from __future__ import annotations

import hashlib
import json
import random
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[4]
SAMPLES = ROOT / "art/m80-muestras/rocas"
GLYPH_SOURCE = ROOT / "art/m80-muestras/glifo-h/sources/glyphs.py"
OUT = ROOT / "assets/sprites/map/rendered"
SCALE = 3
SIZE = 128 * SCALE
LANCZOS = Image.Resampling.LANCZOS


def load_glyphs():
    namespace: dict[str, object] = {}
    exec(compile(GLYPH_SOURCE.read_text(encoding="utf-8"), str(GLYPH_SOURCE), "exec"), namespace)
    return namespace["GLYPHS"]["g2"]


def mark_layer(quad: list[tuple[float, float]], seed: int = 50826) -> Image.Image:
    """Tallado G2 transparente, con bisel de piedra, en el plano de una cara."""
    mask = Image.new("L", (SIZE, SIZE))
    draw = ImageDraw.Draw(mask)
    glyph = load_glyphs()

    def mapped(x: float, y: float) -> tuple[float, float]:
        u, v = x / 60.0, y / 64.0
        a, b, c, d = quad
        return (
            (a[0] * (1 - u) * (1 - v) + b[0] * u * (1 - v) + c[0] * u * v + d[0] * (1 - u) * v) * SCALE,
            (a[1] * (1 - u) * (1 - v) + b[1] * u * (1 - v) + c[1] * u * v + d[1] * (1 - u) * v) * SCALE,
        )

    for polygon in glyph:
        draw.polygon([mapped(float(x), float(y)) for x, y in polygon], fill=255)

    rng = random.Random(seed)
    wear = Image.new("L", (SIZE, SIZE), 255)
    wear_draw = ImageDraw.Draw(wear)
    bounds = mask.getbbox()
    assert bounds is not None
    for _ in range(42):
        x = rng.randrange(bounds[0], bounds[2])
        y = rng.randrange(bounds[1], bounds[3])
        if mask.getpixel((x, y)):
            radius = rng.uniform(0.12, 0.38) * SCALE
            wear_draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=rng.choice((0, 70, 135)))
    mask = ImageChops.multiply(mask, wear)

    layer = Image.new("RGBA", (SIZE, SIZE))
    offset = Image.new("L", mask.size)
    offset.paste(mask, (round(0.75 * SCALE), round(0.95 * SCALE)))
    lip = ImageChops.subtract(offset, mask)
    layer.paste((198, 188, 159, 210), (0, 0), lip)
    layer.paste((39, 39, 34, 235), (0, 0), mask)
    inner_offset = Image.new("L", mask.size)
    inner_offset.paste(mask, (round(1.1 * SCALE), round(1.25 * SCALE)))
    inner = ImageChops.multiply(mask, inner_offset)
    layer.paste((72, 68, 52, 210), (0, 0), inner)
    return layer.resize((128, 128), LANCZOS)


def save_rock_variants() -> dict[str, str]:
    hashes: dict[str, str] = {}
    for model in "abc":
        for color in ("caliza", "arenisca", "oscura"):
            source = SAMPLES / f"roca_{model}_{color}.png"
            target = OUT / f"signal_rock_{model}_{color}.png"
            target.write_bytes(source.read_bytes())
            hashes[target.name] = hashlib.sha256(target.read_bytes()).hexdigest()
    return hashes


def save_engraving_overlay() -> str:
    # El signo ocupa la cara central: cabe en los tres modelos aprobados y no invade la silueta.
    layer = mark_layer([(37, 60), (79, 60), (79, 94), (37, 94)])
    target = OUT / "mark_engraved_g2.png"
    layer.save(target, optimize=True)
    return hashlib.sha256(target.read_bytes()).hexdigest()


def update_rubble() -> str:
    source = SAMPLES / "sources/rubble_idle_original.png"
    image = Image.open(source).convert("RGBA")
    # Tallado chico sobre la cara frontal del bloque inferior izquierdo.
    layer = mark_layer([(18, 67), (44, 68), (44, 91), (18, 90)], seed=50827)
    image.alpha_composite(layer)
    target = OUT / "rubble_idle.png"
    image.save(target, optimize=True)
    return hashlib.sha256(target.read_bytes()).hexdigest()


def main() -> None:
    hashes = save_rock_variants()
    hashes["mark_engraved_g2.png"] = save_engraving_overlay()
    hashes["rubble_idle.png"] = update_rubble()
    manifest = {
        "tarea": "T508",
        "fecha": "2026-10-27",
        "productor": "Codex gpt-6.1-sol, esfuerzo medio",
        "herramienta": "Python 3 y Pillow",
        "procedencia": "Rocas T504 y glifo G2 T505 elegidos por Lucas en T506; no se usó material externo.",
        "prompt": "Conservar los nueve modelos/color aprobados; derivar un tallado G2 de la muestra elegida para overlay 128x128 y sobre el escombro activo.",
        "sha256": hashes,
    }
    (SAMPLES / "sources/runtime_assets_manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
