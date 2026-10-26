#!/usr/bin/env python3
"""T488: máscaras grises G2 «relieve desvaído» de las zonas ocultas del atlas (RF-709, RF-710, D-209).

Procedencia: la variante G2 la aprobó Lucas el 2026-10-26 sobre la muestra de T469 (`art/t469-mapa-propuesta/`). Acá se la
rehace para producción a partir del atlas vigente `assets/ui/campaign_map_background.svg` (el mismo que dibuja la vista) y de
los contornos de zona de `art/t485-atlas-biomas/render_preview.py` (A = niveles 1-5, B = 6-10, C = 11-15).

El atlas se pasa a grises (Y' = 78 + 0,38 * Y, sin matiz de bioma) y se recorta a la costa y a la zona; el borde de la zona es
nítido y el contorno de la costa es el del mapa (#2b2233). No lleva nodos, números, candados, estrellas, ruta, rótulo ni animación.

Salidas (todas del tamaño del atlas, 1240 x 472 con viewBox "20 90 1240 472", así se dibujan con la misma escala y origen):
- assets/ui/campaign_hidden_zones/hidden_zone_b.svg: la zona B (entre el borde de A y el de B; se mete 3 unidades bajo C).
- assets/ui/campaign_hidden_zones/hidden_zone_c.svg: la zona C (todo lo que queda al este del borde de B).
- art/t488-mascara-g2/gris_G2_atlas.svg: el atlas completo en grises (fuente editable de las dos).
Uso, desde la raíz del proyecto: python3 -I art/t488-mascara-g2/build.py
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
ATLAS = ROOT / 'assets/ui/campaign_map_background.svg'
OUT_DIR = ROOT / 'assets/ui/campaign_hidden_zones'
ART = ROOT / 'art/t488-mascara-g2'
LAND_EDGE = '#2b2233'
GRAY_LO, GRAY_K = 78, 0.38
OVERLAP = 3.0  # unidades del atlas que B se mete bajo C para que no quede una costura clara
BOTTOM, RIGHT = 600, 1300

# Borde este de la zona A y de la zona B (curvas cúbicas, de norte a sur), de render_preview.py de T485.
EDGE_A = [(660, 0), [((641, 150), (615, 180), (605, 205)), ((584, 226), (551, 227), (549, 255)),
                     ((545, 280), (513, 290), (525, 316)), ((539, 334), (514, 357), (520, 380)),
                     ((523, 400), (486, 412), (500, 437)), ((515, 463), (560, 459), (570, 490))], (580, 600)]
EDGE_B = [(955, 0), [((956, 167), (948, 211), (920, 239)), ((904, 250), (884, 253), (887, 276)),
                     ((891, 294), (866, 299), (861, 322)), ((856, 342), (886, 355), (880, 374)),
                     ((868, 397), (885, 411), (905, 426)), ((925, 447), (889, 459), (902, 483))], (962, 600)]


def fmt(p):
    return f'{p[0]:g} {p[1]:g}'


def edge_down(edge, dx=0.0):
    """Tramos del borde de norte a sur, como comandos de path (sin el M inicial)."""
    start, curves, end = edge
    cmds = ''
    for c1, c2, to in curves:
        cmds += ' C' + ' '.join(fmt((x + dx, y)) for x, y in (c1, c2, to))
    return fmt((start[0] + dx, start[1])), cmds + ' L' + fmt((end[0] + dx, end[1]))


def edge_up(edge, dx=0.0):
    """El mismo borde de sur a norte (curvas invertidas)."""
    start, curves, end = edge
    pts = [start] + [c[2] for c in curves]
    cmds = ' L' + fmt((curves[-1][2][0] + dx, curves[-1][2][1]))
    for i in range(len(curves) - 1, -1, -1):
        c1, c2, _ = curves[i]
        cmds += ' C' + ' '.join(fmt((x + dx, y)) for x, y in (c2, c1, pts[i]))
    return cmds


def zone_b_path():
    a_start, a_cmds = edge_down(EDGE_A)
    return (f'M{a_start}{a_cmds} L{EDGE_B[2][0] + OVERLAP:g} {BOTTOM}'
            f'{edge_up(EDGE_B, OVERLAP)} Z')


def zone_c_path():
    b_start, b_cmds = edge_down(EDGE_B)
    return f'M{b_start}{b_cmds} L{RIGHT} {BOTTOM} L{RIGHT} 0 Z'


def atlas_inner():
    s = ATLAS.read_text()
    s = re.sub(r'^<!--.*?-->\s*', '', s, flags=re.S)
    return re.search(r'<svg[^>]*>(.*)</svg>', s, re.S).group(1)


def gray_hex(h):
    if len(h) == 4:
        h = '#' + ''.join(ch * 2 for ch in h[1:])
    r, g, b = (int(h[i:i + 2], 16) for i in (1, 3, 5))
    y = GRAY_LO + (0.2126 * r + 0.7152 * g + 0.0722 * b) * GRAY_K
    return '#' + ''.join(f'{max(0, min(255, int(y + d))):02x}' for d in (-3, 1, 2))


def gray_atlas():
    """El atlas con todos los colores pasados a gris; los ids llevan el prefijo g- para no chocar."""
    s = atlas_inner()
    for i in re.findall(r'id="([^"]+)"', s):
        s = s.replace(f'id="{i}"', f'id="g-{i}"').replace(f'url(#{i})', f'url(#g-{i})')
    return re.sub(r'#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b', lambda m: gray_hex(m.group(0)), s)


def coast_d():
    return re.search(r'<clipPath id="land-clip">\s*<path d="([^"]+)"', atlas_inner()).group(1)


def zone_svg(zone_id, zone_d, comment):
    return (f'<!-- {comment} Generado por art/t488-mascara-g2/build.py (T488, G2 «relieve desvaído»). -->\n'
            '<svg xmlns="http://www.w3.org/2000/svg" width="1240" height="472" viewBox="20 90 1240 472">\n'
            f'<defs><clipPath id="{zone_id}-area"><path d="{zone_d}"/></clipPath></defs>\n'
            f'<g clip-path="url(#{zone_id}-area)">\n<g clip-path="url(#g-land-clip)">{gray_atlas()}</g>\n'
            f'<path d="{coast_d()}" fill="none" stroke="{LAND_EDGE}" stroke-width="2.6"/>\n</g>\n</svg>\n')


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / 'hidden_zone_b.svg').write_text(zone_svg('zb', zone_b_path(), 'Zona B (niveles 6 a 10) sin descubrir.'))
    (OUT_DIR / 'hidden_zone_c.svg').write_text(zone_svg('zc', zone_c_path(), 'Zona C (niveles 11 a 15) sin descubrir.'))
    (ART / 'gris_G2_atlas.svg').write_text(
        '<!-- T488: atlas vigente pasado a grises (G2). Fuente editable de las máscaras; derivado por build.py. -->\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" width="1240" height="472" viewBox="20 90 1240 472">{gray_atlas()}</svg>\n')
    print('ok')


if __name__ == '__main__':
    main()
