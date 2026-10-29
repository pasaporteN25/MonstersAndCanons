#!/usr/bin/env python3
"""T533: genera el inventario de textos visibles (specs/tareas/informes/T533-inventario-textos.md).

Uso, desde la raíz del proyecto:  python3 tools/localization_inventory.py [--salida ruta]
Solo LEE el proyecto. Es una heurística: marca candidatos para que Lucas y T534 los revisen.

T534: con `--auditoria [ruta]` NO regenera el inventario; hace la auditoría final de lo que sigue en español fuera del catálogo
(`data/i18n/`): descarta los textos que ya están en el catálogo español y las líneas que ya llaman a `Localization`, clasifica el
resto (Lore, mensajes de validación de datos para desarrollo, nombres técnicos) y escribe el informe en
`specs/tareas/informes/T534-auditoria-textos.md` (o en `ruta`). Los números que imprime son los del informe.
"""
import json
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP_DIRS = {"addons", "tests", ".git", ".godot", "build", "Capturas", "docs", "art", ".claude", "tools"}

STR_RE = re.compile(r'"((?:[^"\\\n]|\\.)*)"')
HAS_LETTER = re.compile(r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]")
ID_LIKE = re.compile(r"^[a-z0-9_\-\./:#%\[\]]+$")
TECH_PREFIX = ("res://", "user://", "uid://", "http", "ui_")
CALLS = r"(?:preload|load|get_node|get_node_or_null|has_signal|connect|emit_signal|add_to_group|is_in_group|has_method|call_deferred|get_meta|set_meta|get_setting|set_setting|has_setting|get|has|erase|get_or_add|find_child|is_action_pressed|is_action_just_pressed|call|callv|begins_with|ends_with|contains|split|replace|nodes_in_group|get_nodes_in_group)"
CALL_RE = re.compile(CALLS + r'\("[^"]*"')


def is_visible_candidate(s):
    if len(s) < 2 or not HAS_LETTER.search(s):
        return False
    if s.startswith(TECH_PREFIX) or ID_LIKE.match(s):
        return False
    if re.match(r"^[A-Z][A-Z0-9_]+$", s):
        return False
    if re.match(r"^[\w\-]+\.(gd|tscn|tres|json|png|svg|ogg|wav|cfg)$", s):
        return False
    if re.match(r"^[#%$@]?[\w/\.\-]+$", s) and " " not in s and not re.search(r"[áéíóúñÁÉÍÓÚÑ]", s):
        return s[0].isupper() and len(s) > 2 and not re.match(r"^[A-Z][a-z]+[A-Z]", s)
    return True


def kinds(s, line):
    ks = []
    if re.search(r"%[sdfx0-9\.\+\-]", s) or ("{" in s and "}" in s):
        ks.append("placeholder")
    if '" +' in line or '+ "' in line:
        ks.append("concatenado")
    if re.search(r'"s" if |" if .* else "|plural', line):
        ks.append("plural")
    if "\\n" in s:
        ks.append("multilinea")
    return ks


def rel(p):
    return os.path.relpath(p, ROOT).replace(os.sep, "/")


def walk(exts):
    for d, ds, fs in os.walk(ROOT):
        ds[:] = sorted(x for x in ds if x not in SKIP_DIRS and not x.startswith("."))
        for f in sorted(fs):
            if f.endswith(exts):
                yield os.path.join(d, f)


def scan_gd():
    out = {}
    for p in walk((".gd",)):
        items = []
        for n, line in enumerate(open(p, encoding="utf-8").read().split("\n"), 1):
            if line.strip().startswith("#"):
                continue
            if re.match(r"\s*(print|push_error|push_warning|assert|printerr|print_debug)\(", line):
                continue
            code = re.sub(r'\s#(?=[^"]*$).*$', "", line)
            masked = CALL_RE.sub("", code)
            for m in STR_RE.finditer(masked):
                s = m.group(1)
                after = masked[m.end():m.end() + 3].lstrip()
                before = masked[:m.start()].rstrip()
                if after.startswith(":") and (before.endswith("{") or before.endswith(",")):
                    continue
                if before.endswith("[") and after.startswith("]"):
                    continue
                if is_visible_candidate(s):
                    items.append((n, s, kinds(s, code)))
        if items:
            out[rel(p)] = items
    return out


