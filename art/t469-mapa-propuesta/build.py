#!/usr/bin/env python3
"""T469: genera la muestra de insignias de conquista y de zonas ocultas del atlas. No toca el juego.

Lee (solo lectura): assets/ui/campaign_map_background.svg (atlas integrado, T471) y scripts/logic/campaign_map.gd
(puntos y curvas de la ruta). Escribe solo en esta carpeta: insignias/, escenas/, frames/ y index.html.
Uso, desde la raiz del worktree:  python3 -I art/t469-mapa-propuesta/build.py
Las capturas PNG las saca `capturar.sh` con Firefox headless (ver index.md).
"""
from pathlib import Path
import json
import math
import re

ROOT = Path(__file__).resolve().parents[2]
ART = Path(__file__).resolve().parent
ATLAS = ROOT / 'assets/ui/campaign_map_background.svg'

# ---------------------------------------------------------------- geometria del atlas (igual que el juego)
SEA_ORIGIN = (20.0, 90.0)
SEA_SIZE = (1240.0, 472.0)
MAP_SCALE = 1.14      # campaign_map_view.gd
MAP_TOP = 160.0
CANVAS_W = SEA_SIZE[0] * MAP_SCALE   # 1413.6
CANVAS_H = 380.0                     # MAP_HEIGHT
OFF_Y = -(MAP_TOP - SEA_ORIGIN[1]) * MAP_SCALE
LANDER = (177.0, 310.0)
RADIUS = 19.5                        # radio del dibujo en px logicos (el juego usa 19; 56 px de area tactil)

gd = (ROOT / 'scripts/logic/campaign_map.gd').read_text()
def _vecs(name):
    body = re.search(name + r'[^=]*=\s*\[(.*?)\n\]', gd, re.S).group(1)
    return [(float(a), float(b)) for a, b in re.findall(r'Vector2\(([\d.]+),\s*([\d.]+)\)', body)]
POINTS = _vecs('const REGION_POINTS')
CONTROLS = _vecs('const ROUTE_CONTROLS')
assert len(POINTS) == 15 and len(CONTROLS) == 45

# Zonas de descubrimiento (A 1-5, B 6-10, C 11-15): contornos de art/t485-atlas-biomas/render_preview.py.
ZONE_1 = 'M0 0 H660 C641 150 615 180 605 205 C584 226 551 227 549 255 C545 280 513 290 525 316 C539 334 514 357 520 380 C523 400 486 412 500 437 C515 463 560 459 570 490 L580 600 H0Z'
ZONE_2 = 'M0 0 H955 C956 167 948 211 920 239 C904 250 884 253 887 276 C891 294 866 299 861 322 C856 342 886 355 880 374 C868 397 885 411 905 426 C925 447 889 459 902 483 L962 600 H0Z'
COAST = None  # se toma del propio atlas (clipPath land-clip)

# ---------------------------------------------------------------- paleta (postes de T475: banner_post_enemy / banner_post_player)
OUT = '#2b2233'   # contorno de mapa (guia de arte)
REB = ('#d9604a', '#a6302f', '#5b2231')    # luz / medio / sombra: carmesi del pendon rebelde
REB_RING = '#231c28'                        # aro oscuro (pendon negro y rojo)
PLY = ('#4fb3aa', '#1f7f7c', '#124a54')    # turquesa del pendon del jugador
PLY_RING = '#ecd9ae'                        # crema del pendon del jugador
GOLD = '#f0cb70'
STAR = '#f0d176'
NUM = '#fff7e6'
NUM_OUT = '#1c1620'

# ---------------------------------------------------------------- insignias (64x64, centro 32,32, radio 26)
VARIANTS = {
    'v1': 'Aro liso',
    'v2': 'Aro dentado / con tachas',
    'v3': 'Relieve con costura diagonal',
}


def grad(gid, c, radial=False):
    if radial:
        return (f'<radialGradient id="{gid}" cx=".35" cy=".28" r=".85"><stop offset="0" stop-color="{c[0]}"/>'
                f'<stop offset=".5" stop-color="{c[1]}"/><stop offset="1" stop-color="{c[2]}"/></radialGradient>')
    return (f'<linearGradient id="{gid}" x1="0" y1="0" x2=".25" y2="1"><stop offset="0" stop-color="{c[0]}"/>'
            f'<stop offset=".5" stop-color="{c[1]}"/><stop offset="1" stop-color="{c[2]}"/></linearGradient>')


def jagged(r_out=26.0, r_in=22.0, n=12):
    pts = []
    for k in range(n * 2):
        a = -math.pi / 2 + k * math.pi / n
        r = r_out if k % 2 == 0 else r_in
        pts.append(f'{32 + r * math.cos(a):.2f},{32 + r * math.sin(a):.2f}')
    return ' '.join(pts)


def studs(r=23.4, n=12, rad=1.7, fill=PLY_RING):
    out = []
    for k in range(n):
        a = k * 2 * math.pi / n
        out.append(f'<circle cx="{32 + r * math.cos(a):.2f}" cy="{32 + r * math.sin(a):.2f}" r="{rad}" fill="{fill}" stroke="{OUT}" stroke-width=".7"/>')
    return ''.join(out)


