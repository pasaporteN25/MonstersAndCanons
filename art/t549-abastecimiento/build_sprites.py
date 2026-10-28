#!/usr/bin/env python3
"""T549: reduce los rasters generados (sources/) a PNG RGBA de 128x128 para assets/sprites/map/rendered/t527/.

Sólo recorta el alfa, reduce con Lanczos y centra; no recolorea ni espeja. Uso: python3 -I build_sprites.py (desde la raíz).
"""
from pathlib import Path
from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / "assets/sprites/map/rendered/t527"
OUT.mkdir(parents=True, exist_ok=True)
# nombre final: (fuente, caja máxima en px dentro del lienzo de 128)
PIECES = {
    "ship_wreck.png": ("ship_wreck_src.png", 116),
    "forge_ruin.png": ("forge_ruin_src.png", 116),
    "ingot_pile.png": ("ingot_pile_src.png", 84),
}
for name, (src, box) in PIECES.items():
    im = Image.open(HERE / "sources" / src).convert("RGBA")
    im = im.crop(im.getchannel("A").getbbox())
    im.thumbnail((box, box), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    # apoyado en la parte baja de la casilla, como el resto de los adornos
    canvas.alpha_composite(im, ((128 - im.width) // 2, 128 - 6 - im.height if box < 100 else (128 - im.height) // 2))
    canvas.save(OUT / name, optimize=True)
    print(name, im.size)
