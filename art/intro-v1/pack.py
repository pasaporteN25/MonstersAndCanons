"""Normaliza las láminas y prepara la revisión; requiere Pillow."""
from pathlib import Path
import hashlib
import html
import json
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
DEST = ROOT / 'assets' / 'intro'
NAMES = ['01_la_nave', '02_la_bodega', '03_los_turnos', '04_la_ventana',
         '05_el_descenso', '06_los_motores_apagados', '07_el_oasis']
TITLES = ['La nave', 'La bodega', 'Los turnos', 'La ventana', 'El descenso',
          'Los motores apagados', 'El oasis']
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 20)
small = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 15)
DEST.mkdir(parents=True, exist_ok=True)
entries = []
for name, title in zip(NAMES, TITLES):
    source = HERE / 'sources' / (name + '.png')
    with Image.open(source) as original:
        size = list(original.size)
        # Se conserva el cuadro completo: la variación de relación es menor al 0,1 %.
        image = original.convert('RGB').resize((1920, 1080), Image.Resampling.LANCZOS)
        image.save(DEST / (name + '.webp'), 'WEBP', lossless=True, quality=100, method=6, exact=True)  # D-150: sin pérdida; Godot aplica q0,90 al importar
    target = DEST / (name + '.webp')
    entries.append({'id': name[:2], 'title': title, 'source': 'sources/' + source.name,
                    'source_size': size, 'file': 'assets/intro/' + target.name,
                    'width': 1920, 'height': 1080, 'bytes': target.stat().st_size,
                    'sha256': hashlib.sha256(target.read_bytes()).hexdigest()})
manifest = {'task': 'T241', 'style': 'A · Cuaderno de bitácora',
            'generator': 'image_gen integrado', 'approval': 'Pendiente de revisión de las siete láminas por Lucas',
            'text_zone': {'y_start': 842, 'y_end': 1080},
            'total_bytes': sum(e['bytes'] for e in entries), 'images': entries}
(HERE / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')

sheet = Image.new('RGB', (1540, 1130), '#efe2c8')
draw = ImageDraw.Draw(sheet)
draw.text((20, 15), 'T241 · Siete láminas · Cuaderno de bitácora · revisión pendiente', font=font, fill='#35251b')
for i, entry in enumerate(entries):
    x, y = 20 + (i % 3) * 510, 60 + (i // 3) * 350
    with Image.open(ROOT / entry['file']) as image:
        sheet.paste(image.resize((490, 276), Image.Resampling.LANCZOS), (x, y))
    draw.text((x, y + 282), f"{i + 1} · {entry['title']}", font=font, fill='#35251b')
    draw.text((x, y + 312), f"1920 × 1080 · {entry['bytes'] / 1048576:.2f} MiB", font=small, fill='#35251b')
sheet.save(HERE / 'contact_sheet.png', optimize=True)

# Los recortes son exclusivamente de revisión; los finales no se recortan.
groups = [
    ('Nave · 1 / 5 / 7', [(0, (380, 290, 1160, 570)), (4, (330, 75, 1430, 640)), (6, (160, 380, 705, 620))]),
    ('Ingeniera · 2 / 3 / 4 / 6', [(1, (55, 120, 630, 800)), (2, (180, 105, 735, 805)), (3, (290, 85, 900, 800)), (5, (110, 140, 555, 800))]),
    ('Herrero · 2 / 4 / 7', [(1, (610, 135, 935, 650)), (3, (1220, 65, 1895, 785)), (6, (675, 540, 730, 635))])
]
continuity = Image.new('RGB', (1540, 1040), '#efe2c8')
draw = ImageDraw.Draw(continuity)
draw.text((20, 15), 'T241 · Continuidad · recortes ampliados, sin alterar los finales', font=font, fill='#35251b')
for row, (label, crops) in enumerate(groups):
    y = 60 + row * 320
    draw.text((20, y), label, font=font, fill='#35251b')
    for col, (index, box) in enumerate(crops):
        with Image.open(ROOT / entries[index]['file']) as original:
            crop = original.crop(box)
            scale = min(355 / crop.width, 265 / crop.height)
            crop = crop.resize((round(crop.width * scale), round(crop.height * scale)), Image.Resampling.LANCZOS)
            continuity.paste(crop, (20 + col * 380, y + 35))
continuity.save(HERE / 'continuity_sheet.png', optimize=True)

cards = ''
for i, entry in enumerate(entries):
    url = '../../' + entry['file']
    cards += f'''<figure><figcaption>{i + 1} · {html.escape(entry['title'])}
    <small>1920 × 1080 · {entry['bytes']:,} bytes · {entry['bytes']/1048576:.2f} MiB</small></figcaption>
    <a href="{url}"><div class="frame"><img src="{url}" alt="{html.escape(entry['title'])}">
    <div class="zone">Zona de texto: y = 842 a 1080</div></div></a></figure>'''
page = '''<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>T241 · Revisión de las siete láminas</title><style>
body{margin:0;background:#231f1a;color:#efe2c8;font:17px system-ui;line-height:1.5}main{max-width:1600px;margin:auto;padding:28px}
h1{font-size:30px}button{padding:12px;background:#e9dabd;border:0;border-radius:5px;color:#231f1a;cursor:pointer}
.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:24px}figure{margin:0}figcaption{padding:10px 0}small{display:block;color:#c8bca8}
img{display:block;width:100%;height:auto}.frame{position:relative}.zone{display:none;position:absolute;bottom:0;left:0;right:0;height:22.04%;background:#0009;border-top:1px solid #f8db9c;box-sizing:border-box;padding:12px;color:white;font-size:14px}
.show .zone{display:block}.sheets{display:grid;gap:24px;margin-top:40px}a{color:#efd3a2}@media(max-width:900px){.grid{grid-template-columns:1fr}}
</style><main><h1>T241 · Cuaderno de bitácora</h1>
<p>Siete láminas en estilo A, sin texto incorporado. Pendientes de la revisión de Lucas.
Abrí cualquier imagen para verla completa. El indicador de franja permite revisar el espacio inferior reservado al texto; no modifica los PNG.</p>
<button id="toggle" aria-pressed="false">Mostrar zona de texto</button><p>Revisar: misma nave (tres cúpulas, dos toberas), ingeniera, herrero, carta y progresión del verde.
Sin Moradores, animales, ruinas, señales ni marcas semejantes al símbolo A.</p><div class="grid">''' + cards + '''</div>
<div class="sheets"><h2>Miniaturas y continuidad</h2><a href="contact_sheet.png"><img src="contact_sheet.png" alt="Las siete láminas en miniatura"></a>
<a href="continuity_sheet.png"><img src="continuity_sheet.png" alt="Recortes comparados de nave, ingeniera y herrero"></a></div>
<p>''' + f"Peso total de los siete finales: {manifest['total_bytes']:,} bytes ({manifest['total_bytes']/1048576:.2f} MiB)." + '''
La integración, las capturas en el juego y el peso de la APK corresponden a T242.</p></main>
<script>document.getElementById('toggle').onclick=function(){const show=document.body.classList.toggle('show');this.setAttribute('aria-pressed',String(show));this.textContent=show?'Ocultar zona de texto':'Mostrar zona de texto';};</script></html>'''
(HERE / 'comparison.html').write_text(page)
print(json.dumps(manifest, ensure_ascii=False, indent=2))
