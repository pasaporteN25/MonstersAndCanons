"""Contact sheet of the applied sprites at map and HUD sizes."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
FONT = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 19)
SMALL = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 15)
TITLE = ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf', 30)
NAMES = [
    ('Básica', 'basic'), ('Cañón', 'cannon'), ('Hielo', 'frost'),
    ('Francotirador', 'sniper'), ('Incendiaria', 'fire'), ('Múltiple', 'multi'),
    ('Ráfaga', 'burst'), ('Eléctrica', 'tesla'), ('Mortero', 'mortar'),
]


def sprite(name, size):
    return Image.open(HERE / f'{name}.png').convert('RGBA').resize((size, size), Image.Resampling.LANCZOS)


def placed(name, size, level=1):
    result = Image.new('RGBA', (size, size), '#72a650')
    result.alpha_composite(sprite(f'base_{level}', size))
    result.alpha_composite(sprite(f'turret_{name}', size))
    return result


board = Image.new('RGB', (1300, 1170), '#161e28')
draw = ImageDraw.Draw(board)
draw.text((28, 15), 'Monsters & Canons · nuevo diseño de torretas', font=TITLE, fill='#f3ead9')
draw.text((30, 61), 'Tubos cilíndricos · mecanismos propios · vista ampliada, 64 px y 34 px', font=FONT, fill='#b8ccd0')

for index, (label, asset) in enumerate(NAMES):
    col, row = index % 3, index // 3
    x, y = 26 + col * 425, 108 + row * 290
    draw.rounded_rectangle((x, y, x+396, y+270), 13, fill='#27343f')
    draw.text((x+16, y+10), label, font=FONT, fill='#f4f0e6')
    big = placed(asset, 220, 2 if asset == 'frost' else 1)
    board.paste(big, (x+15, y+48))
    draw.text((x+255, y+57), '64 px', font=SMALL, fill='#a9bac2')
    map_icon = placed(asset, 64, 2 if asset == 'frost' else 1)
    board.paste(map_icon, (x+265, y+88))
    draw.text((x+255, y+172), 'HUD 34 px', font=SMALL, fill='#a9bac2')
    hud_icon = placed(asset, 34, 2 if asset == 'frost' else 1)
    board.paste(hud_icon, (x+278, y+202))

draw.text((29, 995), 'Barra superior · emblemas de 30 px', font=FONT, fill='#f4f0e6')
draw.rounded_rectangle((26, 1027, 1270, 1097), 8, fill='#1f222b')
for index, (name, label, color) in enumerate([
    ('gold', 'Oro: 200', '#ffdc75'), ('lives', 'Vidas: 20', '#ff858a'),
    ('points', 'Puntos: 0', '#a4deff'), ('wave', 'Oleada 0/15', '#f3f4f8'),
]):
    x = 43 + index * 298
    icon = sprite(f'stat_{name}', 34)
    board.paste(icon, (x, 1045), icon)
    draw.text((x+43, 1045), label, font=FONT, fill=color)

flame = sprite('flame', 35)
board.paste(flame, (34, 1118), flame)
draw.text((77, 1122), 'Llama rediseñada (su tamaño en enemigos varía)', font=SMALL, fill='#d3c6b3')
board.save(HERE / 'vista_assets_3d.png')
board.crop((0, 0, 1300, 980)).save(HERE / 'vista_torretas_3d_v3.png')
print(HERE / 'vista_assets_3d.png')
