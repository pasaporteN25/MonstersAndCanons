#!/usr/bin/env python3
"""Genera los atlas y las vistas de revisión de T362; todo se conserva en art/."""
from PIL import Image, ImageDraw, ImageFont
import math, json, os, random

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
OUT = ROOT
S = 3
SIZE = 192
COLS = 4
BG = {
    'Pradera': (94, 119, 71), 'Nieve': (139, 163, 169),
    'Volcán': (71, 54, 52), 'Desierto': (163, 127, 78),
}
TINTS = {
    'Ámbar · Ametralladora': (236, 174, 75), 'Celeste · Hielo': (106, 206, 235),
    'Violeta · Tesla': (177, 115, 232), 'Naranja · Fuego': (242, 126, 64),
    'Azul · Múltiple': (83, 145, 211),
}
WARM = (255, 246, 219)
BRASS = (232, 198, 133)

def font(n, bold=False):
    candidates = ['/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf' if bold else '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf']
    for p in candidates:
        if os.path.exists(p): return ImageFont.truetype(p, n)
    return ImageFont.load_default()

def line(draw, points, fill, width):
    draw.line([(round(x*S), round(y*S)) for x,y in points], fill=fill, width=max(1,round(width*S)), joint='curve')

def effect(level, i):
    im = Image.new('RGBA', (SIZE*S, SIZE*S), (0,0,0,0)); d=ImageDraw.Draw(im)
    t=i/7
    # Frames 1 and 8 are intentionally almost/fully empty; the light climbs and opens.
    if i in (0,7): return im.resize((SIZE,SIZE), Image.Resampling.LANCZOS)
    fade = min(1.0, (i/1.5), ((7-i)/1.5))
    yshift = (1-t)*25
    radius = (40 if level==2 else 53) + t*(20 if level==2 else 19)
    cy=100-yshift
    alpha=int(235*fade)
    # Moving open ring, tilted slightly forward to suggest it rises around the mechanism.
    box=((96-radius)*S, (cy-radius*.42)*S, (96+radius)*S, (cy+radius*.42)*S)
    d.arc(box, 10, 350, fill=(*WARM,alpha), width=(3 if level==2 else 5)*S)
    # Brass glint is a subtle highlight within neutral ivory, not a family-specific color.
    d.arc((box[0]+2*S,box[1]+2*S,box[2]-2*S,box[3]-2*S), 198, 326, fill=(*BRASS,int(alpha*.8)), width=1*S)
    # Six sparks for reinforcement; eight in a wide fan for mastery.
    count=6 if level==2 else 8
    spread=105 if level==2 else 170
    for k in range(count):
        a=math.radians(-90-spread/2 + spread*k/(count-1))
        dist=(radius+10) + (i%3)*3 + (k%2)*5 if level==2 else (radius+4) + (i%3)*2 + (k%2)
        x=96+math.cos(a)*dist; y=cy+math.sin(a)*dist*.63
        r=(2.6 if level==2 else 6.2)*(1.15 if i in (2,3,4) else .8)
        # pointed diamond glints, legible after tinting and downsampling
        d.polygon([(int(x*S),int((y-r*1.8)*S)),(int((x+r*.65)*S),int(y*S)),(int(x*S),int((y+r*1.8)*S)),(int((x-r*.65)*S),int(y*S))], fill=(*WARM,alpha))
    if level==3:
        # Second ring trails the primary by a little; narrow gaps keep the tower visible.
        r2=radius*.70
        d.arc(((96-r2)*S,(cy-r2*.38)*S,(96+r2)*S,(cy+r2*.38)*S), 18, 338, fill=(*WARM,int(alpha*.95)), width=4*S)
        # Cross-shaped peak flash, strongest at middle frames.
        flare=int(alpha*(1-abs(t-.43)*1.5))
        if flare>0:
            x=96*S; y=(cy-radius*.48)*S
            line(d,[(96,cy-radius*.48-11),(96,cy-radius*.48+11)],(*WARM,flare),3.5)
            line(d,[(89,cy-radius*.48),(103,cy-radius*.48)],(*WARM,int(flare*.82)),3)
    return im.resize((SIZE,SIZE), Image.Resampling.LANCZOS)