def scan_tscn():
    out = {}
    keys = ("text", "tooltip_text", "placeholder_text", "title", "dialog_text", "ok_button_text", "cancel_button_text")
    pat = re.compile(r'^(%s) = "((?:[^"\\]|\\.)*)"' % "|".join(keys))
    for p in walk((".tscn",)):
        items = []
        for n, line in enumerate(open(p, encoding="utf-8").read().split("\n"), 1):
            m = pat.match(line)
            if m and m.group(2) and HAS_LETTER.search(m.group(2)):
                items.append((n, "[%s] %s" % (m.group(1), m.group(2)), kinds(m.group(2), line)))
        if items:
            out[rel(p)] = items
    return out


TRES_KEYS = ("display_name", "description", "flavor", "title", "hint", "tooltip", "text", "label", "short_description", "lore", "upgrade_name", "name")


def scan_tres():
    out = {}
    pat = re.compile(r'^(\w+) = "((?:[^"\\]|\\.)*)"')
    for p in walk((".tres",)):
        items = []
        for n, line in enumerate(open(p, encoding="utf-8").read().split("\n"), 1):
            m = pat.match(line)
            if m and m.group(1) in TRES_KEYS and m.group(2) and HAS_LETTER.search(m.group(2)):
                items.append((n, "[%s] %s" % (m.group(1), m.group(2)), kinds(m.group(2), line)))
        if items:
            out[rel(p)] = items
    return out


JSON_SKIP_KEYS = {"id", "ids", "tema", "theme", "dibujo", "icono", "icon", "sprite", "textura", "fuente", "imagen", "path", "ruta",
                  "escena", "enemigo", "torre", "tipo", "type", "clave", "key", "familia", "bioma", "mapa", "nivel_id", "modo",
                  "version", "borrador", "orden", "color", "forma", "estilo", "estado", "estados", "grupo", "anclaje", "ancla",
                  "fondo", "banner", "marca", "poste", "variante", "variantes", "sonido", "audio", "musica", "plantilla"}


def walk_json(node, path, acc):
    if isinstance(node, dict):
        for k, v in node.items():
            walk_json(v, path + [str(k)], acc)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk_json(v, path + [str(i)], acc)
    elif isinstance(node, str):
        key = ""
        for seg in reversed(path):
            if not seg.isdigit():
                key = seg
                break
        if key in JSON_SKIP_KEYS or not HAS_LETTER.search(node) or len(node) < 2:
            return
        if ID_LIKE.match(node) and " " not in node:
            return
        if node.startswith(("res://", "user://", "#")):
            return
        acc.append((".".join(path), node))


def scan_json():
    out = {}
    for p in walk((".json",)):
        r = rel(p)
        if r.startswith(("export_presets", "data/i18n/")):
            continue
        try:
            d = json.load(open(p, encoding="utf-8"))
        except Exception:
            continue
        acc = []
        walk_json(d, [], acc)
        if r.startswith("data/levels/"):
            acc = [(k, v) for k, v in acc if k.startswith(("textos", "nombre"))]
        if acc:
            out[r] = [(0, "[%s] %s" % (k, v), kinds(v, "")) for k, v in acc]
    return out


