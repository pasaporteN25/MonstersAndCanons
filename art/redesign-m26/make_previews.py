"""Hojas de revisión con recursos preparados; no modifica las fuentes."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parent
FONT='C:/Windows/Fonts/segoeui.ttf'
THEMES=['pradera','desierto','nieve','volcan','bosque','pantano','ruinas']

def font(size):
    return ImageFont.truetype(FONT,size)

def texture(name):
    return Image.open(ROOT/'textures'/f'{name}.png').convert('RGBA').resize((64,64),Image.Resampling.LANCZOS)

def place(canvas,im,x,y,w,h):
    im=im.copy()
    im.thumbnail((w,h),Image.Resampling.LANCZOS)
    canvas.alpha_composite(im,(int(x+(w-im.width)/2),int(y+(h-im.height)/2)))

def terrain_sheet():
    sheet=Image.new('RGBA',(1400,950),'#172331')
    d=ImageDraw.Draw(sheet)
    d.text((30,20),'Fondos · siete paisajes y camino',font=font(30),fill='white')
    d.text((30,62),'Texturas a 64 px · repetición 4×4 · unidades para comparar contraste',font=font(19),fill='#aabccc')
    path=texture('path')
    for i,name in enumerate(THEMES+['path']):
        x,y=30+(i%4)*343,108+(i//4)*412
        d.rounded_rectangle((x,y,x+320,y+393),radius=15,fill='#293d50')
        d.text((x+20,y+12),name.capitalize() if name!='path' else 'Camino común',font=font(23),fill='white')
        tile=texture('ground_'+name) if name!='path' else path
        for row in range(4):
            for col in range(4):
                sheet.alpha_composite(tile,(x+32+col*64,y+52+row*64))
        for col in range(4):
            sheet.alpha_composite(path,(x+32+col*64,y+308))
        for j,id in enumerate(['normal','fast','tank']):
            portrait=Image.open(ROOT.parent.parent/'assets/sprites/enemies/rendered'/f'{id}.png').convert('RGBA')
            place(sheet,portrait,x+47+j*77,y+312,50,50)
    sheet.convert('RGB').save(ROOT/'terrain_sheet.png')

def prop_sheet():
    sheet=Image.new('RGBA',(1320,840),'#172331')
    d=ImageDraw.Draw(sheet)
    d.text((30,20),'Decoración · piedra, vegetación y salida',font=font(30),fill='white')
    d.text((30,62),'Ampliado y a 64 px · marco de 128×128 con alfa',font=font(19),fill='#aabccc')
    ground=texture('ground_pradera')
    for i,(name,label) in enumerate([('rock_a','Rocas · grupo'),('rock_b','Rocas · bloque bajo'),('tree','Árbol'),('bush','Arbusto'),('gate','Puerta de salida')]):
        x,y=30+(i%3)*430,108+(i//3)*354
        d.rounded_rectangle((x,y,x+410,y+333),radius=15,fill='#293d50')
        d.text((x+18,y+12),label,font=font(22),fill='white')
        im=Image.open(ROOT/'props'/f'{name}.png').convert('RGBA')
        place(sheet,im,x+70,y+43,270,220)
        for j in range(3):
            sheet.alpha_composite(ground,(x+105+j*64,y+263))
            place(sheet,im,x+105+j*64,y+263,64,64)
    d.text((925,560),'La decoración no cambia',font=font(22),fill='white')
    d.text((925,603),'rutas ni construcción.',font=font(22),fill='white')
    sheet.convert('RGB').save(ROOT/'props_sheet.png')

if __name__=='__main__':
    terrain_sheet()
    prop_sheet()
