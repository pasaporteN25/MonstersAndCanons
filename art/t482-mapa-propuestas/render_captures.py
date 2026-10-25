#!/usr/bin/env python3
"""Renderiza dos propuestas de costa sobre el marco original de T428."""
from pathlib import Path
import json
import subprocess
import tempfile

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
ART = Path(__file__).resolve().parent
OUT = ROOT / "Capturas"


def rasterize(svg_path: Path, temp: Path) -> Image.Image:
    png = temp / f"{svg_path.stem}.png"
    script = temp / f"{svg_path.stem}.gd"
    script.write_text(
        "extends SceneTree\nfunc _initialize() -> void:\n"
        f"\tvar f := FileAccess.open({json.dumps(str(svg_path))}, FileAccess.READ)\n"
        "\tvar image := Image.new()\n"
        "\tvar result := image.load_svg_from_string(f.get_as_text(), 1.0)\n"
        "\tif result != OK:\n\t\tquit(1)\n\t\treturn\n"
        f"\tif image.save_png({json.dumps(str(png))}) != OK:\n\t\tquit(1)\n\t\treturn\n"
        "\tquit()\n",
        encoding="utf-8",
    )
    subprocess.run(["godot", "--headless", "--path", str(temp), "--script", str(script)], check=True)
    return Image.open(png).convert("RGB")


def make_screen(map_image: Image.Image, output: Path) -> None:
    screen = Image.open(ROOT / "art/t428-mapa-propuesta/captura_producto_1280x720.png").convert("RGB")
    screen.paste(map_image.resize((996, 377), Image.Resampling.LANCZOS), (142, 142))
    draw = ImageDraw.Draw(screen)
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    font_bold = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
    draw.text((153, 150), "ATLAS MERIDIANO · CÁNTARO", font=ImageFont.truetype(font_path, 10), fill="#e3d6b6")
    draw.rounded_rectangle((952, 148, 1167, 227), radius=2, fill="#1a1d20", outline="#805b38", width=1)
    for y, color, label in [
        (168, "#bd8240", "3 estrellas · jugador"),
        (190, "#98463b", "1–2 estrellas · parcial"),
        (212, "#525a5b", "Sin victoria · sin acceso"),
    ]:
        draw.ellipse((961, y - 7, 975, y + 7), fill=color, outline="#ded3b6", width=1)
        draw.text((981, y - 7), label, font=ImageFont.truetype(font_path, 11), fill="#ded8cb")
    # Godot no rasteriza el texto de los SVG; repone los números a escala de la captura.
    labels = [(150, 260), (225, 245), (300, 273), (375, 220), (450, 270), (525, 285), (600, 238), (675, 275), (750, 300), (825, 230), (900, 270), (975, 300), (1050, 225), (1125, 260), (1200, 260)]
    for number, (x, y) in enumerate(labels, start=1):
        fill = "#25241f" if number == 1 else "#282522" if number == 2 else "#fff0c7" if number == 3 else "#fff0c7"
        size = 17 if number < 10 else 15
        draw.text((142 + x * .755, 142 + y * .838), str(number), font=ImageFont.truetype(font_bold, size), fill=fill, anchor="mm")
    screen.save(output, optimize=True)


def main() -> None:
    OUT.mkdir(exist_ok=True)
    original = ROOT / "art/t428-mapa-propuesta/captura_producto_1280x720.png"
    Image.open(original).convert("RGB").save(OUT / "T482-mapa-original-T428.png", optimize=True)
    with tempfile.TemporaryDirectory(prefix="t482-mapa-preview-") as tmp:
        temp = Path(tmp)
        for name, svg in [("A", "mapa-a.svg"), ("B", "mapa-b.svg")]:
            image = rasterize(ART / svg, temp)
            make_screen(image, OUT / f"T482-mapa-propuesta-{name}.png")


if __name__ == "__main__":
    main()