GROUPS = [
    ("Menú principal y navegación", ("scenes/ui/main_menu", "scenes/ui/menu_", "scripts/autoload/game_flow", "scenes/ui/tools_hub", "scripts/logic/game_version")),
    ("Opciones", ("scenes/ui/options_menu",)),
    ("Selector de campaña y mapa", ("scenes/ui/level_select", "scenes/ui/campaign_", "scripts/logic/campaign_", "data/campaign", "data/ui/marcas", "data/ui/postes", "data/progression", "scripts/logic/banner_catalog", "scenes/ui/stars_display")),
    ("Introducción, nivel y presentación", ("scenes/ui/intro_", "scenes/ui/level_intro", "scripts/logic/intro_", "scripts/logic/level_texts", "data/intro", "scenes/ui/boss_presentation", "scripts/logic/boss_")),
    ("Niveles (nombre, lugar, entrada, victoria)", ("data/levels/",)),
    ("HUD y partida", ("scenes/game/", "scenes/ui/tower_panel", "scenes/ui/obstacle_panel", "scenes/ui/infrastructure_tab", "scenes/ui/bar_tabs", "scripts/logic/infrastructure_text", "scripts/logic/ghost_", "scripts/logic/charge_", "scripts/logic/demolition_", "scripts/logic/leak_log", "data/ui/alcance", "data/ui/mejoras", "data/ui/mobile", "scripts/host", "scenes/effects/", "scenes/levels/", "scripts/data/upgrade_fx", "scripts/data/range_display", "scripts/logic/obstacle_", "scripts/logic/view_all")),
    ("Pausa y confirmaciones de salida", ("scenes/ui/pause_menu", "scenes/ui/exit_dialog", "scripts/logic/exit_text")),
    ("Tutorial", ("scenes/ui/tutorial_", "data/tutorial", "scripts/logic/tutorial")),
    ("Consejos de derrota", ("data/consejos", "scripts/logic/advice_", "scripts/logic/defeat_advice")),
    ("Resultados, epílogo y créditos", ("scenes/ui/end_screen", "scenes/ui/epilogue", "scenes/ui/credits", "scripts/logic/credits", "data/creditos", "scripts/logic/lore_unlock")),
    ("Récords, iniciales y Salón de la fama", ("scenes/ui/records_screen", "scenes/ui/score_table", "scenes/ui/hall_of_fame", "scenes/ui/name_entry", "scripts/logic/high_scores")),
    ("Wiki (pantalla y artículos)", ("scenes/ui/wiki_", "data/wiki/", "scripts/logic/wiki")),
    ("Torres (nombre, descripción, mejoras)", ("data/towers/", "scenes/towers/", "scripts/data/tower_", "scripts/logic/tower_text", "scripts/logic/upgrade_deltas")),
    ("Enemigos y jefes", ("data/enemies/", "scenes/enemies/", "scripts/data/enemy_", "scenes/ui/enemy_icon")),
    ("Modos (Asedio y otros)", ("data/modos/", "scripts/logic/siege_", "scripts/logic/mode_")),
    ("Novedades", ("data/novedades", "scenes/ui/news_screen", "scripts/logic/news_data")),
    ("Editor de mapas y comunidad", ("scenes/editor/", "scripts/logic/level_draft", "scripts/logic/community_", "scripts/logic/map_", "scripts/logic/level_file")),
    ("Mensajes técnicos y de desarrollo (a decidir si se traducen)", ("scripts/autoload/", "scripts/logic/dev_", "scripts/logic/balance_args", "scripts/logic/desktop_window", "scripts/logic/scene_transition", "scripts/logic/record_sources", "scenes/ui/touch_scroller")),
    ("Coleccionables y hallazgos", ("scripts/logic/collect", "scripts/logic/finding_", "scripts/logic/collection_")),
]
OTHER = "Otros (sin clasificar; revisar)"


def group_of(path):
    for name, prefixes in GROUPS:
        if any(path.startswith(p) for p in prefixes):
            return name
    return OTHER


# ---------- T534: auditoría de lo que queda en español fuera del catálogo ----------

LORE_JSON = ("data/levels/", "data/intro/", "data/wiki/lore/", "data/creditos.json")
DEV_VALIDATION_LINE = re.compile(r"(errors|warnings|problems|reasons)\.append\(|data\.errors|_failed\(|_article_failed\(|return \"[a-záéíóúñ¿]|\"errors\"|_add\(errors")
TECH_NAME = re.compile(r"^[A-Za-z][A-Za-z0-9_ /.%]*$")
FORMAT_ONLY = re.compile(r"%[0-9.]*[sdf]|⏎|\\n|\\t|[\s\d\W_]")
JSON_WRITER = re.compile(r'^\s*\\"\w+\\": |^[ ]*%s: %s$|^\^|\(\?')

