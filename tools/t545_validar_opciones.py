#!/usr/bin/env python3
"""T545: valida art/t545-revision/opciones.json.

Comprueba, para cada entrada y cada opción:
  - el JSON está bien formado y los ids no se repiten;
  - el «texto actual» coincide con lo que hay hoy en data/ (tal cual);
  - cada opción cumple los límites de líneas y caracteres de su campo
    (RF-464 / LevelTexts; los de nombre y wiki son orientativos);
  - ninguna opción usa el vocabulario vetado de specs/11-textos-lore.md;
  - a lo sumo 3 opciones, distintas entre sí y distintas del texto actual;
  - el epílogo y las imágenes no tienen opciones (texto de Lucas).

Uso (desde la raíz del proyecto):  python3 tools/t545_validar_opciones.py
Sale con código 1 si hay errores. Las advertencias no lo hacen fallar.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RUTA = os.path.join(ROOT, "art", "t545-revision", "opciones.json")

VETADAS = [
    r"enemig\w*", r"peligr\w*", r"bestias?", r"salvajes?", r"invasor\w*", r"nativ\w*",
    r"indi[oa]s?", r"aliens?", r"monstruos?", r"malvad\w*", r"héro\w*", r"heroe\w*",
]
VETADAS_RE = re.compile(r"(?<!\w)(" + "|".join(VETADAS) + r")(?!\w)", re.IGNORECASE)

errores: list[str] = []
avisos: list[str] = []


def err(msg: str) -> None:
    errores.append(msg)


def aviso(msg: str) -> None:
    avisos.append(msg)


def cargar(ruta: str):
    with open(os.path.join(ROOT, ruta), encoding="utf-8") as f:
        return json.load(f)


def actual_en_data(e: dict):
    """Devuelve el texto que hoy tiene el juego para esta entrada, o None si no se compara."""
    id_ = e["id"]
    m = re.match(r"nivel_(\d\d)\.(\w+)$", id_)
    if m:
        d = cargar(f"data/levels/level_{m.group(1)}.json")
        return d["nombre"] if m.group(2) == "nombre" else d["textos"][m.group(2)]
    if id_ == "epilogo":
        return cargar("data/levels/level_15.json")["textos"]["epilogo"]
    if id_ == "creditos":
        return "\n".join(cargar("data/creditos.json")["lineas"])
    m = re.match(r"intro\.lamina_(\d)$", id_)
    if m:
        return cargar("data/intro/intro.json")["laminas"][int(m.group(1)) - 1]["texto"]
    m = re.match(r"lore\.(\w+)$", id_)
    if m:
        d = cargar(f"data/wiki/lore/{m.group(1)}.json")
        return "\n\n".join(b["texto"] for b in d["bloques"] if b["tipo"] == "texto")
    return None


def revisar_limites(id_: str, que: str, texto: str, lim: dict) -> None:
    ors = " (orientativo)" if lim.get("orientativo") else ""
    emit = aviso if lim.get("orientativo") else err
    lineas = texto.split("\n")
    if lim["lineas_max"] and len(lineas) > lim["lineas_max"]:
        emit(f"{id_} {que}: {len(lineas)} líneas, máximo {lim['lineas_max']}{ors}")
    if len(lineas) < lim["lineas_min"]:
        emit(f"{id_} {que}: {len(lineas)} líneas, mínimo {lim['lineas_min']}{ors}")
    if lim["caracteres"] and len(texto) > lim["caracteres"]:
        emit(f"{id_} {que}: {len(texto)} caracteres, máximo {lim['caracteres']}{ors}")
    if lim["linea"]:
        for i, l in enumerate(lineas, 1):
            if not l.strip():
                err(f"{id_} {que}: la línea {i} está en blanco")
            elif len(l) > lim["linea"]:
                emit(f"{id_} {que}: la línea {i} tiene {len(l)} caracteres, máximo {lim['linea']}{ors}")


def main() -> int:
    try:
        with open(RUTA, encoding="utf-8") as f:
            datos = json.load(f)
    except (OSError, json.JSONDecodeError) as ex:
        print(f"ERROR: no se pudo leer {RUTA}: {ex}")
        return 1

    hallazgos = datos.get("hallazgos", {})
    ids = set()
    n_op = 0
    n_con = 0
    for e in datos["entradas"]:
        id_ = e["id"]
        if id_ in ids:
            err(f"{id_}: id repetido")
        ids.add(id_)
        for k in ("seccion", "titulo", "fuente", "actual", "limites", "hallazgos", "opciones"):
            if k not in e:
                err(f"{id_}: falta el campo {k}")
        for h in e.get("hallazgos", []):
            if h not in hallazgos:
                err(f"{id_}: hallazgo desconocido {h}")
        for c in e.get("captura", []):
            if not os.path.exists(os.path.join(ROOT, "art", "t545-revision", c)):
                err(f"{id_}: la captura {c} no existe")

        esperado = actual_en_data(e)
        if esperado is not None and esperado != e["actual"]:
            err(f"{id_}: el texto actual no coincide con data/ (¿cambió el juego? regenerar)")

        ops = e["opciones"]
        if e.get("fijo") and ops:
            err(f"{id_}: es una pieza fija (texto de Lucas o imagen) y no puede tener opciones")
        if len(ops) > 3:
            err(f"{id_}: {len(ops)} opciones, máximo 3")
        prioridades = {hallazgos[h]["prioridad"] for h in e.get("hallazgos", []) if h in hallazgos}
        if not e.get("fijo") and prioridades & {"Alta", "Media"} and len(ops) < 3 and e["campo"] != "vista":
            aviso(f"{id_}: tiene hallazgo de prioridad Alta/Media y solo {len(ops)} opciones")
        vistos = {e["actual"]}
        if ops:
            n_con += 1
        for o in ops:
            n_op += 1
            oid = f"{id_}.{o.get('id', '?')}"
            for k in ("id", "etiqueta", "resuelve", "texto"):
                if not o.get(k):
                    err(f"{oid}: falta {k}")
            t = o.get("texto", "")
            if t in vistos and not o.get("accion_externa"):
                err(f"{oid}: el texto repite el actual u otra opción")
            vistos.add(t)
            revisar_limites(oid, "texto", t, e["limites"])
            m = VETADAS_RE.search(t + " " + o.get("subtitulo", ""))
            if m and e["seccion"] != "Mecánica":
                err(f"{oid}: vocabulario vetado «{m.group(0)}»")
            if e["limite_tipo"] != "wiki" and "\n\n" in t:
                err(f"{oid}: línea en blanco en un texto de pantalla")

        m = VETADAS_RE.search(e["actual"])
        if m:
            aviso(f"{id_}: el texto ACTUAL tiene «{m.group(0)}» (revisar a mano)")
        revisar_limites(id_, "actual", e["actual"], e["limites"])

    print(f"Entradas: {len(datos['entradas'])} · con opciones: {n_con} · opciones: {n_op}")
    print(f"Errores: {len(errores)} · Advertencias: {len(avisos)}")
    for a in avisos:
        print("  AVISO ", a)
    for x in errores:
        print("  ERROR ", x)
    print("RESULTADO:", "FALLA" if errores else "OK")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