def face(v, f):
    """Una cara completa (rebelde o jugador) de la variante v."""
    c, ring = (REB, REB_RING) if f == 'r' else (PLY, PLY_RING)
    g = ('gr' if f == 'r' else 'gp') + v
    if v == 'v1':
        return (f'<circle cx="32" cy="32" r="26" fill="{OUT}"/><circle cx="32" cy="32" r="24" fill="{ring}"/>'
                f'<circle cx="32" cy="32" r="20.5" fill="url(#{g})" stroke="{OUT}" stroke-width="1"/>'
                f'<path d="M17 25 A16.5 16.5 0 0 1 28 16" fill="none" stroke="#fff" stroke-opacity=".35" stroke-width="1.6" stroke-linecap="round"/>')
    if v == 'v2':
        if f == 'r':
            return (f'<polygon points="{jagged()}" fill="{ring}" stroke="{OUT}" stroke-width="1.6" stroke-linejoin="round"/>'
                    f'<circle cx="32" cy="32" r="18.6" fill="url(#{g})" stroke="{OUT}" stroke-width="1"/>'
                    f'<path d="M18 26 A15.5 15.5 0 0 1 28 17" fill="none" stroke="#fff" stroke-opacity=".3" stroke-width="1.5" stroke-linecap="round"/>')
        return (f'<circle cx="32" cy="32" r="26" fill="{ring}" stroke="{OUT}" stroke-width="1.6"/>{studs()}'
                f'<circle cx="32" cy="32" r="18.6" fill="url(#{g})" stroke="{OUT}" stroke-width="1"/>'
                f'<path d="M18 26 A15.5 15.5 0 0 1 28 17" fill="none" stroke="#fff" stroke-opacity=".3" stroke-width="1.5" stroke-linecap="round"/>')
    # v3: relieve (degrade radial, bisel claro arriba a la izquierda)
    return (f'<circle cx="32" cy="32" r="26" fill="{OUT}"/><circle cx="32" cy="32" r="24.2" fill="url(#gb{f})"/>'
            f'<circle cx="32" cy="32" r="19.5" fill="url(#{g})" stroke="{OUT}" stroke-width="1.2"/>'
            f'<path d="M14.5 27 A18 18 0 0 1 27 14.5" fill="none" stroke="#fff" stroke-opacity=".42" stroke-width="1.8" stroke-linecap="round"/>')


def badge_defs(v):
    d = grad('gr' + v, REB, v == 'v3') + grad('gp' + v, PLY, v == 'v3')
    d += (f'<linearGradient id="gbr" x1="0" y1="0" x2=".4" y2="1"><stop offset="0" stop-color="#5a4a60"/><stop offset="1" stop-color="{REB_RING}"/></linearGradient>'
          f'<linearGradient id="gbp" x1="0" y1="0" x2=".4" y2="1"><stop offset="0" stop-color="#fff3cf"/><stop offset="1" stop-color="#b79c68"/></linearGradient>')
    # mitades: rebelde a la izquierda (o arriba-izquierda), jugador a la derecha
    if v == 'v3':
        d += '<clipPath id="cl"><polygon points="0,0 40,0 24,64 0,64"/></clipPath><clipPath id="cr"><polygon points="40,0 64,0 64,64 24,64"/></clipPath>'
    else:
        d += '<clipPath id="cl"><rect x="0" y="0" width="32" height="64"/></clipPath><clipPath id="cr"><rect x="32" y="0" width="32" height="64"/></clipPath>'
    return d


def badge_body(v, kind):
    if kind == 'rebelde':
        return face(v, 'r')
    if kind == 'jugador':
        return face(v, 'p')
    seam = '<line x1="40" y1="-2" x2="24" y2="66" ' if v == 'v3' else '<line x1="32" y1="4" x2="32" y2="60" '
    return (f'<g clip-path="url(#cl)">{face(v, "r")}</g><g clip-path="url(#cr)">{face(v, "p")}</g>'
            f'{seam}stroke="{OUT}" stroke-width="2.2" clip-path="url(#cc)"/>'
            f'<clipPath id="cc"><circle cx="32" cy="32" r="25"/></clipPath>')


def badge_svg(v, kind):
    note = {'rebelde': 'rebelde (sin victoria)', 'partido': 'partido (1-2 estrellas)', 'jugador': 'del jugador (3 estrellas)'}[kind]
    return (f'<!-- T469 propuesta: insignia {note}, variante {v} ({VARIANTS[v]}); sin numero ni emblema canonico. Propuesta, no integrada. -->\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><defs>{badge_defs(v)}</defs>'
            f'{badge_body(v, kind)}</svg>\n')


def locked_body():
    # candado: mismo dibujo que CampaignRegion.draw_mark (LOCKED), a radio 24 sobre 64
    r = 24.0
    return (f'<circle cx="32" cy="32" r="{r}" fill="#414b4b" stroke="#222a2b" stroke-width="2.4"/>'
            f'<rect x="{32 - .33 * r:.2f}" y="{32 - .05 * r:.2f}" width="{.66 * r:.2f}" height="{.5 * r:.2f}" fill="#555d5c" stroke="#b3b9b4" stroke-width="1.8"/>'
            f'<path d="M{32 - .22 * r:.2f} {32 - .05 * r:.2f} A{.22 * r:.2f} {.22 * r:.2f} 0 0 1 {32 + .22 * r:.2f} {32 - .05 * r:.2f}" fill="none" stroke="#b3b9b4" stroke-width="2"/>')


