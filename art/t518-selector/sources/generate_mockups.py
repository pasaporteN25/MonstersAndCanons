from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'Capturas'
MAP = Image.open(ROOT / 'Capturas/T515-pc-1280x720-12-elegido.png').convert('RGB').crop((96, 140, 1185, 520))
CARDS = Image.open(ROOT / 'Capturas/T501-tarjetas-pc-1280x720-estados.png').convert('RGB').crop((96, 140, 1185, 603))
FONT = '/usr/share/fonts/truetype/lato/Lato-Regular.ttf'
BOLD = '/usr/share/fonts/truetype/lato/Lato-Bold.ttf'
BG = '#17191b'; PANEL = '#222529'; IRON = '#36393b'; BRONZE = '#a56e35'; GOLD = '#edc04d'; IVORY = '#eee4d1'; MUTED = '#b9b3a8'

def font(size, bold=False): return ImageFont.truetype(BOLD if bold else FONT, size)
def rounded(d, box, fill, outline=BRONZE, radius=12, width=2): d.rounded_rectangle(box, radius, fill=fill, outline=outline, width=width)
def text(d, xy, value, size=20, fill=IVORY, bold=False): d.text(xy, value, font=font(size,bold), fill=fill)
def pill(d, box, label, active=False):
    rounded(d, box, '#37332c' if active else '#27292b', GOLD if active else '#795832', 10, 2)
    x1,y1,x2,y2=box; f=font(18, active); bb=d.textbbox((0,0),label,font=f); d.text((x1+(x2-x1-(bb[2]-bb[0]))/2,y1+(y2-y1-(bb[3]-bb[1]))/2-2),label,font=f,fill=GOLD if active else IVORY)
def button(d, box, label, primary=False):
    rounded(d, box, '#9a642f' if primary else '#27292b', '#d8a15e' if primary else '#755431', 10, 2)
    x1,y1,x2,y2=box; f=font(20,True); bb=d.textbbox((0,0),label,font=f); d.text((x1+(x2-x1-(bb[2]-bb[0]))/2,y1+(y2-y1-(bb[3]-bb[1]))/2-2),label,font=f,fill=IVORY)