def catalog_texts():
    d = json.load(open(os.path.join(ROOT, "data/i18n/es.json"), encoding="utf-8"))
    return [e["texto"] for e in d["entradas"]]


def unescape(s):
    return s.replace("\\n", "\n").replace('\\"', '"').replace("\\\\", "\\")


VALIDATION_FILES = ("scripts/logic/advice_data.gd", "scripts/logic/news_data.gd", "scripts/logic/tutorial_data.gd", "scripts/logic/intro_data.gd",
                    "scripts/logic/credits.gd", "scripts/logic/wiki.gd", "scripts/logic/localization_catalog.gd", "scripts/logic/balance_args.gd",
                    "scripts/logic/collection_definitions.gd", "scripts/data/range_display_config.gd", "scripts/data/upgrade_fx_config.gd")
DEV_TOOL_FILES = ("scripts/logic/intro_doc.gd",)
SVG_PATH = re.compile(r"^[MLHVCZmlhvcz0-9 .\-]+$")


def classify(path, kind, line_text, text):
    """Devuelve la categoría de un candidato que no está en el catálogo."""
    plain = text.split("] ", 1)[-1] if text.startswith("[") else text
    if kind == "Datos (.json)":
        if path.startswith(LORE_JSON):
            return "Lore"
        if text.startswith(("[nota]", "[casillas_libres]", "[comentario]")):
            return "Notas internas de archivos de datos (no se muestran)"
        return "Revisar a mano"
    if kind in ("Escenas (.tscn)", "Recursos (.tres)"):
        return "Texto por omisión de escena (el código lo reemplaza o está oculto)"
    if path in DEV_TOOL_FILES:
        return "Herramienta de desarrollo (documento y mensajes de tools/intro_doc.gd)"
    if path in VALIDATION_FILES or DEV_VALIDATION_LINE.search(line_text):
        return "Validación de datos de desarrollo (solo consola/tests)"
    if path == "scripts/autoload/dev_mode.gd" and line_text.lstrip().startswith('{"action"'):
        return "Texto sin uso (campo `text` de `DevMode.ACTIONS`, que ningún código lee)"
    letters = re.sub(FORMAT_ONLY, "", plain.replace("FPS", "").replace("ms", ""))
    if len(letters) <= 1 or SVG_PATH.match(plain) or JSON_WRITER.search(plain) or plain.startswith((" → ", "[^")) or plain in (". # X S",):
        return "Nombre técnico, id o formato (no es texto de jugador)"
    if re.match(r"^[./]*[A-Za-z][A-Za-z0-9_ /.%]*$", plain) and not re.search(r"[áéíóúñ]", plain) and len(plain.split()) <= 2:
        return "Nombre técnico, id o formato (no es texto de jugador)"
    if "para el mapa" in plain:
        return "Nombre técnico, id o formato (no es texto de jugador)"
    return "Revisar a mano"


CATEGORIES = ("Lore", "Validación de datos de desarrollo (solo consola/tests)", "Herramienta de desarrollo (documento y mensajes de tools/intro_doc.gd)",
              "Texto por omisión de escena (el código lo reemplaza o está oculto)", "Texto sin uso (campo `text` de `DevMode.ACTIONS`, que ningún código lee)",
              "Nombre técnico, id o formato (no es texto de jugador)", "Notas internas de archivos de datos (no se muestran)", "Revisar a mano")


