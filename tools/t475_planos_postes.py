#!/usr/bin/env python3
"""T475 · Paquete de propuesta de postes de campaña (RF-696). NO integra nada al juego.

Lee `data/levels/level_01..15.json` (solo lectura), revalida cada candidato de la ficha
`specs/tareas/T475-postes-quince-niveles.md`, dibuja un plano rotulado por nivel y escribe
el índice `art/t475-paquete-postes/index.md` con la comparación estructural «antes» (hashes).

Uso (desde la raíz del proyecto, requiere Pillow):
    python3 tools/t475_planos_postes.py            # regenera planos, contexto, validacion.json e index.md
    python3 tools/t475_planos_postes.py --verify   # compara los JSON de nivel con los hashes del índice
                                                   # (sale con código 1 si algún mapa jugable cambió)

Los planos NO son capturas del motor: son un dibujo de la grilla leída de los JSON. El arte del poste
(assets/sprites/map/rendered/banner_post_enemy.png) se pega solo como referencia de tamaño.
La clasificación de letras replica scripts/logic/map_grid.gd y scripts/logic/level_file.gd.
"""
import hashlib
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
LEVELS = ROOT / "data" / "levels"
OUT = ROOT / "art" / "t475-paquete-postes"
POST_ART = ROOT / "assets" / "sprites" / "map" / "rendered" / "banner_post_enemy.png"
DATE = "2026-10-25"
BASE = "9ce9e18"  # origin/main sobre la que se validó

GROUND_DRAWINGS = ("agua", "hielo", "lava", "barro")
SIGNAL_DRAWINGS = ("roca_marcada", "simbolo_ruina", "campamento_vacio", "sendero", "herramienta")

