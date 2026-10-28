#!/usr/bin/env python3
"""Genera las muestras 1920x1080 y los montajes con la franja de texto (no son capturas del motor).

Uso: python3 -I montar.py   (desde art/t546-final)
La franja replica EpilogueScreen: 230 px de 720 abajo, color (0.04,0.045,0.06,0.78), texto 22 px centrado
(3 líneas de la frase) y botones «Créditos» y «Niveles». Escala a 1280x720 (viewport de diseño)."""
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
MUESTRAS = {
    "muestra_luminosa_01": "sources/a2.png",
    "muestra_luminosa_02": "sources/a3.png",
    "muestra_oscura_01": "sources/b4.png",
    "muestra_oscura_02": "sources/b6.png",
}
FRASE = ["La máquina sigue avanzando,", "pero ¿por cuánto tiempo más?", "¿A qué costo?"]
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def montar(img: Image.Image, ancho: int, alto: int) -> Image.Image:
    """Recorta como STRETCH_KEEP_ASPECT_COVERED a ancho x alto y superpone la franja."""
    w, h = img.size
    esc = max(ancho / w, alto / h)
    r = img.resize((round(w * esc), round(h * esc)), Image.LANCZOS)
    x, y = (r.width - ancho) // 2, (r.height - alto) // 2
    base = r.crop((x, y, x + ancho, y + alto)).convert("RGBA")
    franja = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(franja)
    d.rectangle((0, alto - 230, ancho, alto), fill=(10, 11, 15, 199))
    f = ImageFont.truetype(FONT, 22)
    yy = alto - 230 + 22
    for linea in FRASE:
        tw = d.textlength(linea, font=f)
        d.text(((ancho - tw) / 2, yy), linea, font=f, fill=(245, 240, 224, 255))
        yy += 30
    for i, t in enumerate(("Créditos", "Niveles")):
        bx = ancho / 2 + (-170 if i == 0 else 20)
        d.rounded_rectangle((bx, alto - 76, bx + 150, alto - 28), 6, fill=(30, 33, 40, 255), outline=(190, 150, 80, 255), width=2)
        tw = d.textlength(t, font=f)
        d.text((bx + (150 - tw) / 2, alto - 64), t, font=f, fill=(245, 240, 224, 255))
    return Image.alpha_composite(base, franja).convert("RGB")


os.makedirs(os.path.join(HERE, "context"), exist_ok=True)
for nombre, src in MUESTRAS.items():
    im = Image.open(os.path.join(HERE, src)).convert("RGB")
    im.resize((1920, 1080), Image.LANCZOS).save(os.path.join(HERE, nombre + ".png"), optimize=True)
    montar(im, 1280, 720).save(os.path.join(HERE, "context", nombre + "_16x9.png"))
    montar(im, 1280, 549).save(os.path.join(HERE, "context", nombre + "_21x9.png"))
viejo = Image.open(os.path.join(HERE, "../../assets/sprites/story/epilogue.png")).convert("RGB")
viejo.resize((1280, 720), Image.LANCZOS).save(os.path.join(HERE, "context", "vigente_epilogue_t233.png"))
print("listo")