CATEGORY_NOTES = {
    "Lore": "**Es lo único que queda en español como texto de jugador** (D-222): lugar, entrada y victoria y nombre de los 15 niveles, intro, "
            "créditos (incluye «Un juego de Lucas», «Hecho con Godot Engine» y la línea de licencia) y los 11 artículos de Lore de la Wiki. "
            "Se traduce después de T545/T558 y con el OK de Lucas; mientras tanto el respaldo en español los muestra. También son Lore los "
            "nombres de nivel que salen en el selector, en Récords y en la lista «Abrir un nivel» del editor.",
    "Validación de datos de desarrollo (solo consola/tests)": "Mensajes de los lectores de `data/` (tutorial, intro, consejos, novedades, "
            "artículos de la Wiki, créditos, configuraciones de alcance y de mejoras, el catálogo de idiomas, `balance_args`, "
            "`collection_definitions`). Solo llegan a `push_warning`/`push_error` o a los tests; ninguna pantalla los muestra. "
            "D-222 dejó la consola en español. Los de mapas, modos y textos de nivel **sí** se tradujeron (`lvlfile.*`, `grid.*`, `modepack.*`…).",
    "Herramienta de desarrollo (documento y mensajes de tools/intro_doc.gd)": "El documento editable de la intro y sus mensajes (herramienta de línea de comandos).",
    "Texto por omisión de escena (el código lo reemplaza o está oculto)": "Texto que trae el `.tscn` y que el código pisa antes de mostrarlo "
            "(verificado con `tools/capture_menus.gd`, que en inglés no lo encuentra en pantalla) o que está oculto (`WaveBanner`, `BossLine`).",
    "Texto sin uso (campo `text` de `DevMode.ACTIONS`, que ningún código lee)": "Campo `text` de `DevMode.ACTIONS`: ningún código lo lee (el panel usa `dev.*`).",
    "Nombre técnico, id o formato (no es texto de jugador)": "Nombres de nodos, ids, expresiones regulares, fragmentos de formato (`%s · %s`, ` ⏎ `), "
            "trozos de JSON que escribe el editor y rutas de clave (` → removible → `): no son texto de jugador.",
    "Notas internas de archivos de datos (no se muestran)": "Claves `nota` de `data/ui/*.json`: comentarios para quien edita el archivo.",
    "Revisar a mano": "Lo que la heurística no supo clasificar.",
}


def audit(salida):
    cat = catalog_texts()
    cat_blob = "\n".join(cat)
    sources = [("GDScript", scan_gd()), ("Escenas (.tscn)", scan_tscn()), ("Recursos (.tres)", scan_tres()), ("Datos (.json)", scan_json())]
    res = defaultdict(lambda: defaultdict(list))
    skipped_catalogued = 0
    for kind, files in sources:
        for path, items in files.items():
            lines = open(os.path.join(ROOT, path), encoding="utf-8").read().split("\n") if kind != "Datos (.json)" else []
            for n, s, ks in items:
                line_text = lines[n - 1] if n and n <= len(lines) else ""
                raw = s.split("] ", 1)[-1] if s.startswith("[") else s
                if "Localization." in line_text:
                    continue
                if kind == "GDScript" and "#" in line_text and raw and line_text.find("#") < line_text.find(raw.replace('\\"', '"')):
                    continue  # el texto está dentro de un comentario
                data_literal = kind == "GDScript" and re.match(r'\s*(const |\{"|&"|"[^"]+": |\[")', line_text)
                if (kind != "GDScript" or data_literal) and unescape(raw) in cat:
                    skipped_catalogued += 1
                    continue
                if kind == "Datos (.json)" and len(raw) > 3 and unescape(raw) in cat_blob:
                    skipped_catalogued += 1
                    continue
                category = classify(path, kind, line_text, s)
                res[category][path].append((n, s))
    L = ["# T534 · Auditoría de textos que siguen en español fuera del catálogo\n",
         "*Generada con `python3 tools/localization_inventory.py --auditoria` (solo lee el proyecto). Parte de los candidatos del inventario T533 "
         "(`T533-inventario-textos.md`) y descarta los textos que ya viven en `data/i18n/es.json` y las líneas que ya llaman a `Localization`. "
         "Es una heurística: lo que queda se clasificó por ruta y por forma de la línea.*\n",
         "- Candidatos del inventario ya cubiertos por el catálogo (descartados): **%d**." % skipped_catalogued]
    total = 0
    for category in CATEGORIES:
        files = res.get(category, {})
        count = sum(len(v) for v in files.values())
        total += count
        L.append("- %s: **%d** en **%d** archivos." % (category, count, len(files)))
    L.append("- Total que sigue fuera del catálogo: **%d**.\n" % total)
    for category in CATEGORIES:
        files = res.get(category, {})
        L.append("## %s\n" % category)
        if category in CATEGORY_NOTES:
            L.append("*%s*\n" % CATEGORY_NOTES[category])
        if not files:
            L.append("Ninguno.\n")
            continue
        for path in sorted(files):
            items = files[path]
            L.append("<details><summary><code>%s</code> · %d</summary>\n" % (path, len(items)))
            for n, s in items:
                s1 = s.replace("\\n", " ⏎ ").replace("\n", " ").replace("|", "\\|").replace("`", "'")
                if len(s1) > 140:
                    s1 = s1[:137] + "…"
                L.append("- %s`%s`" % (("L%d " % n) if n else "", s1))
            L.append("\n</details>\n")
    os.makedirs(os.path.dirname(salida), exist_ok=True)
    open(salida, "w", encoding="utf-8").write("\n".join(L))
    print("catalogados", skipped_catalogued)
    for category, files in res.items():
        print(category, sum(len(v) for v in files.values()), len(files))


