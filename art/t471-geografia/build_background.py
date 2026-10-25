#!/usr/bin/env python3
"""T471: deriva el fondo de runtime y los datos del modelo desde la fuente aprobada de T485 (ruta B).

Salidas:
- assets/ui/campaign_map_background.svg: atlas completo (terreno en color, sin máscaras de zona, sin marcadores,
  candados, estrellas, aterrizaje ni ruta: eso lo dibuja la interfaz según el progreso).
- art/t471-geografia/model_data.json: costa aplanada y tramos de la ruta B, que se copian a `campaign_map.gd`.
No modifica el juego fuera de ese SVG. Uso, desde la raíz: python3 -I art/t471-geografia/build_background.py
"""
from pathlib import Path
import importlib.util
import json
import re
import sys
import xml.etree.ElementTree as ET

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('t485', ROOT / 'art/t485-atlas-biomas/render_preview.py')
t485 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(t485)
SVG = '{http://www.w3.org/2000/svg}'
CURVE_STEPS = 4


def runtime_svg() -> ET.Element:
    root = t485.make_svg(2)  # estado de atlas completo: sin máscara de zonas
    defs = root[0]
    for e in list(defs):
        if e.attrib.get('id', '').startswith(('zone-', 'gray-')) or e.attrib.get('id') in ('star', 'lock', 'flag', 'lander'):
            defs.remove(e)
    for e in list(root):
        ident = e.attrib.get('id', '')
        is_route = e.tag == SVG + 'path' and e.attrib.get('stroke-dasharray')
        is_lander = e.tag == SVG + 'g' and e.attrib.get('transform') == 'translate(177 310)'
        if ident == 'terrain-gray' or ident.startswith('level-') or is_route or is_lander:
            root.remove(e)
    return root


def flatten_coast(d: str) -> list[list[float]]:
    tokens = re.findall(r'[MCLZ]|-?\d+(?:\.\d+)?', d)
    points: list[tuple[float, float]] = []
    i = 0
    cmd = ''
    while i < len(tokens):
        if tokens[i] in 'MCLZ':
            cmd = tokens[i]
            i += 1
            continue
        n = {'M': 2, 'L': 2, 'C': 6}[cmd]
        v = [float(x) for x in tokens[i:i + n]]
        i += n
        if cmd in 'ML':
            points.append((v[0], v[1]))
        else:
            p0 = points[-1]
            for s in range(1, CURVE_STEPS + 1):
                t = s / CURVE_STEPS
                u = 1 - t
                x = u**3 * p0[0] + 3 * u * u * t * v[0] + 3 * u * t * t * v[2] + t**3 * v[4]
                y = u**3 * p0[1] + 3 * u * u * t * v[1] + 3 * u * t * t * v[3] + t**3 * v[5]
                points.append((x, y))
    if points[-1] == points[0]:
        points.pop()
    return [[round(x, 1), round(y, 1)] for x, y in points]


def route_segments() -> list[list[float]]:
    parts = t485.base_route().split(' C')
    start = [float(x) for x in parts[0].removeprefix('M').split()]
    segments = [[float(x) for x in p.split()] for p in parts[1:]]
    return [start] + segments


def main() -> None:
    root = runtime_svg()
    ET.indent(root, space='  ')
    out = ROOT / 'assets/ui/campaign_map_background.svg'
    out.write_text('<!-- Fondo del atlas de Cántaro (T471): derivado de `art/t485-atlas-biomas` (ruta B aprobada), estado completo '
                   'sin zonas ocultas. Generado por `art/t471-geografia/build_background.py`; marcadores, ruta y aterrizaje se dibujan en la interfaz. -->\n'
                   + ET.tostring(root, encoding='unicode') + '\n')
    data = {'coast': flatten_coast(t485.COAST), 'route': route_segments(), 'nodes': t485.POINTS['nodes'], 'landing': t485.POINTS['landing']}
    (ROOT / 'art/t471-geografia/model_data.json').write_text(json.dumps(data) + '\n')
    print(len(data['coast']), 'puntos de costa;', len(data['route']) - 1, 'tramos')


if __name__ == '__main__':
    main()
