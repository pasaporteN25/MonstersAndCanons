#!/usr/bin/env python3
"""Produce dos muestras localizadas usando la composición T483 sin cambiar runtime."""
from pathlib import Path
import importlib.util
import json
import sys
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
ART = Path(__file__).resolve().parent
BASE = ROOT / 'art/t483-mapa-organico'
OUT = ROOT / 'Capturas'
ET.register_namespace('', 'http://www.w3.org/2000/svg')

VARIANTS = {
    'A': {
        'nodes': [[500,310],[572,350],[639,366],[698,352],[757,332]],
        'segment': 'C467 274 478 299 500 310 C523 321 546 345 572 350 C595 354 616 370 639 366 C662 364 677 355 698 352 C721 347 738 339 757 332 C784 323 811 323 835 321',
    },
    'B': {
        'nodes': [[492,317],[557,343],[603,389],[682,389],[759,342]],
        'segment': 'C469 273 478 299 492 317 C507 332 536 329 557 343 C579 357 582 382 603 389 C626 397 653 390 682 389 C712 388 738 360 759 342 C786 320 813 320 835 321',
    },
}


def load_compositor():
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location('t483_preview', BASE / 'render_preview.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def make_sources(letter: str, variant: dict) -> tuple[Path, dict]:
    target = ART / f'option_{letter.lower()}'
    target.mkdir(exist_ok=True)
    points = json.loads((BASE / 'route_points.json').read_text())
    points['nodes'][4:9] = variant['nodes']
    source = ET.parse(BASE / 'route.svg')
    root = source.getroot()
    children = list(root)
    # Se conserva desde aterrizaje hasta 4, y desde 10 hasta 15. Solo cambia 4→10.
    # La fase de los guiones del recorrido original depende de su longitud total.
    # Conserva los guiones originales fuera del tramo cambiado mediante recorte.
    children[7].set('clip-path', 'url(#unchanged-route)')
    namespace = '{http://www.w3.org/2000/svg}'
    clip = ET.Element(namespace + 'clipPath', {'id':'unchanged-route'})
    ET.SubElement(clip,namespace+'rect',{'x':'20','y':'90','width':'423','height':'472'})
    ET.SubElement(clip,namespace+'rect',{'x':'835','y':'90','width':'425','height':'472'})
    central = ET.Element(namespace+'path',{
        'id':'central-route', 'd':'M443 262 '+variant['segment'],
        'fill':'none','stroke':'#d2be7e','stroke-opacity':'.57','stroke-width':'2.4',
        'stroke-dasharray':'4 10','stroke-linecap':'round'})
    for node_index in range(4,9):
        x,y=points['nodes'][node_index]
        children[10+node_index].set('transform', f'translate({x} {y})')
    root.insert(8,central)
    root.append(clip)
    svg = target / 'route.svg'
    ET.indent(source, space='  ')
    source.write(svg, encoding='utf-8', xml_declaration=False)
    svg.write_text(f'<!-- T484 {letter}: solo se propone otra geometría entre los puntos 4 y 10 de T483. -->\n' + svg.read_text()+'\n')
    (target / 'route_points.json').write_text(json.dumps(points,indent=2)+'\n')
    return target, points


def make_sheet(compositor, screens: dict) -> None:
    sheet=Image.new('RGB',(1280,1650),'#181d20')
    draw=ImageDraw.Draw(sheet)
    rows=[('Actual T483 · rodeo que Lucas pidió ajustar','Actual', 'El punto más bajo llega a y=427.'),
          ('A · Rodeo menos profundo','A', 'Extremo central en y=366; continuidad más tenue y abierta.'),
          ('B · Rodeo por tramos desiguales','B', 'Dos diagonales y un centro tendido; extremo en y=389.')]
    for row,(title,key,detail) in enumerate(rows):
        top=row*535
        draw.text((20,top+12),title,font=compositor.font(22,True),fill='#ead9b0')
        preview=screens[key].crop((142,142,1138,519)).resize((1244,471),Image.Resampling.LANCZOS)
        sheet.paste(preview,(18,top+50))
        # El pie explica el cambio sin marcar ni alterar el arte de la muestra.
        draw.text((25,top+521),detail,font=compositor.font(11),fill='#c9d1c4')
    draw.text((24,1620),'Solo cambian 5–9 y sus conexiones. Costa, aterrizaje, 1–4 y 10–15 se conservan.',font=compositor.font(15),fill='#d0d5cb')
    sheet.save(OUT/'T484-comparacion-tramo-sur.png',optimize=True)


def main() -> None:
    compositor=load_compositor()
    screens={'Actual': Image.open(OUT/'T483-propuesta-recorrido.png').convert('RGB')}
    for letter,variant in VARIANTS.items():
        target,points=make_sources(letter,variant)
        compositor.ART=target
        compositor.POINTS=points
        screen=compositor.compose(compositor.rasterize())
        screen.save(OUT/f'T484-alternativa-{letter}.png',optimize=True)
        screens[letter]=screen
    make_sheet(compositor,screens)


if __name__=='__main__':
    main()