# Candidatos. estado: "propuesta" (a revisar) o "descartado" (queda anotado, no se borra el historial).
# nota: riesgo y recomendación, escritos tras revisar vecinos y márgenes.
C = [
    (1, (13, 5), "propuesta", "Ficha", "Bajo. Pegada a la estatua (12,5), que no se pisa, y bajo el camino (13,4).", "Aprobar tras ver captura del motor."),
    (2, (1, 4), "propuesta", "Ficha", "Alto. La casilla ES la columna `s`: el poste se superpondría a un dibujo existente. Margen 1. Es la única casilla no agua y no construible del mapa; no hay reemplazo sin tocar `data/`.", "Lucas decide: superponer a la columna o aprobar aparte un ajuste de datos. No avanzar sin OK."),
    (3, (15, 6), "propuesta", "Ficha", "Bajo-medio. Cubre las flores (decoración); al este está el camino (17,6) a dos casillas.", "Aprobar tras captura (revisar que las flores no asomen)."),
    (4, (19, 4), "propuesta", "Ficha", "Medio. Margen de borde 0 (última columna), camino pegado al oeste (18,4) y sin alternativa en datos: las únicas otras bloqueadas son el tronco (0,5), también en el borde, y el agua. LevelDecor dibuja los objetos dentro de su casilla, así que en principio no se corta, pero falta verlo en el motor.", "Lucas decide con captura del motor; si se corta, ajuste de datos aparte."),
    (5, (17, 3), "propuesta", "Ficha", "Bajo. Flores aisladas al este, a 4 casillas del camino (13,3).", "Aprobar tras captura."),
    (6, (18, 1), "propuesta", "Ficha", "Bajo. Ya es el poste `p` (`poste_cintas`); solo cambia la regla de estrellas (RF-696), no la posición.", "Conservar la posición; aprobar."),
    (7, (17, 5), "propuesta", "Ficha", "Bajo-medio. Bloqueada `X` del este; el árbol removible (15,6) y la entrada B (19,7) quedan a 2 casillas, ninguno pisado.", "Aprobar tras captura."),
    (8, (0, 4), "propuesta", "Ficha", "Medio-alto. Es el símbolo de ruina `s` (señal canónica) y está en el borde (margen 0). Las únicas casillas bloqueadas permanentes del mapa son las dos señales `s`, ambas en el borde: no hay reemplazo sin tocar `data/`.", "Lucas decide si el poste puede ir sobre la señal; si no, ajuste de datos aparte."),
    (9, (0, 4), "propuesta", "Ficha", "Medio-alto. Igual que el nivel 8: señal `s` en el borde (margen 0); la otra `s` (6,0) también es borde. Sin reemplazo posible sin tocar `data/`.", "Lucas decide; igual que nivel 8."),
    (10, (22, 2), "propuesta", "Ficha", "Bajo. Bloqueada `X` junto al camino (21,2); la mina (10,2) y las ruinas quedan lejos.", "Aprobar tras captura."),
    (11, (2, 1), "propuesta", "Ficha", "Bajo. `X` bajo el camino (2,0); la entrada A (0,0) queda a 2 casillas y la roca marcada (1,2) en diagonal, sin pisarla.", "Aprobar tras captura."),
    (11, (20, 8), "propuesta", "Ficha", "Bajo-medio. `X` rodeada de `X` y pasto; la roca removible (19,9) está en diagonal contigua, sin pisarla.", "Aprobar tras captura."),
    (12, (5, 0), "descartado", "Ficha", "Margen de borde 0 (fila superior) y roca marcada `h` en (4,0) pegada: el poste competiría con la señal y podría cortarse arriba.", "Descartado: reemplazado por (5,2)."),
    (12, (5, 2), "propuesta", "Reemplazo de (5,0)", "Bajo. `X` verificada, margen 2, sin señales ni removibles en las 8 vecinas; la roca marcada (4,0) queda a 2 casillas.", "Aprobar tras captura."),
    (12, (24, 9), "propuesta", "Ficha", "Bajo-medio. `X` sobre el camino (24,10); la salida (25,10) queda en diagonal; margen 1 por el este y por abajo.", "Aprobar tras captura (revisar cercanía a la salida)."),
    (13, (24, 0), "descartado", "Ficha", "Margen de borde 0 (fila superior): el dibujo podría cortarse.", "Descartado: reemplazado por (23, 2)."),
    (13, (23, 2), "propuesta", "Reemplazo de (24,0)", "Bajo. `X` verificada, margen 2, solo `X`, pasto y camino alrededor; sin señales ni removibles cerca.", "Aprobar tras captura."),
    (13, (24, 11), "descartado", "Ficha", "Margen de borde 0 (fila inferior): el dibujo podría cortarse.", "Descartado: reemplazado por (24, 9)."),
    (13, (24, 9), "propuesta", "Reemplazo de (24,11)", "Bajo. `X` verificada, margen 1 por el este y 2 por abajo, vecinas solo `X` y pasto.", "Aprobar tras captura."),
    (14, (1, 1), "propuesta", "Ficha", "Bajo. `X` en el noroeste; el símbolo `s` (8,1) y los campamentos quedan lejos.", "Aprobar tras captura."),
    (14, (24, 10), "propuesta", "Ficha", "Medio. `X` con margen 1; el camino queda al sur (24,11), el símbolo de ruina `s` (25,9) en diagonal contigua y la entrada B (25,11) en diagonal: podría competir con la señal y la entrada.", "Aprobar tras captura (revisar encuadre sudeste)."),
    (15, (5, 1), "propuesta", "Ficha", "Bajo. `X` del noroeste entre dos tramos de camino (5,0) y (6,1); central y abastecimiento lejos.", "Aprobar tras captura."),
    (15, (23, 10), "propuesta", "Ficha", "Bajo. `X` del sudeste bajo el camino (23,9); la salida (25,9) y el poste de abastecimiento (21,11) quedan a 2 casillas y la señal `s` (19,10) a 4.", "Aprobar tras captura (revisar cercanía al poste de abastecimiento)."),
]


def load(n):
    return json.loads((LEVELS / f"level_{n:02d}.json").read_text(encoding="utf-8"))


def classify(d, ch):
    """Devuelve (tipo, dibujo) replicando MapGrid._read."""
    if ch == ".":
        return "construible", ""
    if ch == "#":
        return "camino", ""
    if ch == "X":
        return "bloqueada", ""
    if ch == "S":
        return "salida", ""
    if ch in "ABCDEFGH":
        return "entrada", ""
    e = d["leyenda"][ch]
    draw = e.get("dibujo", "")
    if "removible" in e:
        return "removible", e["removible"].get("clase", "")
    if "extraccion" in e:
        return "extraccion", e["extraccion"].get("clase", "")
    if e.get("construible"):
        return "construible", draw
    if draw in GROUND_DRAWINGS:
        return "suelo:" + draw, draw
    if draw in SIGNAL_DRAWINGS:
        return "senal", draw
    return "decoracion", draw


