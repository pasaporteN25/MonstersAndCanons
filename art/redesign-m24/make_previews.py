"""Componer hojas de revisión; conserva intactas las fuentes generadas."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
FONT = 'C:/Windows/Fonts/segoeui.ttf'
BG = '#172331'

def font(size):
    return ImageFont.truetype(FONT, size)

def sprite(path):
    im = Image.open(path).convert('RGBA')
    box = im.getchannel('A').point(lambda a: 255 if a > 24 else 0).getbbox()
    return im.crop(box) if box else im

def place(canvas, im, box):
    im = im.copy()
    im.thumbnail((box[2], box[3]), Image.Resampling.LANCZOS)
    canvas.alpha_composite(im, (int(box[0] + (box[2]-im.width)/2), int(box[1] + (box[3]-im.height)/2)))

def monsters():
    sheet = Image.new('RGBA', (1320, 1010), BG)
    d = ImageDraw.Draw(sheet)
    d.text((30,20), 'Monstruos · primera tanda', font=font(32), fill='white')
    d.text((30,65), 'A arriba · B abajo | propuestas, sin aplicar al juego', font=font(20), fill='#aabccc')
    for col, (key, label, height) in enumerate([('normal','Normal · diablillo',45),('fast','Rápido · bestia',36),('tank','Tanque · ogro',63)]):
        for row, variant in enumerate(['A','B']):
            x,y=30+col*430,115+row*435
            d.rounded_rectangle((x,y,x+410,y+415),radius=15,fill='#293d50')
            d.text((x+15,y+12),f'{label} · {variant}',font=font(21),fill='white')
            im=sprite(ROOT/'sources'/f'{key}_{variant}.png')
            place(sheet,im,(x+30,y+50,350,280))
            d.rectangle((x+15,y+350,x+395,y+400),fill='#73a650')
            for sx in (x+220,x+280,x+340):
                place(sheet,im,(sx,y+353,45,height if height<45 else 45))
            d.text((x+24,y+360),'Lectura pequeña',font=font(16),fill='#152414')
    sheet.convert('RGB').save(ROOT/'monsters_comparison.png')

def upgrades():
    sheet=Image.new('RGBA',(1320,780),BG)
    d=ImageDraw.Draw(sheet)
    d.text((30,20),'Evoluciones · refuerzos y brillo localizado',font=font(30),fill='white')
    for row,key in enumerate(['cannon','frost']):
        source=Image.open(ROOT/'sources'/f'{key}_levels.png').convert('RGBA')
        d.text((30,78+row*350),'Cañón' if row==0 else 'Hielo',font=font(24),fill='white')
        for i in range(3):
            x,y=30+i*430,120+row*350
            d.rounded_rectangle((x,y,x+410,y+300),radius=15,fill='#293d50')
            d.text((x+15,y+10),f'Nivel {i+1}',font=font(21),fill='white')
            cell=source.crop((i*source.width//3,0,(i+1)*source.width//3,source.height))
            bbox=cell.getchannel('A').point(lambda a:255 if a>24 else 0).getbbox()
            im=cell.crop(bbox)
            place(sheet,im,(x+25,y+40,350,175))
            d.rectangle((x+160,y+225,x+250,y+295),fill='#73a650')
            base=Image.open(ROOT.parent.parent/'assets/sprites/towers/rendered'/f'base_{i+1}.png').convert('RGBA')
            place(sheet,base,(x+173,y+230,64,64))
            place(sheet,im,(x+177,y+234,56,56))
    sheet.convert('RGB').save(ROOT/'upgrades_comparison.png')

if __name__=='__main__':
    monsters()
    upgrades()