def main():
    if "--auditoria" in sys.argv:
        i = sys.argv.index("--auditoria")
        audit(sys.argv[i + 1] if i + 1 < len(sys.argv) else os.path.join(ROOT, "specs/tareas/informes/T534-auditoria-textos.md"))
        return
    salida = os.path.join(ROOT, "specs/tareas/informes/T533-inventario-textos.md")
    if "--salida" in sys.argv:
        salida = sys.argv[sys.argv.index("--salida") + 1]
    sources = [("GDScript", scan_gd()), ("Escenas (.tscn)", scan_tscn()), ("Recursos (.tres)", scan_tres()), ("Datos (.json)", scan_json())]
    by_group = defaultdict(dict)
    for kind, files in sources:
        for path, items in files.items():
            by_group[group_of(path)][(kind, path)] = items
    total = sum(len(i) for _, f in sources for i in f.values())
    nfiles = sum(len(f) for _, f in sources)
    order = [g for g, _ in GROUPS] + [OTHER]
    L = []
    L.append("# T533 · Inventario de textos visibles del juego\n")
    L.append("*Generado con `python3 tools/localization_inventory.py` (solo lee el proyecto). Es una heurística: son **candidatos**, "
             "no una lista cerrada ni una traducción. Lucas revisa este documento antes de T534; todavía no se tradujo nada.*\n")
    L.append("## Resumen\n")
    L.append("- Candidatos a texto visible: **%d** en **%d** archivos." % (total, nfiles))
    L.append("- Por tipo de fuente: " + ", ".join("%s **%d**" % (k, sum(len(i) for i in f.values())) for k, f in sources) + ".\n")
    L.append("| Pantalla / grupo | Archivos | Candidatos | Con placeholder | Concatenados | Plural | Multilínea |")
    L.append("|---|---:|---:|---:|---:|---:|---:|")
    tot = [0] * 6
    for g in order:
        files = by_group.get(g)
        if not files:
            continue
        its = [i for v in files.values() for i in v]
        row = [len(files), len(its)] + [sum(1 for i in its if k in i[2]) for k in ("placeholder", "concatenado", "plural", "multilinea")]
        tot = [a + b for a, b in zip(tot, row)]
        L.append("| %s | %s |" % (g, " | ".join(map(str, row))))
    L.append("| **Total** | %s |\n" % " | ".join("**%d**" % x for x in tot))
    L.append("## Cómo leer los candidatos\n")
    L.append("- Los literales de GDScript incluyen algunos falsos positivos (nombres de nodos, formatos de depuración, ids con mayúscula). En la revisión se descartan; los **falsos negativos** más probables son textos armados con `str()`/`%` desde varias piezas sueltas y textos de una sola palabra en minúscula.")
    L.append("- Las escenas `.tscn` listan `text`, `tooltip_text`, `placeholder_text` y `title`. Los recursos `.tres` listan `display_name`, `description` y similares. Los `.json` listan los valores de texto (se excluyen ids, temas, dibujos y rutas).")
    L.append("- No entran: documentación de desarrollo (`specs/`, `README`…), nombres de archivo e identificadores, `print`/`push_error` (solo consola), tests.")
    L.append("- Los textos generados en tiempo de ejecución (marcados `placeholder`, `concatenado`, `plural`) están en las tablas de abajo; cada uno necesita una clave con placeholders nombrados.\n")
    L.append("## Estrategia de claves y rutas de cobertura\n")
    L.append("- **Infraestructura (T533):** `Localization` (`scripts/logic/localization.gd`) con catálogos `data/i18n/es.json` y `data/i18n/en.json`; `LocalizationCatalog` valida claves ausentes, duplicadas y placeholders. El idioma se guarda en `settings.language` (por omisión `es`) sin tocar `SAVE_VERSION` ni progreso. El selector en Opciones queda **oculto** (`Localization.SELECTOR_ENABLED = false`) hasta que T534 complete el inglés.")
    L.append("- **Claves estables en inglés**, con puntos, por dominio: `menu.main.play`, `options.audio.music`, `level.level_01.entry`, `tower.basic.name`, `wiki.teclas.b3`, `enemy.armored.description`, `hud.wave`. Nunca se usa el texto en español como clave.")
    L.append("- **Escenas y GDScript:** el literal pasa a `Localization.t(&\"clave\")`; los valores van con `Localization.t_fmt(&\"clave\", {\"n\": 3})` y placeholders `{n}`. Las concatenaciones se reescriben como una frase con placeholders; los plurales usan `clave.one` / `clave.other` (`t_plural`).")
    L.append("- **Datos (`data/`):** el texto en español queda como valor base (no cambia balance ni guardados); el inglés vive en `data/i18n/en.json` bajo `<dominio>.<id>.<campo>`.")
    L.append("- **Wiki, tutorial, intro, consejos, novedades, créditos:** por bloque/lámina/regla con índice estable (`wiki.<articulo>.b<n>`).")
    L.append("- **Accesibilidad y tooltips:** `tooltip_text`, `placeholder_text` y cualquier texto para lector de pantalla entran al mismo catálogo.")
    L.append("- **No se traducen:** ids, nombres de archivo, teclas internas, símbolos canónicos y nombres propios del canon (ver decisiones).\n")
    L.append("## Puntos a decidir por Lucas antes de T534\n")
    L.append("- Nombres propios del canon (Cántaro, Compañía Meridiana, Moradores, lugares de niveles, jefes): ¿se conservan en español o tienen versión inglesa? `specs/10-universo.md` no define una.")
    L.append("- Los textos de `specs/11-textos-lore.md` (lugar/entrada/victoria, epílogo, créditos, Lore) son canon en español; ¿quién traduce y aprueba el inglés?")
    L.append("- Nombre del juego y siglas visibles («Monsters & Canons»), y las iniciales de récords de 3 y 5 letras.")
    L.append("- Formato de números, fechas y versión (`GameVersion`) según idioma.")
    L.append("- Mientras `specs/11-textos-lore.md` siga como borrador, ¿los textos de Lore se traducen en T534 o después?\n")
    L.append("## Detalle por pantalla y fuente\n")
    for g in order:
        files = by_group.get(g)
        if not files:
            continue
        L.append("### %s\n" % g)
        for (kind, path), items in sorted(files.items(), key=lambda x: x[0][1]):
            L.append("<details><summary><code>%s</code> · %s · %d</summary>\n" % (path, kind, len(items)))
            for n, s, ks in items:
                tag = (" `" + ",".join(sorted(set(ks))) + "`") if ks else ""
                s1 = s.replace("\\n", " ⏎ ").replace("\n", " ").replace("|", "\\|").replace("`", "'")
                if len(s1) > 160:
                    s1 = s1[:157] + "…"
                loc = ("L%d " % n) if n else ""
                L.append("- %s`%s`%s" % (loc, s1, tag))
            L.append("\n</details>\n")
    os.makedirs(os.path.dirname(salida), exist_ok=True)
    open(salida, "w", encoding="utf-8").write("\n".join(L))
    print("candidatos", total, "archivos", nfiles)
    for g in order:
        if g in by_group:
            print(g, sum(len(v) for v in by_group[g].values()), len(by_group[g]))


main()
