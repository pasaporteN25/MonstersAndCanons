"""T267: recorta y amplía las zonas con cambios entre las capturas antes/después.

Uso: python3 -I art/t267-comparacion/make_crops.py <carpeta_antes> <carpeta_despues>
Cada carpeta trae level_NN_{initial,active,depleted}.png de 1280x720 (capture.gd).
Escribe antes/, despues/ (capturas completas) y crops/ dentro de art/t267-comparacion/.
"""
import shutil
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
ANTES, DESPUES = Path(sys.argv[1]), Path(sys.argv[2])

# id, nivel, estado, (x0, y0, x1, y1) en píxeles nativos de 1280x720
CROPS = [
    ("n01_estatua", "01", "initial", (770, 362, 905, 438)),
    ("n01_flora_a", "01", "initial", (380, 172, 455, 245)),
    ("n01_flora_b", "01", "initial", (570, 555, 645, 625)),
    ("n14_zona", "14", "initial", (200, 95, 640, 195)),
    ("n14_mina_activa", "14", "active", (680, 140, 745, 195)),
    ("n14_mina_agotada", "14", "depleted", (680, 140, 745, 195)),
    ("n14_bosque_activo", "14", "active", (680, 525, 745, 580)),
    ("n14_bosque_agotado", "14", "depleted", (680, 525, 745, 580)),
    ("n14_escombro_trabajo", "14", "active", (535, 283, 600, 342)),
    ("n14_ruinas", "14", "initial", (1030, 240, 1130, 340)),
    ("n15_central", "15", "initial", (1150, 380, 1270, 480)),
    ("n15_mina_activa", "15", "active", (585, 525, 645, 580)),
    ("n15_mina_agotada", "15", "depleted", (585, 525, 645, 580)),
    ("n15_bosque_activo", "15", "active", (155, 430, 215, 482)),
    ("n15_roca_marca", "15", "initial", (100, 240, 175, 295)),
    ("n15_campamento", "15", "initial", (1100, 285, 1170, 340)),
    ("n15_abastecimiento_taller", "15", "initial", (1205, 285, 1265, 345)),
    ("n15_abastecimiento_nave", "15", "initial", (730, 570, 790, 620)),
    ("n15_abastecimiento_lingotes", "15", "initial", (1020, 570, 1080, 620)),
]

for sub in ("antes", "despues", "crops"):
    (HERE / sub).mkdir(exist_ok=True)

for src, sub in ((ANTES, "antes"), (DESPUES, "despues")):
    for png in sorted(src.glob("level_*.png")):
        if png.name.startswith("level_01_") and not png.name.endswith("_initial.png"):
            continue  # el nivel 1 no tiene mina ni bosque: los otros estados son idénticos
        shutil.copy(png, HERE / sub / png.name)

for cid, level, state, box in CROPS:
    scale = max(3, round(560 / (box[2] - box[0])))
    for src, sub in ((ANTES, "a"), (DESPUES, "d")):
        im = Image.open(src / f"level_{level}_{state}.png").convert("RGB").crop(box)
        im = im.resize((im.width * scale, im.height * scale), Image.LANCZOS)
        im.save(HERE / "crops" / f"{cid}_{sub}.png", optimize=True)
    print(cid, scale)