def panel_image(im, src, box, radius=10):
    x1,y1,x2,y2=box; crop=src.copy(); crop.thumbnail((x2-x1,y2-y1),Image.Resampling.LANCZOS)
    canvas=Image.new('RGB',(x2-x1,y2-y1), '#26282a'); canvas.paste(crop,((canvas.width-crop.width)//2,(canvas.height-crop.height)//2))
    mask=Image.new('L',canvas.size); ImageDraw.Draw(mask).rounded_rectangle((0,0,canvas.width-1,canvas.height-1),radius,fill=255)
    im.paste(canvas,(x1,y1),mask)

def base(w,h):
    im=Image.new('RGB',(w,h),BG); d=ImageDraw.Draw(im)
    for y in range(0,h,46): d.line((0,y,w,y),fill='#1b1e20',width=1)
    return im,d

def desktop(mode):
    w,h=1280,720; im,d=base(w,h)
    if mode=='command':
        text(d,(34,24),'MONSTERS & CANONS',16,GOLD,True); text(d,(34,49),'Elegir nivel',34,IVORY,True)
        text(d,(1040,34),'20 / 45 ★',20,GOLD,True)
        rounded(d,(24,102,1256,680),PANEL,'#6e5133',16)
        # rail
        for i,(lab,act) in enumerate([('Campaña',1),('Asedio',0),('Mapas de la comunidad',0)]): pill(d,(42,128+i*56,210,174+i*56),lab,bool(act))
        text(d,(42,378),'VISTA',13,MUTED,True); pill(d,(42,403,210,447),'Mapa',True); pill(d,(42,458,210,502),'Tarjetas')
        panel_image(im,MAP,(236,124,1004,624)); d=ImageDraw.Draw(im); rounded(d,(236,124,1004,624),None,'#775633',10,2)
        rounded(d,(1020,124,1238,624),'#292b2d','#59452e',12)
        text(d,(1040,150),'NIVEL ELEGIDO',13,GOLD,True); text(d,(1040,184),'12 · El cañadón',22,IVORY,True); text(d,(1040,224),'Disponible',17,'#b6c9a1'); text(d,(1040,266),'Mejor resultado',14,MUTED); text(d,(1040,292),'Sin victorias',17,IVORY)
        button(d,(1040,530,1218,584),'Jugar',True); text(d,(1040,596),'← Menú',16,MUTED)
        title='MESA DE MANDO · navegación lateral y detalle persistente'
    elif mode=='frame':
        text(d,(42,24),'Elegir nivel',32,IVORY,True); text(d,(1060,31),'Campaña · 20 de 45',18,GOLD,True)
        rounded(d,(24,82,1256,678),PANEL,'#6e5133',16)
        for x,lab,act in [(48,'Campaña',1),(176,'Asedio',0),(284,'Mapas de la comunidad',0)]: pill(d,(x,100,x+(122 if lab=='Campaña' else 220 if lab.startswith('Mapas') else 104),146),lab,bool(act))
        text(d,(770,112),'Mostrar:',16,MUTED); pill(d,(860,100,966,146),'Mapa',True); pill(d,(978,100,1110,146),'Tarjetas')
        panel_image(im,MAP,(48,164,1232,574)); d=ImageDraw.Draw(im); rounded(d,(48,164,1232,574),None,'#775633',10,2)
        rounded(d,(48,590,1232,650),'#292b2d','#805a32',10)
        text(d,(70,604),'12  ·  El cañadón',23,IVORY,True); text(d,(400,610),'Disponible  ·  Sin victorias todavía',17,MUTED)
        button(d,(1030,596,1208,644),'Jugar',True)
        title='BASTIDOR DE CAMPAÑA · jerarquía central con pie contextual'
    else:
        text(d,(34,24),'Elegir nivel',28,IVORY,True); pill(d,(1038,20,1236,66),'20 de 45',True)
        panel_image(im,MAP,(24,80,1256,640)); d=ImageDraw.Draw(im); rounded(d,(24,80,1256,640),None,'#775633',10,2)
        rounded(d,(42,98,500,150),'#202326','#83603b',10)
        for x,lab,act in [(54,'Campaña',1),(178,'Asedio',0),(286,'Comunidad',0)]: pill(d,(x,104,x+(116 if lab=='Campaña' else 112),144),lab,bool(act))
        rounded(d,(42,500,458,616),'#202326','#805a32',12)
        text(d,(62,520),'12 · El cañadón',23,IVORY,True); text(d,(62,558),'Disponible · Sin victorias',16,MUTED)
        button(d,(1000,574,1228,630),'Jugar  →',True); pill(d,(1012,92,1114,138),'Mapa',True); pill(d,(1120,92,1228,138),'Tarjetas',False)
        rounded(d,(24,652,1256,700),'#222529','#5b452e',10); text(d,(48,665),'← Menú',17,MUTED); text(d,(1008,665),'Campaña · Zona 3',17,GOLD)
        title='LIENZO PRIMERO · el mapa ocupa el foco con controles flotantes'
    d=ImageDraw.Draw(im); d.rectangle((0,700,1280,720),fill=BG); text(d,(32,701),title,12,'#c7bca9')
    return im

def mobile(mode):
    w,h=720,1280; im,d=base(w,h)
    text(d,(28,24),'Elegir nivel',30,IVORY,True); text(d,(28,66),'Campaña · 20 de 45',17,GOLD,True)
    if mode=='command':
        rounded(d,(18,112,702,1248),PANEL,'#6e5133',16)
        for i,(lab,act) in enumerate([('Campaña',1),('Asedio',0),('Mapas de la comunidad',0)]): pill(d,(36,136+i*52,684,180+i*52),lab,bool(act))
        text(d,(38,366),'VISTA',13,MUTED,True); pill(d,(36,389,350,432),'Mapa',True); pill(d,(366,389,684,432),'Tarjetas')
        panel_image(im,MAP,(36,450,684,738)); d=ImageDraw.Draw(im); rounded(d,(36,450,684,738),None,'#775633',10,2)
        rounded(d,(36,756,684,968),'#292b2d','#59452e',12); text(d,(58,776),'NIVEL ELEGIDO',13,GOLD,True); text(d,(58,810),'12 · El cañadón',24,IVORY,True); text(d,(58,850),'Disponible · Sin victorias',17,MUTED); button(d,(58,884,662,942),'Jugar',True)
        pill(d,(36,990,684,1042),'← Volver al menú')
    elif mode=='frame':
        rounded(d,(18,112,702,1248),PANEL,'#6e5133',16)
        pill(d,(36,132,214,178),'Campaña',True); pill(d,(224,132,360,178),'Asedio'); pill(d,(370,132,684,178),'Mapas comunidad')
        pill(d,(36,190,350,234),'Mapa',True); pill(d,(366,190,684,234),'Tarjetas')
        panel_image(im,MAP,(36,252,684,540)); d=ImageDraw.Draw(im); rounded(d,(36,252,684,540),None,'#775633',10,2)
        rounded(d,(36,560,684,736),'#292b2d','#805a32',10); text(d,(60,582),'12 · El cañadón',24,IVORY,True); text(d,(60,624),'Disponible · Sin victorias todavía',17,MUTED)
        button(d,(36,756,684,822),'Jugar',True); pill(d,(36,840,684,892),'← Volver al menú')
    else:
        panel_image(im,MAP,(18,112,702,702)); d=ImageDraw.Draw(im); rounded(d,(18,112,702,702),None,'#775633',10,2)
        rounded(d,(34,128,686,184),'#202326','#83603b',10); pill(d,(44,134,246,178),'Campaña',True); pill(d,(256,134,410,178),'Asedio'); pill(d,(420,134,676,178),'Mapas')
        rounded(d,(36,500,420,674),'#202326','#805a32',12); text(d,(54,518),'12 · El cañadón',22,IVORY,True); text(d,(54,556),'Disponible',16,MUTED); text(d,(54,588),'Sin victorias todavía',15,MUTED)
        button(d,(36,732,684,800),'Jugar  →',True); pill(d,(36,822,684,870),'Cambiar a tarjetas'); pill(d,(36,884,684,932),'← Menú')
    d=ImageDraw.Draw(im); text(d,(28,1230),{'command':'MESA DE MANDO','frame':'BASTIDOR DE CAMPAÑA','field':'LIENZO PRIMERO'}[mode],12,'#c7bca9')
    return im

for key in ('command','frame','field'):
    desktop(key).save(OUT/f'T518-{key}-pc.png',optimize=True)
    mobile(key).save(OUT/f'T518-{key}-mobile.png',optimize=True)
