#!/usr/bin/env python3
"""T320: mide el peso importado de las láminas de la intro y arma `peso/comparison.html`.

Para cada variante de importación cambia los `.import` de `assets/intro/`, corre `godot --headless --import`,
mide los `.ctex` reales (lo que va dentro del .pck/APK) y, en las variantes con pérdida, extrae el WebP que
Godot guardó para compararlo con el PNG original. Al final deja los `.import` como los pidió `--final`.

Uso (desde la raíz del proyecto; requiere Python 3 y Pillow, y `godot` en el PATH):
    python3 art/intro-v1/peso.py            # mide y arma peso/ (tarda unos minutos)
    python3 art/intro-v1/peso.py --final    # solo deja la importación elegida (T320) y sale

No toca `art/intro-v1/sources/` ni los PNG de `assets/intro/`.
"""
import glob, io, math, os, re, shutil, subprocess, sys
from PIL import Image, ImageChops, ImageStat

# nombre: (compress/mode, lossy_quality, mipmaps). mode 0 = sin pérdida, 1 = con pérdida (WebP).
VARIANTS = {
    "actual": (0, 0.7, True),
    "sin_pérdida_sin_mipmaps": (0, 0.7, False),
    "webp_q95": (1, 0.95, False),
    "webp_q90": (1, 0.90, False),
    "webp_q85": (1, 0.85, False),
}
FINAL = "sin_pérdida_sin_mipmaps"
SHOWN = ["webp_q95", "webp_q90", "webp_q85"]  # las que se miden contra el original
SAVED = ["webp_q95", "webp_q85"]  # de estas se guardan recortes para mirarlas
OUT = "art/intro-v1/peso"
NAMES = sorted(glob.glob("assets/intro/*.png"))


def set_import(mode, quality, mipmaps):
    for png in NAMES:
        path = png + ".import"
        text = open(path, encoding="utf-8").read()
        text = re.sub(r"compress/mode=\d+", "compress/mode=%d" % mode, text)
        text = re.sub(r"compress/lossy_quality=[\d.]+", "compress/lossy_quality=%s" % quality, text)
        text = re.sub(r"mipmaps/generate=\w+", "mipmaps/generate=%s" % str(mipmaps).lower(), text)
        open(path, "w", encoding="utf-8", newline="\n").write(text)


def reimport():
    subprocess.run(["godot", "--headless", "--import"], capture_output=True, check=False)


def ctex_of(png):
    return glob.glob(".godot/imported/%s-*.ctex" % os.path.basename(png))[0]


def webp_of(ctex):
    data = open(ctex, "rb").read()
    i = data.find(b"RIFF")
    return data[i:i + int.from_bytes(data[i + 4:i + 8], "little") + 8]


def psnr(a, b):
    sq = ImageStat.Stat(ImageChops.difference(a, b).point(lambda v: v * v))
    mse = sum(sq.mean) / 3
    return 99.0 if mse == 0 else 10 * math.log10(255 * 255 / mse)


def worst_tile(a, b, cols=6, rows=6):
    w, h = a.size
    tw, th = w // cols, h // rows
    best, box = -1.0, None
    for r in range(rows):
        for c in range(cols):
            t = (c * tw, r * th, (c + 1) * tw, (r + 1) * th)
            sq = ImageStat.Stat(ImageChops.difference(a.crop(t), b.crop(t)).point(lambda v: v * v))
            if sum(sq.mean) > best:
                best, box = sum(sq.mean), t
    return box


def main():
    if "--final" in sys.argv:
        set_import(*VARIANTS[FINAL])
        reimport()
        return
    os.makedirs(OUT, exist_ok=True)
    rows = {}
    for name, params in VARIANTS.items():
        set_import(*params)
        reimport()
        sizes = [os.path.getsize(ctex_of(p)) for p in NAMES]
        rows[name] = {"sizes": sizes, "psnr": []}
        if name not in SHOWN:
            continue
        for png, size in zip(NAMES, sizes):
            base = os.path.splitext(os.path.basename(png))[0]
            raw = webp_of(ctex_of(png))
            src = Image.open(png).convert("RGB")
            dec = Image.open(io.BytesIO(raw)).convert("RGB")
            rows[name]["psnr"].append(psnr(src, dec))
            if name == "webp_q95":
                rows.setdefault("_box", {})[base] = worst_tile(src, dec)
                src.crop(rows["_box"][base]).save("%s/%s_recorte_original.png" % (OUT, base))
            if name in SAVED:
                dec.crop(rows["_box"][base]).save("%s/%s_recorte_%s.png" % (OUT, base, name))
    set_import(*VARIANTS[FINAL])
    reimport()
    write_html(rows)


def mb(n):
    return "%.2f" % (n / 1048576)


def write_html(rows):
    bases = [os.path.splitext(os.path.basename(p))[0] for p in NAMES]
    out = ["<!doctype html><html lang='es'><meta charset='utf-8'><title>Peso de la intro (T320)</title>",
           "<style>body{font:15px sans-serif;background:#1b1b22;color:#e8e2d0;margin:20px}table{border-collapse:collapse}"
           "td,th{border:1px solid #555;padding:4px 8px;text-align:right}img{max-width:100%;image-rendering:pixelated}"
           ".g{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}h2{margin-top:36px}</style>",
           "<h1>Peso importado de las láminas de la intro (T320)</h1>",
           "<p>Bytes de los <code>.ctex</code> reales (lo que entra al .pck y a la APK), las 7 láminas juntas. "
           "Los recortes son la zona de 320 × 180 donde WebP q95 se aparta más del original, <b>sin ampliar</b> "
           "(el navegador los muestra a tamaño real).</p><table><tr><th>Variante</th><th>Total MiB</th><th>% del actual</th><th>PSNR medio (dB)</th></tr>"]
    base_total = sum(rows["actual"]["sizes"])
    for name in VARIANTS:
        tot = sum(rows[name]["sizes"])
        ps = rows[name]["psnr"]
        out.append("<tr><td style='text-align:left'>%s</td><td>%s</td><td>%d %%</td><td>%s</td></tr>" % (
            name, mb(tot), round(100 * tot / base_total), ("%.1f" % (sum(ps) / len(ps))) if ps else ("idéntico (sin pérdida)" if VARIANTS[name][0] == 0 else "—")))
    out.append("</table>")
    for i, base in enumerate(bases):
        out.append("<h2>%s</h2><p>Recurso importado: actual %s MiB; WebP q95 %s MiB; q85 %s MiB.</p>" % (
            base, mb(rows["actual"]["sizes"][i]), mb(rows["webp_q95"]["sizes"][i]), mb(rows["webp_q85"]["sizes"][i])))
        out.append("<div class='g'><div>Original<br><img src='%s_recorte_original.png'></div>"
                   "<div>WebP q95<br><img src='%s_recorte_webp_q95.png'></div>"
                   "<div>WebP q85<br><img src='%s_recorte_webp_q85.png'></div></div>" % (base, base, base))
    open(OUT + "/comparison.html", "w", encoding="utf-8").write("\n".join(out))


if __name__ == "__main__":
    main()
