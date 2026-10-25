#!/usr/bin/env python3
"""Compara las capturas de tools/measure_sharpness.gd (modos host y native) con Pillow.

Uso: python3 tools/compare_sharpness.py <carpeta_con_PNG_y_JSON> [carpeta_de_diferencias]

Por pantalla imprime: tamaño de captura, diferencia absoluta media y máxima entre host y native,
porcentaje de píxeles distintos, y nitidez de cada una (varianza del Laplaciano y energía media del
gradiente) sobre toda la imagen y sobre la mitad central. Si se pasa la segunda carpeta, guarda un
mapa de diferencias amplificado. Solo mide nitidez de lo dibujado; no mide rendimiento.
"""
import json
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter, ImageStat

SCREENS = ["main_menu", "level_select", "wiki_screen", "game"]


def sharpness(img):
    gray = img.convert("L")
    lap = gray.filter(ImageFilter.Kernel((3, 3), [0, 1, 0, 1, -4, 1, 0, 1, 0], scale=1, offset=128))
    lap_var = ImageStat.Stat(lap).var[0]
    gx = ImageChops.difference(gray, ImageChops.offset(gray, 1, 0))
    gy = ImageChops.difference(gray, ImageChops.offset(gray, 0, 1))
    grad = ImageStat.Stat(gx).mean[0] + ImageStat.Stat(gy).mean[0]
    return lap_var, grad


def centre(img):
    w, h = img.size
    return img.crop((w // 4, h // 4, 3 * w // 4, 3 * h // 4))


def main():
    folder = Path(sys.argv[1])
    diffs = Path(sys.argv[2]) if len(sys.argv) > 2 else None
    results = {}
    for mode in ("host", "native"):
        info = json.loads((folder / f"{mode}_info.json").read_text())
        print(f"[{mode}] ventana {info['ventana_tamano']} modo {info['ventana_modo']} pantalla {info['pantalla_tamano']}")
    for name in SCREENS:
        a = Image.open(folder / f"host_{name}.png").convert("RGB")
        b = Image.open(folder / f"native_{name}.png").convert("RGB")
        row = {"host_size": a.size, "native_size": b.size}
        if a.size == b.size:
            d = ImageChops.difference(a, b)
            stat = ImageStat.Stat(d.convert("L"))
            hist = d.convert("L").histogram()
            row["diff_media"] = stat.mean[0]
            row["diff_max"] = d.getextrema()
            row["pct_distintos"] = 100.0 * (sum(hist[1:])) / (a.size[0] * a.size[1])
            row["pct_distintos_mayor_8"] = 100.0 * (sum(hist[9:])) / (a.size[0] * a.size[1])
            if diffs:
                diffs.mkdir(parents=True, exist_ok=True)
                d.point(lambda v: min(255, v * 8)).save(diffs / f"diff_{name}.png")
        for label, img in (("host", a), ("native", b)):
            row[label + "_lap_total"], row[label + "_grad_total"] = sharpness(img)
            row[label + "_lap_centro"], row[label + "_grad_centro"] = sharpness(centre(img))
        results[name] = row
        print(name)
        for k, v in row.items():
            print("   %-24s %s" % (k, ("%.4f" % v) if isinstance(v, float) else v))
    print(json.dumps(results, default=str))


if __name__ == "__main__":
    main()