# ---------------------------------------------------------------- piezas sueltas sobre el atlas
def star_poly(cx, cy, r=6.0):
    pts = []
    for k in range(10):
        rr = r if k % 2 == 0 else r * 0.43
        a = -math.pi / 2 + k * math.pi / 5
        pts.append(f'{cx + rr * math.cos(a):.2f},{cy + rr * math.sin(a):.2f}')
    return f'<polygon points="{" ".join(pts)}" fill="{STAR}" stroke="{OUT}" stroke-width=".9" stroke-linejoin="round"/>'


def stars_svg(cx, cy, n):
    step = 11.0
    first = -step * (n - 1) / 2
    return ''.join(star_poly(cx + first + step * i, cy) for i in range(n))


def number_svg(cx, cy, n):
    size = 15 if n < 10 else 14
    return (f'<text x="{cx:.1f}" y="{cy + size * .36:.1f}" text-anchor="middle" font-family="DejaVu Sans, Verdana, sans-serif" '
            f'font-weight="700" font-size="{size}" fill="{NUM}" stroke="{NUM_OUT}" stroke-width="3" stroke-linejoin="round" paint-order="stroke">{n}</text>')


def lander_svg(cx, cy):
    hull = [(-8, 3), (-6, -5), (0, -9), (6, -5), (8, 3), (4, 7), (-4, 7)]
    pts = ' '.join(f'{cx + x:.1f},{cy + y:.1f}' for x, y in hull)
    return (f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="21" fill="#202226" stroke="#e1b45b" stroke-width="2"/>'
            f'<polygon points="{pts}" fill="#bd9a60" stroke="{OUT}" stroke-width="1.5"/>'
            f'<line x1="{cx - 5}" y1="{cy + 6}" x2="{cx - 9}" y2="{cy + 12}" stroke="#d2ad6a" stroke-width="2"/>'
            f'<line x1="{cx + 5}" y1="{cy + 6}" x2="{cx + 9}" y2="{cy + 12}" stroke="#d2ad6a" stroke-width="2"/>'
            f'<rect x="{cx - 44}" y="{cy + 26}" width="88" height="18" fill="#1d2022" stroke="#86623a"/>'
            f'<text x="{cx}" y="{cy + 39}" text-anchor="middle" font-family="DejaVu Sans, sans-serif" font-size="11" fill="#f4d98f">ATERRIZAJE</text>')


def to_canvas(p):
    return ((p[0] - SEA_ORIGIN[0]) * MAP_SCALE, (p[1] - SEA_ORIGIN[1]) * MAP_SCALE + OFF_Y)


# ---------------------------------------------------------------- el atlas y su version gris
def atlas_inner():
    s = ATLAS.read_text()
    s = re.sub(r'^<!--.*?-->\s*', '', s, flags=re.S)
    return re.search(r'<svg[^>]*>(.*)</svg>', s, re.S).group(1)


def gray_hex(h, lo, k):
    if len(h) == 4:
        h = '#' + ''.join(ch * 2 for ch in h[1:])
    r, g, b = (int(h[i:i + 2], 16) for i in (1, 3, 5))
    y = lo + (0.2126 * r + 0.7152 * g + 0.0722 * b) * k
    return '#' + ''.join(f'{max(0, min(255, int(y + d))):02x}' for d in (-3, 1, 2))


def gray_atlas(lo, k):
    """Copia del atlas en grises (sin matiz de bioma). Los ids se renombran con g- para no chocar con el atlas en color."""
    s = atlas_inner()
    ids = re.findall(r'id="([^"]+)"', s)
    for i in ids:
        s = s.replace(f'id="{i}"', f'id="g-{i}"').replace(f'url(#{i})', f'url(#g-{i})')
    return re.sub(r'#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b', lambda m: gray_hex(m.group(0), lo, k), s)


def coast_d():
    return re.search(r'<clipPath id="land-clip">\s*<path d="([^"]+)"', atlas_inner()).group(1)


# Variantes de gris. G1: niebla lisa (no deja ver ningun bioma). G2: relieve desvaido (el relieve se adivina, sin color).
GRAYS = {
    'G1': 'Niebla pizarra: gris liso y borde difuso; no deja ver el relieve ni los biomas.',
    'G2': 'Relieve desvaido: terreno del atlas en grises y borde nitido; se adivina el relieve, sin color de bioma.',
}


