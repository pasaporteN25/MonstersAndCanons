#!/usr/bin/env python3
"""Compone la muestra estática sobre la captura T428; no abre el proyecto del juego."""
from pathlib import Path
import json
import subprocess
import tempfile
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
ART = Path(__file__).resolve().parent
OUT = ROOT / 'Capturas'
FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
POINTS = json.loads((ART / 'route_points.json').read_text())


def font(size: int, bold: bool = False):
    return ImageFont.truetype(BOLD if bold else FONT, size)


def rasterize() -> Image.Image:
    with tempfile.TemporaryDirectory(prefix='t483-svg-') as temporary:
        temp = Path(temporary)
        png = temp / 'route.png'
        script = temp / 'render.gd'
        script.write_text('extends SceneTree\nfunc _initialize() -> void:\n'
            f'\tvar file := FileAccess.open({json.dumps(str(ART / "route.svg"))}, FileAccess.READ)\n'
            '\tvar image := Image.new()\n'
            '\tif image.load_svg_from_string(file.get_as_text()) != OK:\n\t\tquit(1)\n\t\treturn\n'
            f'\tif image.save_png({json.dumps(str(png))}) != OK:\n\t\tquit(1)\n\t\treturn\n'
            '\tquit()\n')
        subprocess.run(['godot', '--headless', '--path', str(temp), '--script', str(script)], check=True)
        return Image.open(png).convert('RGB')


def point(x: float, y: float) -> tuple[float, float]:
    return (142 + (x - 20) * 996 / 1240, 142 + (y - 90) * 377 / 472)


def compose(map_image: Image.Image) -> Image.Image:
    screen = Image.open(ROOT / 'art/t428-mapa-propuesta/captura_producto_1280x720.png').convert('RGB')
    screen.paste(map_image.resize((996, 377), Image.Resampling.LANCZOS), (142, 142))
    draw = ImageDraw.Draw(screen)
    draw.text((154, 152), 'ATLAS MERIDIANO · CÁNTARO', font=font(11), fill='#e2d7b9')
    for number, (x, y) in enumerate(POINTS['nodes'], 1):
        px, py = point(x, y)
        draw.text((px, py), str(number), font=font(15 if number < 10 else 13, True), fill='#fff1cc' if number <= 3 else '#d1d7c9', anchor='mm')
    for number, name, dx, dy in [(1, 'Pradera', 0, 27), (2, 'Desfiladero', 34, 28), (3, 'Encrucijada', 14, -38)]:
        px, py = point(*POINTS['nodes'][number-1])
        draw.text((px + dx, py + dy), f'{number} · {name}', font=font(10), fill='#ecd68c', anchor='mt', stroke_width=1, stroke_fill='#344437')
    px, py = point(*POINTS['landing'])
    draw.text((px, py+25), 'ATERRIZAJE', font=font(9), fill='#ead293', anchor='mt', stroke_width=1, stroke_fill='#344437')
    px, py = point(1208, 524)
    draw.text((px, py-21), 'N', font=font(10), fill='#e2d7b9', anchor='mb')
    draw.rectangle((952, 148, 1167, 226), fill='#1f2325', outline='#805b38', width=2)
    for y, fill, label in [(166, '#a98039', '3 estrellas'), (188, '#955239', '1–2 estrellas'), (210, '#3e4c4b', 'Sin acceso')]:
        draw.ellipse((963, y-7, 977, y+7), fill=fill, outline='#d5c697', width=1)
        draw.text((986, y-6), label, font=font(11), fill='#e3decd')
    draw.rectangle((107, 534, 600, 565), fill='#1c1f21')
    draw.text((114, 539), '3 · Encrucijada', font=font(24), fill='#eee8dc')
    return screen


def annotate(screen: Image.Image) -> None:
    canvas = Image.new('RGB', (1280, 760), '#181d20')
    draw = ImageDraw.Draw(canvas)
    draw.text((24, 20), 'Recorrido propuesto · lectura de los tramos', font=font(23,True), fill='#ead9b0')
    map_preview = screen.crop((142,142,1138,519)).resize((1244,471),Image.Resampling.LANCZOS)
    canvas.paste(map_preview,(18,65))
    draw = ImageDraw.Draw(canvas)
    parts=[((177,310),'Acceso en tierra',['El módulo baja al llano oeste.','Se conserva la costa original.']),
           ((443,262),'Falda occidental',['1–4 avanzan hacia el interior.','El giro se extiende entre nodos.']),
           ((645,427),'Rodeo central amplio',['5–9 rodean hacia el sur.','Una única inflexión amplia.']),
           ((1000,287),'Corredor oriental',['10–15 retoman el avance al este.','La llegada queda junto a la costa.'])]
    for index,(geo,title,details) in enumerate(parts,1):
        px=18+(geo[0]-20)*1244/1240
        py=65+(geo[1]-90)*471/472
        draw.ellipse((px-31,py-31,px+31,py+31),outline='#ddc687',width=2)
        draw.ellipse((px+16,py-40,px+40,py-16),fill='#d8bd78',outline='#263235',width=2)
        draw.text((px+28,py-28),str(index),font=font(12,True),fill='#20292b',anchor='mm')
        tx=24+(index-1)*315
        draw.text((tx,570),f'{index}. {title}',font=font(16,True),fill='#ead9b0')
        for y,line in zip([602,627],details):
            draw.text((tx,y),line,font=font(13),fill='#d0d5cb')
    draw.line((24,676,1256,676),fill='#4f584d',width=1)
    draw.text((24,699),'Costa, mar, relieve y ríos: T428 sin cambios. Las marcas solo explican la muestra.',font=font(15),fill='#d0d5cb')
    canvas.save(OUT/'T483-lectura-geografica.png',optimize=True)


def main() -> None:
    screen=compose(rasterize())
    screen.save(OUT/'T483-propuesta-recorrido.png',optimize=True)
    annotate(screen)


if __name__ == '__main__':
    main()
