"""Hojas de comparación y reproducción de los cuadros de atlas ya empaquetados."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
FONT = 'C:/Windows/Fonts/segoeui.ttf'

def font(size):
    return ImageFont.truetype(FONT, size)

def place(canvas, source, x, y, w, h):
    im=source.copy()
    im.thumbnail((w,h),Image.Resampling.LANCZOS)
    canvas.alpha_composite(im,(int(x+(w-im.width)/2),int(y+(h-im.height)/2)))

def walk_preview():
    atlases=[Image.open(ROOT/'atlases'/f'{id}_walk.png').convert('RGBA') for id in ['normal','fast','tank']]
    frames=[]
    for column in range(4):
        canvas=Image.new('RGBA',(1040,690),'#172331')
        d=ImageDraw.Draw(canvas)
        d.text((25,15),'Animaciones · cuatro direcciones',font=font(27),fill='white')
        d.text((25,53),'Cuadros a ritmo común para comparar · integración pendiente',font=font(17),fill='#aabccc')
        for col,title in enumerate(['Diablillo rojo','Bestia turquesa','Ogro de piedra']):
            d.text((180+col*280,90),title,font=font(20),fill='white')
            for row,direction in enumerate(['Este','Sur','Oeste','Norte']):
                x,y=150+col*280,122+row*137
                if col==0:
                    d.text((25,y+50),direction,font=font(20),fill='white')
                d.rounded_rectangle((x,y,x+255,y+128),radius=10,fill='#293d50')
                region=atlases[col].crop((column*256,row*256,(column+1)*256,(row+1)*256))
                place(canvas,region,x+8,y,128,128)
                d.rectangle((x+157,y+25,x+243,y+112),fill='#73a650')
                size=[45,36,63][col]
                place(canvas,region,x+157,y+30,86,size)
        frames.append(canvas.convert('RGB'))
    frames[0].save(ROOT/'walks_preview.gif',save_all=True,append_images=frames[1:],duration=130,loop=0,disposal=2)
    frames[0].save(ROOT/'walks_comparison.png')

def concepts():
    canvas=Image.new('RGBA',(1320,960),'#172331')
    d=ImageDraw.Draw(canvas)
    d.text((30,20),'Monstruos · segunda tanda',font=font(32),fill='white')
    d.text((30,65),'Cinco propuestas nuevas · no aplicadas al juego',font=font(20),fill='#aabccc')
    titles=[('armored','Blindado · escarabajo'),('troll','Troll · regenerativo'),('flyer','Volador · gárgola'),('spider','Araña · madre'),('spiderling','Cría · arácnida')]
    for i,(id,title) in enumerate(titles):
        x,y=30+(i%3)*430,110+(i//3)*410
        d.rounded_rectangle((x,y,x+410,y+385),radius=15,fill='#293d50')
        d.text((x+15,y+12),title,font=font(22),fill='white')
        im=Image.open(ROOT/'sources'/f'{id}_concept.png').convert('RGBA')
        bounds=im.getchannel('A').getbbox()
        if bounds:
            im=im.crop(bounds)
        place(canvas,im,x+25,y+50,360,260)
        d.rectangle((x+15,y+320,x+395,y+370),fill='#73a650')
        d.text((x+25,y+335),'Lectura pequeña',font=font(16),fill='#152414')
        for j in range(3):
            place(canvas,im,x+210+j*59,y+321,48,48)
    d.text((920,600),'Misma cámara, luz y volumen',font=font(22),fill='white')
    d.text((920,644),'Revisar antes de animar',font=font(19),fill='#aabccc')
    canvas.convert('RGB').save(ROOT/'physical_monsters.png')

if __name__=='__main__':
    walk_preview()
    if (ROOT/'sources/spiderling_concept.png').exists():
        concepts()
