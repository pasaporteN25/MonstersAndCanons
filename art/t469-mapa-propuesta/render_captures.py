#!/usr/bin/env python3
"""Renderizá las capturas de revisión desde mapa.svg (Godot 4 y Pillow)."""
from pathlib import Path
import json
import subprocess
import tempfile

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
GODOT = "godot"
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT, size)


def round_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill: str, outline: str | None = None, width: int = 1) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="t469-preview-") as temp:
        temp_path = Path(temp)
        svg_path = str(HERE / "mapa.svg")
        png_path = str(temp_path / "mapa.png")
        script = temp_path / "render.gd"
        script.write_text(
            "extends SceneTree\n"
            "func _initialize() -> void:\n"
            f"\tvar file := FileAccess.open({json.dumps(svg_path)}, FileAccess.READ)\n"
            "\tvar image := Image.new()\n"
            "\tvar result := image.load_svg_from_string(file.get_as_text(), 1.0)\n"
            "\tif result != OK:\n\t\tquit(1)\n\t\treturn\n"
            f"\tif image.save_png({json.dumps(png_path)}) != OK:\n\t\tquit(1)\n\t\treturn\n"
            "\tquit()\n",
            encoding="utf-8",
        )
        subprocess.run([GODOT, "--headless", "--path", temp, "--script", str(script)], check=True)
        map_image = Image.open(png_path).convert("RGB")

    out = ROOT / "Capturas"
    out.mkdir(exist_ok=True)

    # PC: las quince regiones y la leyenda entran completas en el viewport.
    pc = Image.new("RGB", (1280, 720), "#121518")
    d = ImageDraw.Draw(pc)
    d.rectangle((0, 0, 1280, 84), fill="#1b1d20")
    d.line((0, 83, 1280, 83), fill="#634c31", width=2)
    d.text((40, 14), "T469 · Mapa planetario e insignias", font=font(26, True), fill="#f1ce7a")
    d.text((40, 51), "PC · 1280 × 720 · mapa completo, sin desborde · progreso ilustrativo", font=font(14), fill="#c4c4bc")
    round_rect(d, (24, 100, 1256, 696), 16, "#1a1d20", "#42413b", 2)
    d.text((48, 112), "Campaña · atlas", font=font(18, True), fill="#f1ce7a")
    scaled_map = map_image.resize((1184, 404), Image.Resampling.LANCZOS)
    pc.paste(scaled_map, (48, 146))
    for x, color, label in [
        (62, "#bd8240", "3 estrellas · jugador"),
        (250, "#98463b", "1–2 estrellas · insignia dividida"),
        (500, "#98463b", "0 estrellas · rebelde; candado si está bloqueada"),
    ]:
        d.ellipse((x - 8, 572, x + 8, 588), fill=color, outline="#e5d9b7", width=2)
        if x == 250:
            d.pieslice((x - 7, 573, x + 7, 587), 270, 90, fill="#bd8240")
        d.text((x + 16, 571), label, font=font(13), fill="#d7d3c7")
    d.text((48, 632), "15 zonas · recorrido en serrucho oeste→este · estados de muestra", font=font(13), fill="#aaa99f")
    pc.save(out / "t469-mapa-pc.png", optimize=True)

    # Celular: el lienzo se desplaza; ficha y acción quedan fuera de ese recorte.
    mobile = Image.new("RGB", (900, 1040), "#121518")
    d = ImageDraw.Draw(mobile)
    d.text((36, 22), "T469 · Revisión celular", font=font(30, True), fill="#f1ce7a")
    d.text((36, 63), "Marcadores táctiles conservan su tamaño; se desplaza solo el mapa.", font=font(16), fill="#c4c4bc")
    round_rect(d, (235, 105, 665, 1000), 42, "#090a0b", "#67665f", 5)
    round_rect(d, (250, 138, 650, 968), 15, "#17191c")
    d.text((270, 154), "Campaña", font=font(18, True), fill="#eee4d0")
    d.text((620, 157), "Mapa · Tarjetas", font=font(15), fill="#d1c6b0", anchor="ra")
    round_rect(d, (268, 198, 632, 648), 8, "#10181c", "#55452f", 1)
    crop = map_image.crop((0, 0, 352, 450))
    mobile.paste(crop, (280, 198))
    d = ImageDraw.Draw(mobile)
    d.text((270, 662), "Deslizá con un dedo · tocá para seleccionar", font=font(14), fill="#c7b48e")
    d.line((270, 696, 630, 696), fill="#53432f", width=2)
    d.text((270, 710), "Zona 2 · 2 estrellas", font=font(17, True), fill="#f1ce7a")
    d.text((270, 738), "Insignia mitad rebelde / mitad jugador", font=font(14), fill="#eee4d0")
    round_rect(d, (270, 783, 630, 845), 10, "#795233", "#e0ad5c", 2)
    d.text((450, 796), "Jugar", font=font(22, True), fill="#fff0cc", anchor="ma")
    d.text((450, 898), "La ficha y Jugar quedan fijos abajo.", font=font(13), fill="#9b9a91", anchor="ma")
    mobile.save(out / "t469-mapa-celular.png", optimize=True)


if __name__ == "__main__":
    main()
