"""Hoja de revisión de recursos finales: composición, escala de mapa e iconos."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
ASSETS = ROOT / 'assets/sprites'
NAMES = [('Básica', 'basic', 'B · Industrial'), ('Cañón', 'cannon', 'A · Fantasía'), ('Hielo', 'frost', 'C · Arcana'),
         ('Francotirador', 'sniper', 'B · Industrial'), ('Incendiaria', 'fire', 'B · Industrial'), ('Múltiple', 'multi', 'B · Industrial'),
         ('Ráfaga', 'burst', 'B · Industrial'), ('Eléctrica', 'tesla', 'C · Arcana'), ('Mortero', 'mortar', 'A · Fantasía')]
FONT = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 19)
SMALL = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 15)
TITLE = ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf', 30)

def composed(name, size, level=1, direction=0):
    canvas = Image.new('RGBA', (128, 128), '#72a650')
    canvas.alpha_composite(Image.open(ASSETS / f'towers/rendered/base_{level}.png').convert('RGBA'))
    atlas = Image.open(ASSETS / f'towers/rendered/{name}_atlas.png').convert('RGBA')
    x, y = (direction % 4)*128, (direction // 4)*128
    canvas.alpha_composite(atlas.crop((x,y,x+128,y+128)))
    return canvas.resize((size,size), Image.Resampling.LANCZOS)

board = Image.new('RGB', (1300,1160), '#151e2b')
draw = ImageDraw.Draw(board)
draw.text((26,18), 'Monsters & Canons · tres familias, un mismo juego', font=TITLE, fill='#f5eada')
draw.text((28,64), 'Sprites PNG con ocho vistas · recursos finales usados por Godot', font=FONT, fill='#b7cad2')
for i,(label,name,family) in enumerate(NAMES):
    x,y = 26+(i%3)*425,108+(i//3)*288
    draw.rounded_rectangle((x,y,x+396,y+270),12,fill='#273646')
    draw.text((x+15,y+10),label,font=FONT,fill='#f6efdf')
    draw.text((x+228,y+14),family,font=SMALL,fill='#b8c7d6')
    board.paste(composed(name,220), (x+12,y+45))
    draw.text((x+254,y+52),'Mapa 64 px',font=SMALL,fill='#b8c7d6')
    board.paste(composed(name,64,direction=1),(x+266,y+78))
    draw.text((x+254,y+159),'HUD 34 px',font=SMALL,fill='#b8c7d6')
    board.paste(composed(name,34,direction=6),(x+280,y+187))
draw.text((27,984),'Tres niveles de base',font=FONT,fill='#f6efdf')
for i in range(3):
    board.paste(composed('cannon',112,level=i+1),(28+i*128,1020))
draw.text((456,984),'Proyectiles e impactos',font=FONT,fill='#f6efdf')
for i,(_,name,_) in enumerate(NAMES):
    im=Image.open(ASSETS/f'projectiles/rendered/{name}.png').convert('RGBA').resize((48,48),Image.Resampling.LANCZOS)
    board.paste(im,(460+i*64,1020),im)
for i,name in enumerate(['flame','frost','explosion','spark']):
    im=Image.open(ASSETS/f'effects/rendered/{name}.png').convert('RGBA').resize((56,56),Image.Resampling.LANCZOS)
    board.paste(im,(460+i*80,1080),im)
board.save(HERE/'conjunto_m23.png')

directions=Image.new('RGB',(1000,900),'#151e2b')
d=ImageDraw.Draw(directions)
d.text((22,12),'Ocho vistas · luz fija en el mundo',font=TITLE,fill='#f5eada')
for i,(label,name,_) in enumerate(NAMES):
    y=65+i*90
    d.text((20,y+25),label,font=FONT,fill='#f6efdf')
    for direction in range(8):
        directions.paste(composed(name,76,direction=direction),(190+direction*98,y))
directions.save(HERE/'direcciones_m23.png')
print(HERE/'conjunto_m23.png')
