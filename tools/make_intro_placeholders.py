"""Genera las láminas PROVISORIAS de la intro (T242): un rectángulo de color liso de 1920 x 1080 con el
número de la lámina y la palabra PROVISORIA. T241 las reemplaza por las definitivas, con los mismos nombres.

Uso (desde la raíz del proyecto): python3 tools/make_intro_placeholders.py
"""
from PIL import Image, ImageDraw, ImageFont

NAMES = ["01_la_nave", "02_la_bodega", "03_los_turnos", "04_la_ventana", "05_el_descenso",
         "06_los_motores_apagados", "07_el_oasis"]
# Un color por lámina, según el guion de color (dominante de cada una).
COLORS = [(18, 28, 52), (92, 62, 24), (28, 52, 58), (44, 40, 60), (110, 70, 34), (60, 38, 20), (70, 120, 52)]
FONTS = ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", "DejaVuSans-Bold.ttf"]


def font(size: int) -> ImageFont.FreeTypeFont:
    for path in FONTS:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


for i, name in enumerate(NAMES):
    img = Image.new("RGB", (1920, 1080), COLORS[i])
    draw = ImageDraw.Draw(img)
    draw.rectangle((40, 40, 1879, 1039), outline=(235, 220, 180), width=6)
    draw.text((960, 400), str(i + 1), font=font(420), fill=(240, 230, 200), anchor="mm")
    draw.text((960, 700), "LÁMINA PROVISORIA", font=font(70), fill=(240, 230, 200), anchor="mm")
    img.save("assets/intro/%s.png" % name, optimize=True)
    print(name)