def hidden_overlay(gv, zone_d):
    cd = coast_d()
    mask = (f'<mask id="m-hide" maskUnits="userSpaceOnUse" x="20" y="90" width="1240" height="472"><rect x="20" y="90" width="1240" height="472" fill="#fff"/>')
    if gv == 'G1':
        for w, a in ((28, .10), (20, .18), (12, .32)):
            mask += f'<path d="{zone_d}" fill="none" stroke="#000" stroke-opacity="{a}" stroke-width="{w}"/>'
    mask += f'<path d="{zone_d}" fill="#000"/></mask>'
    if gv == 'G1':
        body = ('<linearGradient id="fog" x1="0" y1="0" x2=".3" y2="1"><stop offset="0" stop-color="#848b8c"/>'
                '<stop offset=".55" stop-color="#737a7b"/><stop offset="1" stop-color="#636a6c"/></linearGradient>'
                f'<path d="{cd}" fill="url(#fog)"/>')
        defs = ''
    else:
        defs = ''
        body = gray_atlas(78, .38)
    inner = f'<g clip-path="url(#land-clip)"><g mask="url(#m-hide)">{body}</g></g>'
    edge = f'<path d="{cd}" fill="none" stroke="{OUT}" stroke-width="2.6"/>'
    return f'<defs>{mask}{defs}</defs>{inner}{edge}'


# ---------------------------------------------------------------- escena completa del lienzo del mapa
def scene_svg(variant='v1', progress=None, discovered=15, selected=None, focus=None, gray='G1', locked_only_badges=True,
              note=''):
    """progress[i]: 'L' bloqueado, 'A' disponible (sin victoria), 0..3 estrellas (0 = disponible, 1-2 partido, 3 jugador).
    Se dibuja el lienzo del juego: 1413,6 x 380 px logicos, atlas a 1,14 recortado desde MAP_TOP."""
    progress = progress or ['L'] * 15
    zone = {5: ZONE_1, 10: ZONE_2}.get(discovered)
    atlas = atlas_inner()
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{CANVAS_W:.1f}" height="{CANVAS_H:.0f}" viewBox="0 0 {CANVAS_W:.1f} {CANVAS_H:.0f}">',
             f'<!-- T469 propuesta: escena de lienzo {CANVAS_W:.0f}x{CANVAS_H:.0f}, insignias {variant}, gris {gray}, zonas descubiertas hasta el nivel {discovered}. {note} Maqueta, no es el juego. -->',
             f'<defs>{badge_defs(variant)}<clipPath id="view"><rect width="{CANVAS_W:.1f}" height="{CANVAS_H:.0f}"/></clipPath>',
             f'<g id="locked">{locked_body()}</g>',
             f'<g id="b-rebelde">{badge_body(variant, "rebelde")}</g><g id="b-partido">{badge_body(variant, "partido")}</g><g id="b-jugador">{badge_body(variant, "jugador")}</g></defs>',
             '<g clip-path="url(#view)">',
             f'<g transform="translate(0 {OFF_Y:.2f}) scale({MAP_SCALE}) translate({-SEA_ORIGIN[0]} {-SEA_ORIGIN[1]})">{atlas}']
    if zone:
        parts.append(hidden_overlay(gray, zone))
    parts.append('</g>')
    # ruta: solo hasta la ultima zona descubierta
    segs = []
    start = LANDER
    for i in range(discovered):
        c1, c2, end = CONTROLS[i * 3:i * 3 + 3]
        p0, p1, p2, p3 = (to_canvas(q) for q in (start, c1, c2, end))
        open_ = i == 0 or progress[i - 1] != 'L'
        op = '1' if open_ else '.28'
        segs.append(f'<path d="M{p0[0]:.1f} {p0[1]:.1f} C{p1[0]:.1f} {p1[1]:.1f} {p2[0]:.1f} {p2[1]:.1f} {p3[0]:.1f} {p3[1]:.1f}" fill="none" stroke="#e0bc6a" stroke-opacity="{op}" stroke-width="2" stroke-dasharray="7 5"/>')
        start = end
    parts += segs
    lx, ly = to_canvas(LANDER)
    parts.append(lander_svg(lx, ly))
    for i in range(discovered):
        cx, cy = to_canvas(POINTS[i])
        st = progress[i]
        s = RADIUS / 26.0
        if selected == i:
            parts.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{RADIUS + 6}" fill="none" stroke="#f0cb70" stroke-width="2"/>')
        if focus == i:
            parts.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{RADIUS + 11}" fill="none" stroke="#ffffff" stroke-width="3"/>')
        if st == 'L':
            parts.append(f'<use href="#locked" transform="translate({cx - 32 * s * .92:.2f} {cy - 32 * s * .92:.2f}) scale({s * .92:.4f})"/>')
            continue
        kind = 'rebelde' if st in ('A', 0) else ('partido' if st in (1, 2) else 'jugador')
        parts.append(f'<use href="#b-{kind}" transform="translate({cx - 32 * s:.2f} {cy - 32 * s:.2f}) scale({s:.4f})"/>')
        if st == 'A' or st == 0:
            parts.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{RADIUS + 3.2}" fill="none" stroke="{GOLD}" stroke-width="1.6" stroke-dasharray="3 3"/>')
        parts.append(number_svg(cx, cy, i + 1))
        if isinstance(st, int) and st > 0:
            parts.append(stars_svg(cx, cy - RADIUS - 9, st))
    # brujula y titulo, como el juego
    parts.append(f'<text x="14" y="22" font-family="DejaVu Sans, sans-serif" font-size="12" fill="#dfd7bf">ATLAS MERIDIANO · CÁNTARO</text>')
    ccx, ccy = CANVAS_W - 40, CANVAS_H - 42
    parts.append(f'<circle cx="{ccx:.1f}" cy="{ccy}" r="{19 * MAP_SCALE:.1f}" fill="#22282b" stroke="#98a69c" stroke-width="1.5"/>'
                 f'<polygon points="{ccx:.1f},{ccy - 13} {ccx + 4:.1f},{ccy} {ccx:.1f},{ccy + 12} {ccx - 4:.1f},{ccy}" fill="#f0d176"/>'
                 f'<text x="{ccx:.1f}" y="{ccy - 19 * MAP_SCALE - 5:.1f}" text-anchor="middle" font-family="DejaVu Sans, sans-serif" font-size="10" fill="#dfd7bf">N</text>')
    parts.append('</g></svg>\n')
    return ''.join(parts)


