"""Comparativa a escala de juego e interfaz a partir de los renders de Godot."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
font = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 19)
small = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 15)
heading = ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf', 33)

W, H = 1440, 1110
board = Image.new('RGB', (W, H), '#141c28')
draw = ImageDraw.Draw(board)
draw.text((34, 22), 'TORRES / Pruebas de volumen', font=heading, fill='#f1eee5')
draw.text((36, 70), 'SVG de 64 × 64  ·  mismo centro de giro  ·  ejemplos sin aplicar al juego', font=font, fill='#9caeb7')

items = [('base_1','Madera · nivel 1'),('base_2','Piedra · nivel 2'),('base_3','Oro · nivel 3')]
options = [('original','Actual'),('a','A · facetas'),('b','B · bisel suave')]

def asset(option, name, size):
    im = Image.open(HERE/f'{option}_{name}.png').convert('RGBA')
    return im.resize((size,size),Image.Resampling.LANCZOS)

def sample(x,y,option,base,turret):
    draw.rounded_rectangle((x,y,x+430,y+285),15,fill='#25323d')
    draw.text((x+18,y+11),dict(options)[option],font=font,fill='#e9e8e0')
    # The 64px scene is shown at 3x for inspection, while the bottom strip uses
    # the real game size and the approximate HUD button size.
    tile=Image.new('RGBA',(192,192),'#69a34e')
    for name in (base,turret):
        im=asset(option,name,192)
        tile.alpha_composite(im)
    board.paste(tile,(x+32,y+49),tile)
    draw.text((x+235,y+59),'64 px en el juego',font=small,fill='#c0cdd0')
    draw.rounded_rectangle((x+235,y+89,x+395,y+157),8,fill='#587f47')
    for i in range(2):
        mini=Image.new('RGBA',(64,64),'#69a34e')
        for name in (base,turret):
            mini.alpha_composite(asset(option,name,64))
        board.paste(mini,(x+243+i*73,y+91),mini)
    draw.text((x+235,y+183),'34 px en interfaz',font=small,fill='#c0cdd0')
    mini=Image.new('RGBA',(34,34),'#69a34e')
    for name in (base,turret):
        mini.alpha_composite(asset(option,name,34))
    for i in range(3):
        board.paste(mini,(x+237+i*50,y+214),mini)

rows=[('Cañón sobre madera','base_1','turret_cannon'),
      ('Cañón sobre piedra dorada','base_3','turret_cannon'),
      ('Hielo sobre piedra','base_2','turret_frost')]
for j,(title,base,turret) in enumerate(rows):
    y=114+j*324
    draw.text((36,y),title,font=font,fill='#e5e5de')
    for i,(option,_) in enumerate(options):
        sample(27+i*468,y+30,option,base,turret)

board.save(HERE/'comparativa.png')
print(HERE/'comparativa.png')