def hashes(n):
    raw = (LEVELS / f"level_{n:02d}.json").read_bytes()
    d = json.loads(raw)
    grid = json.dumps({"mapa": d["mapa"], "leyenda": d["leyenda"]}, sort_keys=True, ensure_ascii=False)
    return hashlib.sha256(raw).hexdigest(), hashlib.sha256(grid.encode()).hexdigest()


def validate(n, cell):
    d = load(n)
    m = d["mapa"]
    h, w = len(m), len(m[0])
    x, y = cell
    r = {"existe": 0 <= x < w and 0 <= y < h}
    if not r["existe"]:
        r["ok"] = False
        return r
    ch = m[y][x]
    kind, draw = classify(d, ch)
    r.update(letra=ch, tipo=kind, dibujo=draw)
    r["permanente_no_construible"] = kind in ("bloqueada", "decoracion", "senal")
    r["margen_borde"] = min(x, y, w - 1 - x, h - 1 - y)
    names = {(-1, 0): "O", (1, 0): "E", (0, -1): "N", (0, 1): "S"}
    v4 = {}
    for (dx, dy), nm in names.items():
        xx, yy = x + dx, y + dy
        if 0 <= xx < w and 0 <= yy < h:
            k, dr = classify(d, m[yy][xx])
            v4[nm] = k + (f":{dr}" if dr else "")
        else:
            v4[nm] = "fuera del mapa"
    r["vecinas4"] = v4
    near = []
    for yy in range(max(0, y - 2), min(h, y + 3)):
        for xx in range(max(0, x - 2), min(w, x + 3)):
            if (xx, yy) == (x, y):
                continue
            k, dr = classify(d, m[yy][xx])
            if k in ("senal", "removible", "extraccion", "entrada", "salida") or k.startswith("suelo"):
                near.append(f"{k}{':' + dr if dr else ''} ({xx},{yy})")
    r["cercanas_2"] = near
    r["ok"] = r["permanente_no_construible"] and not kind.startswith("suelo")
    return r


# ---------- dibujo ----------
def font(size, bold=False):
    for p in ("/usr/share/fonts/truetype/dejavu/DejaVuSans%s.ttf" % ("-Bold" if bold else ""),):
        if Path(p).exists():
            return ImageFont.truetype(p, size)
    return ImageFont.load_default(size)


COL = {
    "construible": (172, 214, 130), "camino": (214, 186, 130), "bloqueada": (92, 92, 100),
    "entrada": (70, 160, 90), "salida": (200, 70, 70), "removible": (230, 150, 60),
    "extraccion": (150, 100, 190), "decoracion": (120, 140, 110), "senal": (240, 220, 80),
    "suelo": (80, 140, 205),
}
ABBR = {"flores": "flo", "estatua": "est", "columna": "col", "tronco": "tro", "helecho": "hel",
        "poste_cintas": "POS", "simbolo_ruina": "rui", "roca_marcada": "rm", "campamento_vacio": "cam",
        "agua": "~", "hielo": "hie", "supply_depot": "dep", "supply_line_pole": "lin", "supply_cart": "car",
        "central_1": "C1", "central_2": "C2", "central_3": "C3", "central_4": "C4", "columna ": "col"}


def cell_color(kind):
    return COL["suelo"] if kind.startswith("suelo") else COL[kind]


def draw_cell(dr, d, ch, x0, y0, cs, f):
    kind, draw = classify(d, ch)
    dr.rectangle([x0, y0, x0 + cs - 1, y0 + cs - 1], fill=cell_color(kind), outline=(40, 40, 40))
    if kind == "bloqueada":
        dr.line([x0 + 3, y0 + 3, x0 + cs - 4, y0 + cs - 4], fill=(60, 60, 66))
        dr.line([x0 + cs - 4, y0 + 3, x0 + 3, y0 + cs - 4], fill=(60, 60, 66))
    elif kind in ("entrada", "salida"):
        dr.text((x0 + cs / 2, y0 + cs / 2), ch, fill="white", font=f, anchor="mm")
    elif kind in ("removible", "extraccion"):
        dr.text((x0 + cs / 2, y0 + cs / 2), ch.upper() if kind == "extraccion" else ch, fill="black", font=f, anchor="mm")
    elif kind in ("decoracion", "senal", "suelo:agua", "suelo:hielo"):
        dr.text((x0 + cs / 2, y0 + cs / 2), ABBR.get(draw, draw[:3]), fill="black", font=f, anchor="mm")


def post_icon(size):
    im = Image.open(POST_ART).convert("RGBA").resize((size, size), Image.LANCZOS)
    return im


