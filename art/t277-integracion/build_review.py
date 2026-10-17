"""Revisa derivados aprobados y arma vistas de las capturas reales de T277."""
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
LEVELS = [1, 3, 5, 11, 12, 13, 14, 15]
STATES = ["initial", "active", "depleted", "cleared"]
metadata = json.loads((ROOT / "map_metadata.json").read_text())
assets = []
for source in sorted((REPO / "art/t267b/sprites").glob("*.png")):
    if source.name == "central_master.png":
        continue
    target = REPO / "assets/sprites/map/rendered" / source.name
    assert source.read_bytes() == target.read_bytes(), target
    assert 'mipmaps/generate=true' in target.with_suffix('.png.import').read_text()
    assets.append({"file": str(target.relative_to(REPO)), "sha256": hashlib.sha256(target.read_bytes()).hexdigest()})
master = Image.open(REPO / "art/t267b/sprites/central_master.png").convert("RGBA")
central = Image.new("RGBA", (256, 256))
for i in range(4):
    central.paste(Image.open(REPO / f"assets/sprites/map/rendered/central_{i+1}.png"), (i % 2 * 128, i // 2 * 128))
assert central.tobytes() == master.tobytes()
overview = Image.new("RGB", (1280, 1560), (28, 29, 32))
draw = ImageDraw.Draw(overview)
rows = []
for index, level in enumerate(LEVELS):
    images = {state: Image.open(ROOT / f"level_{level:02d}_{state}.png").convert("RGB") for state in STATES}
    assert all(im.size == (1280, 720) for im in images.values())
    x, y = index % 2 * 640, index // 2 * 390
    overview.paste(images['initial'].resize((640, 360)), (x, y+26))
    draw.text((x+8, y+6), f"Nivel {level} - inicial (reducido al 50%)", fill="white")
    info = metadata[str(level)]
    tile = info['tile_screen_px']
    chosen = {}
    for entry in info['legend']:
        name = entry['drawing']
        if name not in ['mina', 'bosque_explotable', 'escombro', 'estatua', 'central_1'] or name in chosen:
            continue
        chosen[name] = entry
    for name, entry in chosen.items():
        x, y = entry['screen_origin']
        span = tile * (2 if name == 'central_1' else 1)
        box = (round(x), round(y), round(x+span), round(y+span))
        crops = [images[state].crop(box) for state in STATES]
        if name in ['mina', 'bosque_explotable']:
            assert crops[0].tobytes() != crops[1].tobytes() != crops[2].tobytes()
        if name == 'escombro':
            assert crops[0].tobytes() != crops[1].tobytes()
            assert crops[1].tobytes() != crops[3].tobytes()
        rows.append((level, name, crops))
overview.save(ROOT / 'overview.png')
contact = Image.new('RGB', (760, len(rows)*116+32), (28, 29, 32))
draw = ImageDraw.Draw(contact)
for i, state in enumerate(STATES):
    draw.text((190+i*138, 8), state, fill='white')
for row, (level, name, crops) in enumerate(rows):
    y = row*116+32
    draw.text((6, y+8), f"Nivel {level}: {name}", fill='white')
    for i, crop in enumerate(crops):
        # Recortes a tamaño nativo, sin agrandar las casillas.
        contact.paste(crop, (190+i*138, y))
contact.save(ROOT / 'states_native.png')
(ROOT / 'validation/art_check.json').write_text(json.dumps({"assets_identical_to_approved": assets, "central_reconstructs_master": True, "captures": 32, "resolution": [1280,720], "state_checks": "passed"}, indent=2)+"\n")
print('18 derivados idénticos, Central continua, 32 capturas 1280x720 y estados distintos: OK')
