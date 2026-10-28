#!/usr/bin/env python3
"""T549: hoja de contacto (220 px y 34 px) de las tres piezas y recortes ampliados antes/después del nivel 15."""
from pathlib import Path
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
R = Image.Resampling.LANCZOS
names = [("ship_wreck", "supply_cart"), ("forge_ruin", "supply_depot"), ("ingot_pile", "supply_line_pole")]
ground = Image.open(ROOT / "assets/tiles/rendered/ground_pradera.png").convert("RGBA")
sheet = Image.new("RGBA", (3 * 250 + 20, 220 + 34 + 90), (30, 34, 38, 255))
d = ImageDraw.Draw(sheet)
for i, (n, key) in enumerate(names):
    im = Image.open(ROOT / f"assets/sprites/map/rendered/t527/{n}.png").convert("RGBA")
    x = 10 + i * 250
    tile = ground.resize((220, 220), R)
    tile.alpha_composite(im.resize((220, 220), R))
    sheet.alpha_composite(tile, (x, 10))
    t34 = ground.resize((34, 34), R)
    t34.alpha_composite(im.resize((34, 34), R))
    sheet.alpha_composite(t34, (x, 240))
    d.text((x, 285), f"{n} ({key})", fill=(230, 220, 200, 255))
sheet.convert("RGB").save(HERE / "contact_220_34.png")
for label in ["antes", "despues"]:
    shot = Image.open(HERE / f"level_15_{label}_1280x720.png").convert("RGB")
    # esquina inferior derecha del mapa: taller, nave y lingotes (casillas 25,5; 15,11; 21,11)
    parts = [shot.crop((1100, 280, 1280, 340)).resize((540, 180), R), shot.crop((690, 580, 1100, 620)).resize((1230, 120), R)]
    out = Image.new("RGB", (1230, 300), (20, 20, 20))
    out.paste(parts[0], (0, 0))
    out.paste(parts[1], (0, 180))
    out.save(HERE / f"zoom_{label}.png")
