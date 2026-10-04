"""Selección B del cañón y revisión C del hielo, con tamaños de juego."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
font = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',21)
small = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',16)
title = ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf',34)
board = Image.new('RGB',(1380,860),'#141c28')
d = ImageDraw.Draw(board)
d.text((30,18),'TORRES / Selección y nueva prueba de hielo',font=title,fill='#f5f0e6')
d.text((32,66),'B aplicada al cañón y las bases 1 y 3 · C es una nueva propuesta para hielo sobre piedra',font=font,fill='#a9b8be')

def img(option,name,size):
    return Image.open(HERE/f'{option}_{name}.png').convert('RGBA').resize((size,size),Image.Resampling.LANCZOS)

def card(x,y,name,option,base,turret):
    d.rounded_rectangle((x,y,x+422,y+330),14,fill='#26333e')
    d.text((x+19,y+12),name,font=font,fill='#edece5')
    big=Image.new('RGBA',(192,192),'#69a34e')
    for asset in (base,turret): big.alpha_composite(img(option,asset,192))
    board.paste(big,(x+24,y+48),big)
    d.text((x+234,y+53),'Vista ampliada',font=small,fill='#b3c4ca')
    d.text((x+234,y+146),'64 px',font=small,fill='#b3c4ca')
    d.text((x+234,y+237),'34 px',font=small,fill='#b3c4ca')
    normal=Image.new('RGBA',(64,64),'#69a34e')
    icon=Image.new('RGBA',(34,34),'#69a34e')
    for asset in (base,turret):
        normal.alpha_composite(img(option,asset,64))
        icon.alpha_composite(img(option,asset,34))
    for i in range(2):
        board.paste(normal,(x+231+i*76,y+174),normal)
        board.paste(icon,(x+237+i*52,y+268),icon)

d.text((32,111),'Elegidos',font=font,fill='#e4bc6c')
card(24,145,'B · Cañón / madera','b','base_1','turret_cannon')
card(480,145,'B · Cañón / oro','b','base_3','turret_cannon')
d.text((32,493),'Hielo rehecho',font=font,fill='#a8e6f1')
card(24,530,'Actual · Hielo / piedra','original','base_2','turret_frost')
card(480,530,'B anterior · Hielo / piedra','b','base_2','turret_frost')
card(936,530,'C nueva · Hielo / piedra','c','base_2','turret_frost')
board.save(HERE/'revision.png')
print(HERE/'revision.png')
