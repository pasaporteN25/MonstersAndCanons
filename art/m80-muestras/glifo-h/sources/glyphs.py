"""Tres signos originales: polígonos manuales, nunca caracteres de una fuente.

Coordenadas locales 0..60, 0..64. El mismo contorno se reutiliza sin reflejar.
Los quiebres y muescas son geometría; el desgaste pertenece al material.
"""
from pathlib import Path

GLYPHS = {
    'g1': [
        [(2,9),(14,1),(22,4),(17,13),(17,51),(23,57),(10,63),(4,57),(6,43),(6,17)],
        [(43,7),(54,4),(57,14),(53,50),(59,53),(49,63),(40,58),(42,19),(35,19),(34,10)],
        [(14,29),(29,21),(37,31),(46,23),(49,35),(35,44),(27,33),(14,41)],
    ],
    'g2': [
        [(1,10),(11,1),(19,8),(14,17),(15,49),(22,55),(10,63),(3,55),(5,17)],
        [(21,15),(29,11),(28,51),(20,55)],
        [(39,6),(48,2),(56,11),(51,21),(48,44),(54,46),(59,39),(59,54),(49,63),(37,56),(38,35),(26,35),(25,24),(40,22)],
    ],
    'g3': [
        [(4,1),(18,6),(15,27),(19,32),(14,38),(15,59),(3,64),(5,43),(1,35),(5,28)],
        [(41,13),(54,8),(51,28),(58,33),(51,40),(54,59),(42,62),(38,48),(41,40)],
        [(10,37),(56,19),(60,30),(12,49),(6,44)],
    ],
}
NAMES = {'g1':'Pilares y barra quebrada', 'g2':'Bucle abierto', 'g3':'Angular y rúnica'}


def export_svg(folder):
    for key, polygons in GLYPHS.items():
        paths = '\n'.join('<polygon points="'+' '.join(f'{x},{y}' for x,y in p)+'"/>' for p in polygons)
        svg = f'''<!-- Signo original {key}: {NAMES[key]}; fuente editable, no recurso del juego. -->
<svg xmlns="http://www.w3.org/2000/svg" width="60" height="64" viewBox="0 0 60 64">
<g fill="#171813">{paths}</g></svg>
'''
        (Path(folder)/f'glyph_{key}.svg').write_text(svg, encoding='utf-8')
