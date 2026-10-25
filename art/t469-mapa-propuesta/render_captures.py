#!/usr/bin/env python3
"""Rasterizá el mapa vectorial y reemplazá solo el área del mapa T428."""
from pathlib import Path
import json
import subprocess
import tempfile

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT, size)


def round_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill: str, outline: str | None = None, width: int = 1) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def rasterize(svg_path: Path, temp_path: Path) -> Image.Image:
    png_path = temp_path / f"{svg_path.stem}.png"
    script = temp_path / f"{svg_path.stem}.gd"
    script.write_text(
        "extends SceneTree\n"
        "func _initialize() -> void:\n"
        f"\tvar file := FileAccess.open({json.dumps(str(svg_path))}, FileAccess.READ)\n"
        "\tvar image := Image.new()\n"
        "\tvar result := image.load_svg_from_string(file.get_as_text(), 1.0)\n"
        "\tif result != OK:\n\t\tquit(1)\n\t\treturn\n"
        f"\tif image.save_png({json.dumps(str(png_path))}) != OK:\n\t\tquit(1)\n\t\treturn\n"
        "\tquit()\n",
        encoding="utf-8",
    )
    subprocess.run(["godot", "--headless", "--path", str(temp_path), "--script", str(script)], check=True)
    image = Image.open(png_path).convert("RGB")
    # Godot no rasteriza los textos SVG; se dibujan los números en su posición vectorial.
    draw = ImageDraw.Draw(image)
    for level, (x, y) in enumerate([
        (112, 266), (194, 254), (276, 296), (358, 235), (440, 278),
        (522, 310), (604, 246), (686, 286), (768, 314), (850, 250),
        (932, 291), (1014, 318), (1096, 245), (1178, 283), (1260, 308),
    ], start=1):
        color = "#25241f" if level == 1 else "#282522" if level == 2 else "#fff0c7" if level == 3 else "#c7cbc2"
        draw.text((x, y), str(level), font=font(22, True), fill=color, anchor="mm")
    return image


def pc_capture(map_image: Image.Image, output: Path) -> None:
    pc = Image.open(ROOT / "art/t428-mapa-propuesta/captura_producto_1280x720.png").convert("RGB")
    pc.paste(map_image.resize((996, 377), Image.Resampling.LANCZOS), (142, 142))
    d = ImageDraw.Draw(pc)
    d.text((154, 151), "ATLAS MERIDIANO · CÁNTARO", font=font(10), fill="#e3d6b6")
    round_rect(d, (952, 148, 1167, 227), 2, "#1a1d20", "#805b38", 1)
    for y, color, label in [
        (168, "#bd8240", "3 estrellas · jugador"),
        (190, "#98463b", "1–2 estrellas · parcial"),
        (212, "#525a5b", "Sin victoria · sin acceso"),
    ]:
        d.ellipse((961, y - 7, 975, y + 7), fill=color, outline="#ded3b6", width=1)
        d.text((981, y - 7), label, font=font(11), fill="#ded8cb")
    pc.save(output, optimize=True)


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="t469-preview-") as temp:
        temp_path = Path(temp)
        map_images = {
            "a": rasterize(HERE / "mapa.svg", temp_path),
            "b": rasterize(HERE / "mapa-opcion-b.svg", temp_path),
            "c": rasterize(HERE / "mapa-opcion-c.svg", temp_path),
        }

    out = ROOT / "Capturas"
    out.mkdir(exist_ok=True)

    # Tres alternativas comparables: todo sigue igual salvo la forma de la costa.
    for option, image in map_images.items():
        pc_capture(image, out / f"T469-geografia-{option.upper()}.png")
    map_image = map_images["a"]
    pc_capture(map_image, out / "t469-mapa-pc.png")

    # Celular: el mismo mapa ilustrado, con desplazamiento horizontal; ficha y acción fijas.
    mobile = Image.new("RGB", (900, 1040), "#121518")
    d = ImageDraw.Draw(mobile)
    d.text((36, 22), "T469 · Revisión celular", font=font(30, True), fill="#f1ce7a")
    d.text((36, 63), "Se conserva el atlas de T428; cambia la geografía.", font=font(16), fill="#c4c4bc")
    round_rect(d, (235, 105, 665, 1000), 42, "#090a0b", "#67665f", 5)
    round_rect(d, (250, 138, 650, 968), 15, "#17191c")
    d.text((270, 154), "Campaña", font=font(18, True), fill="#eee4d0")
    d.text((630, 157), "Mapa · Tarjetas", font=font(15), fill="#d1c6b0", anchor="ra")
    map_mobile = map_image.resize((1320, 450), Image.Resampling.LANCZOS)
    viewport = Image.new("RGB", (364, 348), "#10181c")
    viewport.paste(map_mobile.crop((0, 0, 364, 348)))
    mobile.paste(viewport, (268, 198))
    d = ImageDraw.Draw(mobile)
    round_rect(d, (268, 198, 632, 546), 8, None, "#55452f", 1)
    d.text((270, 558), "Deslizá el mapa · tocá para seleccionar", font=font(14), fill="#c7b48e")
    d.line((270, 588, 630, 588), fill="#53432f", width=2)
    d.text((270, 604), "Zona 2 · 2 estrellas", font=font(17, True), fill="#f1ce7a")
    d.text((270, 632), "Insignia mitad rebelde / mitad jugador", font=font(14), fill="#eee4d0")
    round_rect(d, (270, 680, 630, 742), 10, "#795233", "#e0ad5c", 2)
    d.text((450, 693), "Jugar", font=font(22, True), fill="#fff0cc", anchor="ma")
    d.text((450, 900), "La ficha y Jugar quedan fijos abajo.", font=font(13), fill="#9b9a91", anchor="ma")
    mobile.save(out / "t469-mapa-celular.png", optimize=True)


if __name__ == "__main__":
    main()