def mark_candidate(img, dr, x0, y0, cs, label, estado, f, big=False):
    if estado == "propuesta":
        dr.rectangle([x0 - 2, y0 - 2, x0 + cs + 1, y0 + cs + 1], outline=(255, 0, 200), width=4 if big else 3)
        img.alpha_composite(post_icon(cs), (x0, y0)) if img.mode == "RGBA" else img.paste(post_icon(cs), (x0, y0), post_icon(cs))
    else:
        dr.rectangle([x0 - 2, y0 - 2, x0 + cs + 1, y0 + cs + 1], outline=(110, 110, 110), width=3)
        dr.line([x0, y0, x0 + cs, y0 + cs], fill=(220, 0, 0), width=3)
        dr.line([x0 + cs, y0, x0, y0 + cs], fill=(220, 0, 0), width=3)
    tw = dr.textlength(label, font=f)
    ty = y0 - 17 if y0 > 40 else y0 + cs + 2
    col = (255, 0, 200) if estado == "propuesta" else (200, 0, 0)
    dr.rectangle([x0 + cs / 2 - tw / 2 - 2, ty, x0 + cs / 2 + tw / 2 + 2, ty + 15], fill="white", outline=col)
    dr.text((x0 + cs / 2, ty + 8), label, fill=col, font=f, anchor="mm")