# progresos de ejemplo (maqueta, no guardados reales)
PROG_A = [3, 2, 1, 'A', 'L']
PROG_AB = [3, 3, 2, 1, 3, 'A', 'L', 'L', 'L', 'L']
PROG_ABC = [3, 3, 3, 2, 3, 3, 1, 3, 2, 3, 'A', 'L', 'L', 'L', 'L']
STATES = {'A': (PROG_A, 5, 3), 'AB': (PROG_AB, 10, 5), 'ABC': (PROG_ABC, 15, 10)}  # progreso, zonas, seleccionado (0-based)


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')


def main():
    for v in VARIANTS:
        for k in ('rebelde', 'partido', 'jugador'):
            write(ART / 'insignias' / f'{k}_{v}.svg', badge_svg(v, k))
    write(ART / 'insignias' / 'candado_actual.svg',
          '<!-- T469 referencia: candado actual de CampaignRegion (LOCKED), a 64x64; no se redibuja. -->\n'
          f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">{locked_body()}</svg>\n')
    for v in VARIANTS:
        write(ART / 'escenas' / f'atlas_{v}_completo.svg', scene_svg(v, PROG_ABC, 15, selected=10, focus=10))
    for g in GRAYS:
        for key, (prog, n, sel) in STATES.items():
            write(ART / 'escenas' / f'zonas_{g}_{key}.svg',
                  scene_svg('v1', prog, n, selected=sel, gray=g, note=f'Estado {key}.'))
    # copia de referencia del atlas usado (procedencia)
    write(ART / 'fuentes' / 'atlas_actual.svg', ATLAS.read_text())
    write(ART / 'fuentes' / 'gris_G2_atlas.svg',
          '<!-- T469: atlas integrado pasado a grises (variante G2). Derivado de atlas_actual.svg por build.py. -->\n'
          f'<svg xmlns="http://www.w3.org/2000/svg" width="1240" height="472" viewBox="20 90 1240 472">{gray_atlas(78, .38)}</svg>\n')
    print('ok')




# ================================================================ paginas HTML (maqueta y marcos de captura)
LEVEL_NAMES = {n: json.loads((ROOT / f'data/levels/level_{n:02}.json').read_text())['nombre'] for n in range(1, 16)}
REC = 'v1'   # variante recomendada (se ajusta tras la revision visual; ver index.md)

CSS = """
:root{--bg:#181d20;--panel:#222b2d;--line:#795e3c;--ink:#e7e2d2;--mut:#aeb6ac;--gold:#efcf75}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.5 'DejaVu Sans',Verdana,sans-serif}
h1{font-size:26px;margin:0 0 4px;color:#e7cc83}h2{font-size:20px;margin:34px 0 6px;color:#e7cc83;border-top:1px solid #333;padding-top:22px}
h3{font-size:16px;margin:18px 0 6px}p,li{max-width:900px}small,.mut{color:var(--mut)}
main{padding:24px 28px;max-width:1500px;margin:auto}
table{border-collapse:collapse;margin:8px 0}td,th{border:1px solid #3a3f3f;padding:5px 9px;text-align:left;vertical-align:top;font-size:13px}th{background:#222b2d}
.row{display:flex;flex-wrap:wrap;gap:6px 14px;align-items:flex-end;margin:6px 0}
.cell{text-align:center;font-size:11px;color:var(--mut)}
.chip{display:block;background:#4a5a3c;border-radius:6px}.chip.dark{background:#202a2d}
.touch{outline:1px dashed #e0bc6a;outline-offset:-1px}
.scroller{width:1240px;overflow-x:auto;border:1px solid #3a3f3f;background:#111}
.scroller img{display:block;max-width:none!important}
.frame{position:relative;width:1280px;height:720px;background:#1d2427;overflow:hidden;font-family:'DejaVu Sans',Verdana,sans-serif;color:#e7e2d2}
.frame .title{position:absolute;left:26px;top:20px;font-size:29px;font-weight:700;color:#e7cc83}
.frame .sub{position:absolute;left:28px;top:65px;font-size:16px;color:#c7cebf}
.frame .view{position:absolute;left:20px;top:105px;height:384px;overflow:hidden;border:1px solid #3b3329;border-radius:12px}
.frame .view img{display:block;position:absolute;top:0}
.frame .panel{position:absolute;left:20px;top:491px;height:72px;border:2px solid #8a663b;background:#202629;border-radius:7px}
.frame .panel b{position:absolute;left:18px;top:6px;font-size:27px;font-weight:400}
.frame .panel span{position:absolute;left:20px;top:46px;font-size:14px;color:#c6cdbc}
.frame .panel i{position:absolute;right:18px;top:7px;width:164px;height:52px;border:2px solid #a47e43;border-radius:5px;background:#242729;font-style:normal;font-size:23px;text-align:center;line-height:48px}
.frame .foot{position:absolute;left:28px;bottom:14px;font-size:12px;color:#8d958c}
.ph{background:#000;position:relative;overflow:hidden}
.ph .stage{position:absolute;transform-origin:0 0}
.mapas img{max-width:100%}
"""


def uniq(fragment, tag):
    ids = set(re.findall(r'id="([^"]+)"', fragment))
    for i in ids:
        fragment = fragment.replace(f'id="{i}"', f'id="{tag}{i}"').replace(f'url(#{i})', f'url(#{tag}{i})').replace(f'href="#{i}"', f'href="#{tag}{i}"')
    return fragment


_chip_n = [0]


def chip(v, kind, n=None, stars=0, size=1.0, sel=False, focus=False, dark=False, touch=False, halo=False):
    """Un cuadro de 64x64 px logicos (con 56 de area tactil) con la insignia al radio del juego (19,5 px)."""
    _chip_n[0] += 1
    tag = f'c{_chip_n[0]}'
    box = 72
    cx = cy = box / 2
    s = RADIUS / 26.0
    inner = ''
    if sel:
        inner += f'<circle cx="{cx}" cy="{cy}" r="{RADIUS + 6}" fill="none" stroke="#f0cb70" stroke-width="2"/>'
    if focus:
        inner += f'<circle cx="{cx}" cy="{cy}" r="{RADIUS + 11}" fill="none" stroke="#fff" stroke-width="3"/>'
    if kind == 'candado':
        inner += f'<g transform="translate({cx - 32 * s * .92} {cy - 32 * s * .92}) scale({s * .92})">{locked_body()}</g>'
    else:
        inner += f'<g transform="translate({cx - 32 * s} {cy - 32 * s}) scale({s})"><defs>{badge_defs(v)}</defs>{badge_body(v, kind)}</g>'
        if halo:
            inner += f'<circle cx="{cx}" cy="{cy}" r="{RADIUS + 3.2}" fill="none" stroke="{GOLD}" stroke-width="1.6" stroke-dasharray="3 3"/>'
        if n:
            inner += number_svg(cx, cy, n)
        if stars:
            inner += stars_svg(cx, cy - RADIUS - 9, stars)
    cls = 'chip' + (' dark' if dark else '')
    w = box * size
    svg = f'<svg class="{cls}" width="{w:.0f}" height="{w:.0f}" viewBox="0 0 {box} {box}">'
    if touch:
        svg += f'<rect x="{cx - 28}" y="{cy - 28}" width="56" height="56" fill="none" stroke="#e0bc6a" stroke-dasharray="3 2" stroke-width="1"/>'
    svg += inner + '</svg>'
    return uniq(svg, tag)


def game_frame(img, scroll, selected=10, status='Disponible · sin victorias todavía', view_w=1240, w=1280, h=720, sub=''):
    name = f'{selected + 1} · {LEVEL_NAMES[selected + 1]}'
    return (f'<div class="frame" style="width:{w}px;height:{h}px">'
            f'<div class="title">Campaña · Atlas de Cántaro</div><div class="sub">{sub}</div>'
            f'<div class="view" style="width:{view_w}px"><img src="{img}" style="left:{-scroll}px"></div>'
            f'<div class="panel" style="width:{view_w}px"><b>{name}</b><span>{status}</span><i>Jugar</i></div>'
            f'<div class="foot">Maqueta T469 (no es el juego) · lienzo 1413,6×380 px lógicos · desplazamiento {scroll:.0f} px</div></div>')


def page(title, body, extra_css=''):
    return (f'<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
            f'<title>{title}</title><style>{CSS}{extra_css}</style></head><body>{body}</body></html>')


def scaled(inner, sw, sh, k):
    return f'<div style="width:{sw * k:.0f}px;height:{sh * k:.0f}px;overflow:hidden"><div style="width:{sw}px;height:{sh}px;transform:scale({k});transform-origin:0 0">{inner}</div></div>'


def write_frames():
    """Paginas de un solo marco para sacar las capturas."""
    img = f'../escenas/atlas_{REC}_completo.svg'
    sub = 'Insignias propuestas · estado de ejemplo (no es un guardado real)'
    end_scroll = CANVAS_W - 1240
    F = ART / 'frames'
    write(F / 'pc1280_inicio.html', page('pc1280', game_frame(img, 0, sub=sub), 'body{margin:0}'))
    write(F / 'pc1280_final.html', page('pc1280f', game_frame(img, end_scroll, sub=sub), 'body{margin:0}'))
    write(F / 'pc1920.html', page('pc1920', scaled(game_frame(img, 0, sub=sub), 1280, 720, 1.5), 'body{margin:0}'))
    wide = game_frame(img, 0, view_w=1666, w=1706, sub=sub + ' · 21:9 simulado: 2560×1080 a 1706×720 lógicos')
    write(F / 'pc2560.html', page('pc2560', wide, 'body{margin:0}'))
    # celular simulado: 844x390 pt de pantalla a 2x; el motor (stretch canvas_items, aspect keep) escala 1280x720 a 0,5417 con barras
    k = min(844 / 1280, 390 / 720)
    for nm, sc in (('inicio', 0), ('final', end_scroll)):
        ph = (f'<div class="ph" style="width:1688px;height:780px"><div class="stage" style="left:{(1688 - 1280 * k * 2) / 2:.1f}px;top:{(780 - 720 * k * 2) / 2:.1f}px;'
              f'transform:scale({k * 2:.4f})">{game_frame(img, sc, sub="Celular simulado")}</div></div>')
        write(F / f'celular_{nm}.html', page('cel', ph, 'body{margin:0}'))


MARK = []


def build_index():
    L = []
    L.append('<main><h1>T469 · Muestra de insignias de conquista y zonas ocultas del atlas</h1>'
             '<p class="mut">Propuesta de arte para que Lucas apruebe. <b>No integrada en runtime</b> y <b>no aprobada</b>. Sobre el atlas actual (M76/T471), los postes de T475 (carmesí y negro = rebelde; turquesa y crema = jugador) y la UI vigente de <code>main</code>. '
             'El celular es <b>simulado</b> (ventana del navegador escalada como lo hace el motor); no hay teléfono real. Fuentes SVG editables en <code>insignias/</code>, <code>escenas/</code> y <code>fuentes/</code>; regenerar con <code>python3 -I build.py</code>.</p>')
    # 1 catalogo
    L.append('<h2>1 · Insignias: rebelde, partido y jugador (RF-695, D-203)</h2><p>Tres variantes de cada una, al radio del juego (19,5 px). Rebelde sin victoria = carmesí con aro negro; partido (1–2 estrellas) = mitad rebelde / mitad jugador; jugador (3 estrellas) = turquesa con aro crema. '
             'La forma también cambia (V2: aro dentado rebelde vs. tachas del jugador) para no depender solo del color. Sin emblema: no se inventa ninguno canónico (D-203). «Disponible» = rebelde con un halo dorado punteado (mi propuesta; RF-695 dice solo «fondo rebelde sin victoria»).</p>')
    for v, nm in VARIANTS.items():
        L.append(f'<h3>{v.upper()} · {nm}{"  — recomendada" if v == REC else ""}</h3><div class="row">')
        cells = [('candado', None, 0, {}, 'bloqueado (actual)'), ('rebelde', 11, 0, {'halo': True}, 'disponible'), ('rebelde', 7, 0, {}, 'rebelde'),
                 ('partido', 1, 1, {}, 'partido 1★'), ('partido', 10, 2, {}, 'partido 2★'), ('jugador', 15, 3, {}, 'jugador 3★'),
                 ('rebelde', 4, 0, {'sel': True, 'halo': True}, 'seleccionado'), ('partido', 8, 2, {'sel': True, 'focus': True}, 'selección + foco'),
                 ('jugador', 12, 3, {'focus': True}, 'foco')]
        for kind, n, st, kw, lab in cells:
            L.append(f'<div class="cell">{chip(v, kind, n, st, 1.5, **kw)}{lab}</div>')
        L.append('</div>')
    MARK.append(len(L))
    # 2 numeros
    L.append('<h2>2 · Números 1 a 15 sin cero inicial, con el área táctil de 56 px (RF-690)</h2><p>Escala 1× de PC (1280×720). El cuadro punteado mide 56×56 px lógicos y las insignias quedan dentro. Número en crema con contorno oscuro, 15 px (14 px de dos cifras); se lee sobre carmesí, turquesa y sobre la costura del partido.</p>')
    for v, nm in VARIANTS.items():
        L.append(f'<h3>{v.upper()} · {nm}</h3>')
        for kind, st in (('rebelde', 0), ('partido', 2), ('jugador', 3)):
            L.append('<div class="row" style="gap:0">' + ''.join(chip(v, kind, n, st, 1.0, dark=True, touch=True) for n in range(1, 16)) + '</div>')
    L.append('<p class="mut">Las estrellas (hasta tres, radio 6) quedan encima de la insignia; con dos cifras no tocan el número. Ver también las capturas a 1920×1080 y celular simulado más abajo.</p>')
    MARK.append(len(L))
    # 3 atlas
    L.append('<h2>3 · Las tres variantes sobre el atlas actual (lienzo del juego, desplazable)</h2><p>Lienzo real del selector: 1413,6×380 px lógicos (atlas ×1,14 recortado desde y=160). Desborda 173,6 px la vista de 1240 px: se desplaza en horizontal (arrastrá). Estado de ejemplo: 1–3 con 3★, 4 con 2★, 5 y 6 con 3★, 7 con 1★, 8 con 3★, 9 con 2★, 10 con 3★, 11 disponible (seleccionado, con foco), 12–15 bloqueados. Es un ejemplo, no un guardado.</p><div class="mapas">')
    for v, nm in VARIANTS.items():
        L.append(f'<h3>{v.upper()} · {nm}</h3><div class="scroller"><img src="escenas/atlas_{v}_completo.svg" width="{CANVAS_W:.0f}" height="380"></div>')
    L.append('</div>')
    MARK.append(len(L))
    # 4 PC / celular
    L.append('<h2>4 · PC y celular simulado, con y sin desborde</h2><p>Variante recomendada. Capturas de Firefox headless sobre estas mismas páginas (<code>frames/</code>); el ancho no se fuerza: 1,14 es el mínimo que mantiene las áreas de 56 px sin pisarse (ya fijado en T471).</p>')
    for f, cap in (('T469-pc-1280x720-inicio', 'PC 1280×720, desplazamiento 0 (con desborde)'), ('T469-pc-1280x720-final', 'PC 1280×720, desplazamiento al final'),
                   ('T469-pc-1920x1080', 'PC 1920×1080 (mismo diseño lógico ×1,5)'), ('T469-pc-2560x1080-sin-desborde', 'Ultrapanorámico simulado (1706×720 lógicos): cabe entero, sin desborde'),
                   ('T469-celular-sim-inicio', 'Celular simulado 844×390 pt a 2×, desplazamiento 0'), ('T469-celular-sim-final', 'Celular simulado, desplazamiento al final')):
        L.append(f'<h3>{cap}</h3><img src="../../Capturas/{f}.png" style="max-width:100%;border:1px solid #333">')
    MARK.append(len(L))
    # 5 zonas
    L.append('<h2>5 · Zona oculta del atlas: la «máscara gris» para T488 (RF-709, RF-710, D-209)</h2><p>Tres estados: solo A (niveles 1–5), A+B (1–10) y A+B+C (todo). La zona sin descubrir es terreno gris, <b>sin número, candado, estrellas, ruta, rótulo ni animación</b>; la ruta se corta en el último nivel descubierto. Dos grises: '
             '<b>G1 niebla pizarra</b> (liso, borde difuso, no deja ver biomas ni relieve) y <b>G2 relieve desvaído</b> (el atlas en grises con borde nítido; se adivina el relieve y los símbolos de ruinas, sin color de bioma). Ejemplos de progreso (maqueta): A = 1★3, 2★2, 3★1, 4 disponible, 5 bloqueado; A+B = el 6 recién disponible y 7–10 bloqueados (descubrir no abre).</p>')
    for g, desc in GRAYS.items():
        L.append(f'<h3>{g} · {desc}</h3><div class="mapas">')
        for key in STATES:
            L.append(f'<div class="cell" style="text-align:left">Estado {key}</div><div class="scroller"><img src="escenas/zonas_{g}_{key}.svg" width="{CANVAS_W:.0f}" height="380"></div>')
        L.append('</div>')
    L.append('<h3>¿Se confunde el gris con el candado?</h3><p>Se midió sobre las capturas (ver <code>index.md</code>, tabla «gris vs. candado»): el candado es un disco chico de 36 px, oscuro (#414b4b) con aro negro y candadito claro; el gris es un terreno extenso, más claro, sin contorno circular ni pictograma, y ningún candado cae sobre él (solo en zonas descubiertas). Captura: <img src="../../Capturas/T469-gris-vs-candado.png" style="vertical-align:middle;max-width:100%"></p>')
    MARK.append(len(L))
    L.append('<h2>6 · Recomendación por pieza</h2><p>Ver tabla en <code>index.md</code>. Las piezas siguen sin aprobación de Lucas.</p></main>')
    write(ART / 'index.html', page('T469 · Insignias y zonas ocultas', ''.join(L)))
    head = L[0]
    secs = {'catalogo': L[1:MARK[0]], 'numeros': L[MARK[0]:MARK[1]], 'variantes': L[MARK[1]:MARK[2]]}
    z = L[MARK[3]:MARK[4]]
    for name, part in secs.items():
        write(ART / f'hoja_{name}.html', page('T469 ' + name, '<main>' + ''.join(part) + '</main>', '.scroller{width:1416px}'))
    write(ART / 'hoja_zonas.html', page('T469 zonas', '<main>' + ''.join(z[:1]) + ''.join(z[1:]) + '</main>', '.scroller{width:1416px}'))
    write(ART / 'hoja_gris_candado.html', page('T469 gris vs candado', gris_vs_candado()))


def gris_vs_candado():
    # recortes ampliados x2 de la frontera A|B (estado A) y B|C (estado AB) para G1 y G2, junto a un candado
    out = '<main><h1>Gris sin descubrir vs. candado de LOCKED</h1><p class="mut">Recortes ×2 de las escenas. En cada fila: terreno oculto, candado actual (disco #414b4b con aro y candadito) y borde de la zona.</p>'
    for g in GRAYS:
        out += f'<h3>{g}</h3><div class="row">'
        for key, (x, y, w, h) in (('A', (430, 90, 330, 250)), ('AB', (780, 60, 330, 280))):
            out += (f'<div style="width:{w * 2}px;height:{h * 2}px;overflow:hidden;position:relative;border:1px solid #444">'
                    f'<img src="escenas/zonas_{g}_{key}.svg" width="{CANVAS_W * 2:.0f}" style="position:absolute;left:{-x * 2}px;top:{-y * 2}px"></div>')
        out += '</div>'
    return out + '</main>'


def main2():
    main()
    write_frames()
    build_index()


if __name__ == '__main__':
    main2()