def tint(color, im):
    a=im.getchannel('A'); out=Image.new('RGBA',im.size,(*color,255)); out.putalpha(a); return out

def atlas(level):
    im=Image.new('RGBA',(SIZE*4,SIZE*2),(0,0,0,0))
    for i in range(8): im.alpha_composite(effect(level,i),(i%4*SIZE,i//4*SIZE))
    return im

def terrain(size, name, seed):
    base=BG[name]; im=Image.new('RGB',size,base); d=ImageDraw.Draw(im); rng=random.Random(seed)
    # subdued procedural ground texture; avoid competing with the luminous read.
    w,h=size
    for _ in range(int(w*h/1000)):
        x=rng.randrange(w); y=rng.randrange(h); rr=rng.randrange(1,max(2,w//150))
        c=tuple(max(0,min(255,v+rng.randrange(-13,14))) for v in base)
        d.ellipse((x-rr,y-rr,x+rr,y+rr),fill=c)
    return im.convert('RGBA')

def draw_tower(im, kind='Ametralladora'):
    d=ImageDraw.Draw(im,'RGBA'); w,h=im.size; cx=w//2; cy=h//2+4
    scale=min(w,h)/100
    def poly(points, fill, outline=(39,34,47,255), width=2):
        p=[(int(cx+x*scale),int(cy+y*scale)) for x,y in points]
        d.polygon(p,fill=fill,outline=outline,width=max(1,int(width*scale)))
    # simple orthographic tower massing, faithful in palette/material, explicitly a mockup
    d.ellipse((cx-35*scale,cy+23*scale,cx+35*scale,cy+34*scale), fill=(20,24,23,80))
    poly([(-24,14),(-20,26),(20,26),(24,14),(16,8),(-16,8)],(99,68,47,255))
    poly([(-18,11),(-12,0),(12,0),(18,11),(12,17),(-12,17)],(126,139,126,255))
    d.ellipse((cx-13*scale,cy-22*scale,cx+13*scale,cy+7*scale),fill=(153,167,150,255),outline=(39,34,47,255),width=max(1,int(2*scale)))
    if kind=='Mortero':
        d.polygon([(cx-7*scale,cy-14*scale),(cx-18*scale,cy-38*scale),(cx+4*scale,cy-42*scale),(cx+8*scale,cy-13*scale)],fill=(75,77,72,255),outline=(39,34,47,255))
    else:
        d.rounded_rectangle((cx-4*scale,cy-18*scale,cx+38*scale,cy-8*scale),radius=max(1,int(4*scale)),fill=(78,81,75,255),outline=(39,34,47,255),width=max(1,int(2*scale)))
        d.ellipse((cx+31*scale,cy-17*scale,cx+40*scale,cy-8*scale),fill=(47,49,49,255))
    return im

def composite_preview(effect_im, tint_color, ground, tile=192, tower='Ametralladora'):
    bg=ground.resize((tile,tile),Image.Resampling.BICUBIC).convert('RGBA')
    # resize effect to a 1x1 tile frame, overlay mock tower and then light.
    e=tint(tint_color,effect_im).resize((tile,tile),Image.Resampling.LANCZOS)
    draw_tower(bg,tower); bg.alpha_composite(e)
    return bg

def save_sheets():
    for lv in (2,3): atlas(lv).save(os.path.join(OUT,f'upgrade_l{lv}.png'),optimize=True)
    # Four terrain samples, complete animation row, at both 192 px and icon size 34 px.
    for level in (2,3):
        panels=[]
        for terrain_name in BG:
            tile=Image.new('RGBA',(4*192,2*192),(25,28,31,255))
            for i in range(8):
                bg=terrain((192,192),terrain_name,100+level*8+i)
                p=composite_preview(effect(level,i),WARM,bg,192)
                tile.alpha_composite(p,(i%4*192,i//4*192))
            panels.append((terrain_name,tile))
        for terrain_name,tile in panels:
            stem=terrain_name.lower().replace('í','i').replace('á','a').replace('ó','o')
            tile.save(os.path.join(OUT,f'contact_l{level}_{stem}_192.png'),optimize=True)
            tile.resize((4*34,2*34),Image.Resampling.LANCZOS).save(os.path.join(OUT,f'contact_l{level}_{stem}_34.png'),optimize=True)
        sheet=Image.new('RGB',(4*4*192,2*192+45),(30,32,33)); d=ImageDraw.Draw(sheet)
        for q,(name,tile) in enumerate(panels):
            x=q*4*192; sheet.paste(tile.convert('RGB'),(x,45)); d.text((x+10,10),f'{name} · cuadro completo 192 px',font=font(22,True),fill=(244,233,210))
        sheet.save(os.path.join(OUT,f'contact_l{level}_192.png'),optimize=True)
        small=Image.new('RGB',(4*4*34,2*34+38),(30,32,33)); d=ImageDraw.Draw(small)
        for q,(name,tile) in enumerate(panels):
            x=q*4*34; d.text((x+2,2),name,font=font(11,True),fill=(244,233,210))
            thumb=tile.resize((4*34,2*34),Image.Resampling.LANCZOS).convert('RGB'); small.paste(thumb,(x,22))
        small.save(os.path.join(OUT,f'contact_l{level}_34.png'),optimize=True)
    # Tints: a single tint per tower as game's modulate. At frame 4 (peak read).
    sw=Image.new('RGB',(5*300,245),(30,32,33)); d=ImageDraw.Draw(sw)
    for ix,(label,color) in enumerate(TINTS.items()):
        x=ix*300; d.text((x+10,8),label,font=font(17,True),fill=(245,234,215))
        for row,level in enumerate((2,3)):
            bg=terrain((130,130),'Pradera',ix*5+row)
            p=composite_preview(effect(level,4),color,bg,130)
            sw.paste(p.convert('RGB'),(x+10+row*140,40))
            d.text((x+10+row*140,174),f'Niv. {level}',font=font(14),fill=(235,224,205))
    sw.save(os.path.join(OUT,'tints_34px.png'),optimize=True)
    # Footprint comparison: tower sized 1x1 and mortar 2x2, desktop and mobile framing.
    canvas=Image.new('RGB',(1280,750),(34,38,39)); d=ImageDraw.Draw(canvas)
    d.text((25,18),'Escala ilustrativa · Ametralladora (1×1) y Mortero (2×2)',font=font(24,True),fill=(246,232,207))
    for row,(name,level) in enumerate([('Ametralladora',2),('Mortero',3)]):
        y=70+row*335
        d.text((25,y),f'{name} · cuadro de efecto: {"120" if level==2 else "160"} px nominales',font=font(18,True),fill=(240,226,204))
        for col,(label,zoom) in enumerate([('PC · 70 %',.70),('Celular · 150 %',1.5)]):
            x=28+col*620; top=y+36; view_w,view_h=570,260
            d.rounded_rectangle((x,top,x+view_w,top+view_h),radius=12,fill=(42,47,46),outline=(133,120,95),width=2)
            d.text((x+14,top+10),label,font=font(16,True),fill=(240,226,204))
            cell=64*zoom; footprint=cell*(1 if name=='Ametralladora' else 2)
            cx=x+view_w*.50; cy=top+view_h*.58
            d.rectangle((cx-footprint/2,cy-footprint/2,cx+footprint/2,cy+footprint/2),fill=(79,104,70),outline=(180,151,106),width=2)
            ground=Image.new('RGBA',(max(20,int(footprint)),max(20,int(footprint))),(79,104,70,255)); draw_tower(ground,name)
            e=tint(WARM,effect(level,4)).resize((int(footprint*2.15),int(footprint*2.15)),Image.Resampling.LANCZOS)
            # Clip the shown effect to the viewport to mimic an in-map camera crop.
            temp=Image.new('RGBA',(view_w,view_h),(0,0,0,0)); temp.alpha_composite(e,(int(cx-x-e.width/2),int(cy-top-e.height/2)))
            canvas.paste(ground.convert('RGB'),(int(cx-footprint/2),int(cy-footprint/2)))
            temp.putalpha(temp.getchannel('A').point(lambda a:int(a*.72)))
            canvas.paste(temp,(x,top),temp)
            # Draw tower above the light to keep the mechanism readable in the mockup.
            tower=Image.new('RGBA',(max(20,int(footprint)),max(20,int(footprint))),(0,0,0,0)); draw_tower(tower,name)
            canvas.paste(tower,(int(cx-footprint/2),int(cy-footprint/2)),tower)
            d.text((x+14,top+view_h-29),f'zoom {zoom*100:.0f}% · mockup, no es captura real',font=font(13),fill=(218,207,187))
    canvas.save(os.path.join(OUT,'scale_mockup.png'),optimize=True)
    # Old ring comparison, centered on equivalent tower illustration.
    comp=Image.new('RGB',(1000,365),(36,38,38)); d=ImageDraw.Draw(comp)
    for col,(title,level) in enumerate([('Hoy · anillo de construcción',0),('Propuesta · refuerzo',2),('Propuesta · maestría',3)]):
        x=col*333; d.text((x+12,12),title,font=font(17,True),fill=(245,231,207))
        tile=terrain((250,250),'Pradera',col+20); draw_tower(tile)
        if level:
            tile.alpha_composite(tint(WARM,effect(level,4)).resize((250,250),Image.Resampling.LANCZOS))
        else:
            dd=ImageDraw.Draw(tile,'RGBA'); dd.ellipse((54,74,196,216),outline=(255,246,219,220),width=4)
        comp.paste(tile.convert('RGB'),(x+38,55))
    comp.save(os.path.join(OUT,'ring_comparison.png'),optimize=True)
    # Looping animation previews (4x slow playback for comfortable inspection).
    for level,fps in ((2,16),(3,11)):
        frames=[]
        for i in range(8):
            bg=terrain((320,320),'Pradera',70+i); draw_tower(bg,'Mortero' if level==3 else 'Ametralladora')
            e=tint(WARM,effect(level,i)).resize((320,320),Image.Resampling.LANCZOS)
            bg.alpha_composite(e); frames.append(bg.convert('P',palette=Image.Palette.ADAPTIVE))
        duration=round(1000/fps*4)
        frames[0].save(os.path.join(OUT,f'animation_l{level}.gif'),save_all=True,append_images=frames[1:],duration=duration,loop=0,optimize=False,disposal=2)

def main():
    save_sheets()
    manifest={
      'tarea':'T362 · Efectos de mejora de torres M65',
      'nota':'Propuesta visual para revisión; no integrada ni aprobada.',
      'atlas': {'canvas':'768x384','frame':'192x192','layout':'4 columnas x 2 filas','centro':[96,96],'safe_margin_px':8,'order':'izquierda a derecha, arriba a abajo','alfa':'RGBA real; primer cuadro casi vacío, cuadro 8 transparente','tint':'Un arte neutro marfil/bronce claro, teñido por modulate.'},
      'effects': {'upgrade_l2':{'frames':8,'fps':16,'duration_seconds':0.5,'nominal_visible_diameter_px':120},'upgrade_l3':{'frames':8,'fps':11,'duration_seconds':0.7,'nominal_visible_diameter_px':160}},
      'limitations':['Mockup esquemático: no es captura del juego.','La maqueta ilustra PC 70 % y celular 150 %; no es medición en dispositivos reales.','Los tintes son una simulación de modulate; verificar el color definitivo en juego.']
    }
    for lv in (2,3):
        p=os.path.join(OUT,f'upgrade_l{lv}.png'); im=Image.open(p); manifest['effects'][f'upgrade_l{lv}']['atlas_px']=list(im.size); manifest['effects'][f'upgrade_l{lv}']['bytes']=os.path.getsize(p)
    with open(os.path.join(OUT,'manifest.json'),'w',encoding='utf-8') as f: json.dump(manifest,f,ensure_ascii=False,indent=2); f.write('\n')

if __name__=='__main__': main()
