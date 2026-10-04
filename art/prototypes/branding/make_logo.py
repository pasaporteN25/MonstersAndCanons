"""Logo de muestra. Genera una imagen transparente y una lámina de revisión."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
SCALE = 2
W, H = 1600 * SCALE, 470 * SCALE
INK = '#20242f'
GOLD = '#e5b653'
IVORY = '#f5f0df'
RED = '#b8493f'
font_path = 'C:/Windows/Fonts/bahnschrift.ttf'

logo = Image.new('RGBA', (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(logo)

def xy(seq):
    return [(int(x * SCALE), int(y * SCALE)) for x,y in seq]

# Small emblem: two monster horns above a cannon wheel and barrel.
d.rounded_rectangle((22*SCALE,24*SCALE,360*SCALE,442*SCALE), radius=82*SCALE,
                    fill=INK, outline=GOLD, width=10*SCALE)
d.polygon(xy([(82,176),(90,73),(145,137),(173,101),(192,161)]),fill=IVORY)
d.polygon(xy([(240,161),(269,96),(295,139),(318,73),(321,175)]),fill=IVORY)
d.ellipse((83*SCALE,134*SCALE,302*SCALE,316*SCALE),fill='#42505f',outline=INK,width=8*SCALE)
d.polygon(xy([(139,198),(252,185),(218,217),(153,227)]),fill=RED)
d.polygon(xy([(232,186),(306,185),(319,201),(306,217),(221,216)]),fill=GOLD)
d.rectangle((292*SCALE,184*SCALE,327*SCALE,219*SCALE),fill='#536171',outline=INK,width=5*SCALE)
d.ellipse((108*SCALE,271*SCALE,266*SCALE,418*SCALE),fill='#303c4c',outline=GOLD,width=12*SCALE)
d.ellipse((158*SCALE,315*SCALE,216*SCALE,371*SCALE),fill=GOLD,outline=INK,width=6*SCALE)

font_top = ImageFont.truetype(font_path, 171*SCALE)
font_bottom = ImageFont.truetype(font_path, 155*SCALE)
text_x = 420*SCALE
d.text((text_x,40*SCALE),'Monsters',font=font_top,fill=IVORY,
       stroke_width=4*SCALE,stroke_fill=INK)
d.text((text_x,207*SCALE),'& Canons',font=font_bottom,fill=GOLD,
       stroke_width=4*SCALE,stroke_fill=INK)
d.rounded_rectangle((text_x,409*SCALE,1520*SCALE,421*SCALE),
                    radius=5*SCALE,fill=GOLD)

logo=logo.resize((1600,470),Image.Resampling.LANCZOS)
logo.save(HERE/'monsters_canons_logo.png')

preview=Image.new('RGB',(1600,1060),'#1b2532')
pd=ImageDraw.Draw(preview)
label_font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',28)
pd.text((50,35),'Logo en fondo oscuro',font=label_font,fill='#aebdc4')
preview.paste(logo,(0,75),logo)
pd.rounded_rectangle((30,565,1570,1020),26,fill='#6ca24e')
pd.text((50,570),'Logo en fondo de juego',font=label_font,fill='#263b2d')
preview.paste(logo,(0,610),logo)
preview.save(HERE/'vista_logo.png')
print('Logo y vista previa guardados en', HERE)
