"""Compara capturas nativas; arma un visor local sin integrar recursos."""
from pathlib import Path
import json
from PIL import Image, ImageChops, ImageDraw, ImageFont
HERE=Path(__file__).resolve().parent
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
metadata=json.loads((HERE/'capture_metadata.json').read_text())
checks=[]
for sample in metadata:
    second=sample['second']
    prefix=f'level_07_wave_08_{second:02d}s'
    before=Image.open(HERE/'captures'/f'{prefix}_before.png').convert('RGB')
    after=Image.open(HERE/'captures'/f'{prefix}_after.png').convert('RGB')
    assert before.size==after.size==(1280,720)
    diff=ImageChops.difference(before,after)
    assert diff.getbbox()
    mask=Image.new('L',before.size); d=ImageDraw.Draw(mask)
    for actor in sample['actors']:
        x,y=actor['origin']
        # Incluye sprite y barra de salud que sigue las cotas del nuevo alfa.
        d.rectangle((int(x)-46,int(y)-65,int(x)+46,int(y)+34),fill=255)
    diff.paste((0,0,0),(0,0),mask)
    outside=diff.getbbox()
    checks.append({'second':second,'size':before.size,'changed_outside_actor_regions':outside})
    assert outside is None,(second,outside)
    # Recortes a 1:1, sin ampliar enemigos.
    cargador=next(a for a in sample['actors'] if a['id']=='cargador')
    x,y=cargador['origin'];left=max(0,min(960,round(x)-100));top=max(48,round(y)-72)
    crop=(left,top,left+320,top+150)
    sheet=Image.new('RGB',(640,178),'#22262b'); draw=ImageDraw.Draw(sheet)
    sheet.paste(before.crop(crop),(0,28));sheet.paste(after.crop(crop),(320,28))
    draw.text((6,5),f'ANTES · {second}s',font=font,fill='white');draw.text((326,5),'PROPUESTA B / A · escala nativa',font=font,fill='white')
    sheet.save(HERE/'review'/f'game_native_{second:02d}s.png')
(HERE/'validation/comparison_check.json').write_text(json.dumps(checks,indent=2)+'\n')
page='''<!doctype html><html lang="es"><meta charset="utf-8"><title>T281 · La Cuadrilla</title>
<style>body{background:#1c2126;color:#eee;font:16px sans-serif;margin:24px}a{color:#e9bd7a}button,select{font:inherit;padding:8px;margin:6px}img.map{width:1280px;height:720px;max-width:none}.row{display:flex;gap:18px}p{max-width:1000px}</style>
<h1>T281 · Propuestas de La Cuadrilla</h1><p>Sin aprobación ni integración. Dos Rateros (B/C) y dos Cargadores (A/B). Ciclos exploratorios de Ratero B y Cargador A: Lucas elige antes de integrar. El estudio Ratero A se descartó por realismo y halo.</p>
<p><a href="review/contact_220.png">Hoja 220 px</a> · <a href="review/contact_34.png">Lienzos 34 px</a> · <a href="review/silhouettes_visible_34.png">Siluetas de 34 px visibles</a></p>
<img src="review/contact_220.png" width="976"><div class="row"><img src="review/ratero_walk.gif"><img src="review/cargador_walk.gif"></div>
<p>GIF: cadencia de revisión común por especie; las velocidades del juego dependen del recorrido. Atlas 4 direcciones × 4 fases, no modelo 3D compartido. Hay deriva de proporciones y rasgos entre vistas.</p>
<h2>Partida real, nivel 7, oleada 8</h2><p>Escena y oleada de producción, avance automático sin torres ni intervención humana. Se salta a la oleada 8 con la función existente de pruebas; a los 3/6/9 segundos se pausa y se cambian solo textura y atlas sobre duplicados de EnemyData en memoria. Mismos enemigos, posición, datos, cámara y HUD en cada par. No se guarda la propuesta en el juego.</p>
<select id="time"><option>3</option><option>6</option><option>9</option></select><button onclick="phase='before';show()">Antes</button><button onclick="phase='after';show()">Propuesta B / A</button><br><img class="map" id="map">
<script>let phase='before';function show(){map.src='captures/level_07_wave_08_'+time.value.padStart(2,'0')+'s_'+phase+'.png'}time.onchange=show;show()</script>
<h2>Recortes nativos (1:1)</h2>'''
for second in [3,6,9]:page+=f'<p><img src="review/game_native_{second:02d}s.png" width="640"></p>'
page+='</html>'
(HERE/'comparison.html').write_text(page)
print('6 capturas 1280×720; 3 comparaciones sin diferencias fuera de los actores seleccionados.')