def render_plan(n, cands):
    d = load(n)
    m = d["mapa"]
    h, w = len(m), len(m[0])
    W, H = 1280, 720
    top, left = 92, 36
    cs = min((W - left - 30) // w, (H - top - 120) // h, 46)
    img = Image.new("RGBA", (W, H), (248, 248, 244, 255))
    dr = ImageDraw.Draw(img)
    f, fs, fb = font(12), font(11), font(20, True)
    dr.text((20, 12), f"Nivel {n} · {d['nombre']}  ({w}×{h})", fill="black", font=fb)
    dr.rectangle([20, 44, 520, 70], fill=(255, 235, 245), outline=(255, 0, 200), width=2)
    dr.text((30, 57), "PROPUESTA NO APROBADA · T475 · base " + BASE, fill=(190, 0, 150), font=font(14, True), anchor="lm")
    dr.text((540, 57), "Plano de la grilla leída de data/levels (no es captura del motor)", fill=(80, 80, 80), font=f, anchor="lm")
    for x in range(w):
        dr.text((left + x * cs + cs / 2, top - 9), str(x), fill="black", font=fs, anchor="mm")
    for y in range(h):
        dr.text((left - 12, top + y * cs + cs / 2), str(y), fill="black", font=fs, anchor="mm")
    for y in range(h):
        for x in range(w):
            draw_cell(dr, d, m[y][x], left + x * cs, top + y * cs, cs, fs)
    for k, (cell, estado, origen) in enumerate(cands):
        pre = "P" if estado == "propuesta" else "DESC"
        mark_candidate(img, dr, left + cell[0] * cs, top + cell[1] * cs, cs, f"{pre} ({cell[0]},{cell[1]})", estado, fs)
    # leyenda
    ly = top + h * cs + 14
    items = [("construible", "construible"), ("camino", "camino #"), ("bloqueada", "bloqueada X"),
             ("entrada", "entrada A.."), ("salida", "salida S"), ("removible", "removible"),
             ("extraccion", "extracción"), ("decoracion", "decoración"), ("senal", "señal"), ("suelo", "agua/hielo")]
    lx = left
    for key, txt in items:
        dr.rectangle([lx, ly, lx + 16, ly + 16], fill=COL[key], outline=(40, 40, 40))
        dr.text((lx + 22, ly + 8), txt, fill="black", font=f, anchor="lm")
        lx += 22 + int(dr.textlength(txt, font=f)) + 18
    dr.rectangle([left, ly + 30, left + 16, ly + 46], outline=(255, 0, 200), width=3)
    dr.text((left + 22, ly + 38), "poste propuesto (sprite del poste enemigo existente pegado solo como referencia de tamaño)", fill="black", font=f, anchor="lm")
    dr.line([left + 600, ly + 30, left + 616, ly + 46], fill=(220, 0, 0), width=3)
    dr.line([left + 616, ly + 30, left + 600, ly + 46], fill=(220, 0, 0), width=3)
    dr.text((left + 622, ly + 38), "candidato DESCARTADO (queda anotado)", fill="black", font=f, anchor="lm")
    dr.text((left, ly + 62), "Coordenadas (x, y) desde 0, origen arriba a la izquierda. Letras de las casillas: ver índice.", fill=(80, 80, 80), font=f, anchor="lm")
    img.convert("RGB").save(OUT / f"nivel_{n:02d}_plano.png", optimize=True)


def render_context(n, cands):
    d = load(n)
    m = d["mapa"]
    h, w = len(m), len(m[0])
    cs = 64
    rx, ry = 4, 3  # 9×7 casillas
    live = [c for c in cands if c[1] == "propuesta"] or cands
    panels = []
    for cell, estado, origen in live:
        x0c, y0c = cell[0] - rx, cell[1] - ry
        pw, ph = 2 * rx + 1, 2 * ry + 1
        p = Image.new("RGBA", (pw * cs, ph * cs + 28), (248, 248, 244, 255))
        pd = ImageDraw.Draw(p)
        f, fs = font(16), font(13)
        pd.text((6, 4), f"Contexto de ({cell[0]},{cell[1]}) · PROPUESTA NO APROBADA", fill=(190, 0, 150), font=font(14, True))
        for j in range(ph):
            for i in range(pw):
                x, y = x0c + i, y0c + j
                px, py = i * cs, j * cs + 28
                if 0 <= x < w and 0 <= y < h:
                    draw_cell(pd, d, m[y][x], px, py, cs, f)
                    pd.text((px + 3, py + 2), f"{x},{y}", fill=(30, 30, 30), font=font(9))
                else:
                    pd.rectangle([px, py, px + cs - 1, py + cs - 1], fill=(30, 30, 34))
                    pd.text((px + cs / 2, py + cs / 2), "fuera", fill=(150, 150, 150), font=font(11), anchor="mm")
        mark_candidate(p, pd, rx * cs, ry * cs + 28, cs, f"({cell[0]},{cell[1]})", "propuesta", fs, big=True)
        panels.append(p)
    total_w = sum(p.width for p in panels) + 10 * (len(panels) - 1)
    out = Image.new("RGBA", (total_w, max(p.height for p in panels)), (248, 248, 244, 255))
    x = 0
    for p in panels:
        out.paste(p, (x, 0))
        x += p.width + 10
    out.convert("RGB").save(OUT / f"nivel_{n:02d}_contexto.png", optimize=True)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    idx = OUT / "index.md"
    if "--verify" in sys.argv:
        text = idx.read_text(encoding="utf-8")
        bad = 0
        for n in range(1, 16):
            fh, gh = hashes(n)
            ok = fh in text and gh in text
            print(f"nivel {n:02d}: {'igual' if ok else 'CAMBIÓ'}")
            bad += not ok
        sys.exit(1 if bad else 0)

    by_level = {}
    for n, cell, estado, origen, riesgo, rec in C:
        by_level.setdefault(n, []).append((cell, estado, origen, riesgo, rec))
    results = {}
    for n in range(1, 16):
        rows = by_level[n]
        render_plan(n, [(c, e, o) for c, e, o, _, _ in rows])
        render_context(n, [(c, e, o) for c, e, o, _, _ in rows])
        results[n] = [{"celda": list(c), "estado": e, "origen": o, **validate(n, c)} for c, e, o, _, _ in rows]
    (OUT / "validacion.json").write_text(json.dumps(results, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

    L = []
    L.append("# T475 · Paquete de propuesta de postes de campaña\n")
    L.append(f"**PROPUESTA NO APROBADA.** Generado el {DATE} por `tools/t475_planos_postes.py` sobre `origin/main` {BASE}. "
             "No integra nada al juego: no toca `data/`, `game.gd`, `LevelDecor` ni código de runtime. "
             "Las 15 aprobaciones de Lucas (RF-696, D-203) siguen **pendientes**.\n")
    L.append("## Cómo leerlo\n")
    L.append("- Coordenadas `(x, y)` desde 0, origen arriba a la izquierda.\n"
             "- Cada nivel tiene `nivel_NN_plano.png` (grilla completa con coordenadas, camino, entradas/salida, construibles, removibles, extracciones, decoración y señales) y `nivel_NN_contexto.png` (9×7 casillas ampliadas alrededor de cada candidato).\n"
             "- Son **planos de la grilla leída de los JSON**, no capturas del motor. El sprite del poste enemigo existente se pega solo como referencia de tamaño; la integración real puede verse distinta.\n"
             "- Clasificación (replica `MapGrid`/`LevelFile`): `bloqueada` = `X`; `decoración`/`señal` = letra de leyenda con `dibujo` y sin `construible`/`removible`/`extraccion` (MapGrid la trata como bloqueada); `señal` = `roca_marcada`, `simbolo_ruina`, `campamento_vacio`, `sendero`, `herramienta`.\n"
             "- «Margen» = casillas hasta el borde más cercano del mapa (0 = casilla de borde). `LevelDecor` dibuja los objetos dentro de su casilla (`level_decor.gd`, líneas 75-77), así que un poste de tamaño de casilla no se corta en el borde; igual hace falta confirmarlo en una captura del motor.\n"
             "- Los candidatos descartados quedan anotados (no se borra historial); su reemplazo está verificado con las mismas comprobaciones.\n")
    L.append("## Resumen\n")
    L.append("- 20 candidatos vigentes (1 por nivel en 1–10, 2 en 11–15). Los 20 de la ficha existen y son permanentemente no construibles; ninguno cae en agua, hielo, removible, extracción, camino, entrada, salida o casilla libre.\n"
             "- **3 candidatos cambiaron** por margen de borde 0 con reemplazo verificado: nivel 12 `(5,0)` → `(5,2)`; nivel 13 `(24,0)` → `(23,2)` y `(24,11)` → `(24,9)`.\n"
             "- **4 candidatos sin reemplazo posible dentro de los datos**: niveles 4, 8 y 9 (margen de borde 0) y nivel 2 (ocuparía la columna existente). Se mantienen marcados como riesgo y requieren decisión de Lucas; cambiar la grilla exigiría su OK explícito y queda fuera de esta tarea.\n")
    L.append("## Por nivel\n")
    v = {n: results[n] for n in results}
    for n in range(1, 16):
        d = load(n)
        L.append(f"### Nivel {n} · {d['nombre']} ({len(d['mapa'][0])}×{len(d['mapa'])})\n")
        L.append(f"![plano](nivel_{n:02d}_plano.png)  \n![contexto](nivel_{n:02d}_contexto.png)\n")
        L.append("| Candidato | Estado | Origen | Tipo de casilla | Vecinas (N/E/S/O) | Margen | Cercano (≤2) | Riesgo | Recomendación | OK de Lucas |")
        L.append("|---|---|---|---|---|---|---|---|---|---|")
        for (cell, estado, origen, riesgo, rec), res in zip(by_level[n], v[n]):
            tipo = f"`{res['letra']}` {res['tipo']}" + (f" ({res['dibujo']})" if res["dibujo"] else "")
            vec = ", ".join(f"{k}: {res['vecinas4'][k]}" for k in "NESO" if k in res["vecinas4"])
            cer = "; ".join(res["cercanas_2"]) or "—"
            valid = "" if res["ok"] else " **FALLA**"
            ok_cell = "Pendiente (fecha: —, ref: —)" if estado == "propuesta" else "No aplica (descartado)"
            L.append(f"| `({cell[0]}, {cell[1]})` | {estado}{valid} | {origen} | {tipo} | {vec} | {res['margen_borde']} | {cer} | {riesgo} | {rec} | {ok_cell} |")
        L.append("")
    L.append("## Comparación estructural «antes»\n")
    L.append(f"Hash SHA-256 de cada `data/levels/level_NN.json` en `origin/main` {BASE}. «Grilla» es el hash de `mapa` + `leyenda` (JSON canónico, claves ordenadas). "
             "Para probar después que el mapa jugable no cambió: `python3 tools/t475_planos_postes.py --verify` (debe decir «igual» en los 15).\n")
    L.append("| Nivel | JSON completo (SHA-256) | Grilla + leyenda (SHA-256) |")
    L.append("|---|---|---|")
    for n in range(1, 16):
        fh, gh = hashes(n)
        L.append(f"| {n:02d} | `{fh}` | `{gh}` |")
    L.append("")
    L.append("## Límites\n")
    L.append("- No hay capturas del motor ni prueba en partida: los planos salen de los JSON. Falta ver cada poste dentro del juego (estados 0/2/3 estrellas, encuadre y zoom) antes de aprobar.\n"
             "- No se verificó rendimiento, teléfono ni balance. No hay ninguna aprobación registrada: la columna «OK de Lucas» queda en Pendiente para los 20 candidatos vigentes.\n")
    (OUT / "index.md").write_text("\n".join(L) + "\n", encoding="utf-8")
    print("listo:", OUT)


if __name__ == "__main__":
    main()
