"""Compone vistas de revisión desde capturas reales y coordenadas del juego."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
CAPTURES = HERE / "captures"
OUT = HERE / "review"
OUT.mkdir(exist_ok=True)
METADATA = json.loads((HERE / "map_metadata.json").read_text())
FONT = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
SMALL = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
BACKGROUND = "#191d22"
FOREGROUND = "#eee8da"


def label(image: Image.Image, x: int, y: int, text: str, font: ImageFont.FreeTypeFont = FONT) -> None:
    ImageDraw.Draw(image).text((x, y), text, fill=FOREGROUND, font=font)


def capture(level: int, phase: str) -> Image.Image:
    return Image.open(CAPTURES / f"level_{level:02d}_{phase}.png").convert("RGB")


# Mapas completos para valorar las pruebas en el estado actual de los temas y assets.
levels = [1, 13, 15]
overview = Image.new("RGB", (1280, len(levels) * 395), BACKGROUND)
for row, level in enumerate(levels):
    y = row * 395
    label(overview, 12, y + 5, f"Nivel {level} · actual integrado (izq.) / muestras T267 (der.)")
    overview.paste(capture(level, "current").resize((640, 360), Image.Resampling.LANCZOS), (0, y + 30))
    overview.paste(capture(level, "proposal").resize((640, 360), Image.Resampling.LANCZOS), (640, y + 30))
overview.save(OUT / "contexto-niveles-1-13-15.png")

# Escombro queda fuera de la selección: la muestra histórica conserva la A anterior a M80.
items = [
    ("Mina · nivel 11", 11, "mina", False),
    ("Bosque explotable · N13", 13, "bosque_explotable", False),
    ("Central 2×2 · nivel 15", 15, "central_1", True),
    ("Estatua · nivel 1", 1, "estatua", False),
]
row_height = 212
board = Image.new("RGB", (1000, row_height * len(items)), BACKGROUND)
for row, (name, level, drawing, is_central) in enumerate(items):
    y = row * row_height
    label(board, 12, y + 4, f"{row + 1}. {name}")
    label(board, 260, y + 4, "Actual en main · b775feb", SMALL)
    label(board, 630, y + 4, "Prueba T267 · sin integrar", SMALL)
    meta = METADATA[str(level)]
    cell = next(entry for entry in meta["legend"] if entry["drawing"] == drawing)
    tile = meta["tile_screen_px"]
    footprint = tile * 2 if is_central else tile
    x, top = cell["screen_origin"]
    center_x, center_y = x + footprint / 2, top + footprint / 2
    left = max(0, min(1280 - 260, round(center_x - 130)))
    upper = max(48, min(624 - 160, round(center_y - 80)))
    box = (left, upper, left + 260, upper + 160)
    for column, phase in enumerate(["current", "proposal"]):
        board.paste(capture(level, phase).crop(box), (250 + column * 370, y + 28))
board.save(OUT / "comparaciones-por-pieza.png")

# Capturas completas a píxeles originales para abrir/descargar por separado.
for level in [1, 3, 5, 11, 13, 15]:
    for phase in ["current", "proposal"]:
        capture(level, phase).save(OUT / f"nivel-{level:02d}-{phase}.png")
print("Comparaciones T267 actualizadas desde capturas de main b775feb.")
