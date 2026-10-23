#!/usr/bin/env python3
"""Renderiza la muestra neutral T367 con Pillow; no genera archivos del juego."""
from __future__ import annotations

import json
import hashlib
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops

ROOT = Path(__file__).resolve().parents[3]
ART = ROOT / "art/jefes-m66"
OUT = ART / "sources"
OUT.mkdir(parents=True, exist_ok=True)
SCALE = 3
NEUTRAL = (226, 213, 190)
INK = (43, 34, 51)


def font(size: int, bold: bool = False):
    candidates = ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]
    for p in candidates:
        if Path(p).exists():
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def scale_polygon(points, s=SCALE):
    return [(round(x*s), round(y*s)) for x, y in points]


def render_burst_frame(frame: int) -> Image.Image:
    """Un cuadro de 256²; pivote del punto de apoyo (128,176)."""
    im = Image.new("RGBA", (256*SCALE, 256*SCALE))
    glow = Image.new("RGBA", im.size)
    gd = ImageDraw.Draw(glow)
    d = ImageDraw.Draw(im)
    t = frame / 7
    cx, cy = 128, 176
    if frame == 7:
        return Image.new("RGBA", (256, 256))
    # Un halo de polvo se eleva, dejando el centro despejado para la silueta.
    opacity = int(75 * (1-t) ** .7)
    radius_x = 30 + 58*t
    radius_y = 9 + 20*t
    gd.ellipse(((cx-radius_x)*SCALE, (cy-radius_y)*SCALE,
                (cx+radius_x)*SCALE, (cy+radius_y)*SCALE),
               fill=(255, 238, 205, int(opacity*.28)))
    glow = glow.filter(ImageFilter.GaussianBlur(12*SCALE))
    im.alpha_composite(glow)
    d = ImageDraw.Draw(im)
    # Aro de choque abierto sobre el suelo, con borde facetado y luz contenida.
    rx, ry = 10 + 91*t, 3 + 20*t
    ring_alpha = int(230 * (1-t)**.48)
    box = ((cx-rx)*SCALE, (cy-ry)*SCALE, (cx+rx)*SCALE, (cy+ry)*SCALE)
    d.ellipse(box, outline=(248, 229, 196, ring_alpha), width=max(2, int((3.2-1.8*t)*SCALE)))
    if frame < 5:
        inner = ((cx-rx*.78)*SCALE, (cy-ry*.70)*SCALE, (cx+rx*.78)*SCALE, (cy+ry*.70)*SCALE)
        d.arc(inner, 205, 338, fill=(255, 248, 226, int(ring_alpha*.72)), width=2*SCALE)
    # Nube de polvo en lóbulos redondeados, separada de la silueta del jefe.
    cloud_alpha=int(82*(1-t)**.62)
    cloud_y=cy-22-26*t
    puff_specs=[(-42,8,16),(-28,-5,19),(-10,-10,20),(10,-12,19),(30,-4,18),(45,8,14)]
    for dx,dy,r in puff_specs:
        drift=dx*(.18+.25*t)
        px=cx+drift; py=cloud_y+dy*(.55+.45*t)
        pr=r*(.58+.42*t)
        d.ellipse(((px-pr)*SCALE,(py-pr*.65)*SCALE,(px+pr)*SCALE,(py+pr*.65)*SCALE),
                  fill=(236,229,214,cloud_alpha),outline=(250,241,220,int(cloud_alpha*.72)),width=SCALE)
        d.arc(((px-pr*.55)*SCALE,(py-pr*.28)*SCALE,(px+pr*.55)*SCALE,(py+pr*.38)*SCALE),190,340,
              fill=(247,233,208,int(cloud_alpha*.78)),width=SCALE)
    # Lasca y motas de polvo ascienden y se abren hacia los costados; sin silueta de llamas.
    for i, a in enumerate([198, 213, 227, 241, 254, 268, 282, 296, 310, 324, 338]):
        rad = math.radians(a)
        drift = (frame-2)*1.6
        distance=22+61*t
        x = cx + math.cos(rad)*distance + math.sin(rad)*drift
        y = cy + math.sin(rad)*(18+58*t) - 8*t
        r = (5.5 + (i%4)*1.5) * (1-.2*t)
        alpha = int((185 + (i%2)*25) * (1-t)**.62)
        if alpha <= 0: continue
        # Fragmentos facetados con contraste suficiente sobre pradera y camino.
        points = [(x-r*.9,y+r*.25),(x-r*.3,y-r*.75),(x+r*.7,y-r*.55),(x+r,y+r*.1),(x+r*.2,y+r*.82)]
        d.polygon(scale_polygon(points), fill=(224, 216, 201, alpha), outline=(205,196,180,int(alpha*.8)))
        d.line(scale_polygon([points[1],points[2],points[3]]), fill=(247, 233, 205, int(alpha*.9)), width=SCALE)
        # Motas pequeñas que se separan de la silueta.
        for j in range(2):
            px = x + (j-.5)*r*1.7
            py = y - r*(.8+j*.22)
            d.ellipse(((px-1.1)*SCALE,(py-1.1)*SCALE,(px+1.1)*SCALE,(py+1.1)*SCALE), fill=(235,224,203,int(alpha*.7)))
    # Ondas secundarias bajas, dibujadas por segmentos para que no parezcan rayos.
    if frame in (2,3,4,5):
        for side in (-1, 1):
            startx = cx + side*(rx*.55)
            d.arc(((startx-15)*SCALE,(cy-8)*SCALE,(startx+15)*SCALE,(cy+8)*SCALE), 198 if side<0 else 345, 300 if side<0 else 447,
                  fill=(226,213,190,int(95*(1-t))), width=SCALE)
    # Desenfoque muy leve del polvo, conservando bordes y alfa reales.
    im = im.resize((256,256), Image.Resampling.LANCZOS)
    return im


def render_crack() -> Image.Image:
    im = Image.new("RGBA", (192*2,96*2))
    d = ImageDraw.Draw(im)
    # Borde irregular atenuado, fisuras radiales y pequeñas lascas.
    paths = [
        [(95,49),(79,44),(67,33),(52,31)], [(79,44),(75,57),(60,69),(56,79)],
        [(95,49),(105,38),(119,35),(129,22)], [(105,38),(104,27)],
        [(95,49),(115,53),(133,64),(150,67)], [(115,53),(126,46),(143,45)],
        [(95,49),(89,62),(94,77)], [(67,33),(61,24)], [(133,64),(144,77)],
    ]
    def xy(p): return [(x*2,y*2) for x,y in p]
    for idx,path in enumerate(paths):
        a = 95 if idx < 7 else 60
        d.line(xy(path), fill=(66,60,55,a), width=3 if idx < 7 else 2, joint="curve")
        d.line([(x,y+1) for x,y in xy(path)], fill=(167,153,131,int(a*.45)), width=1)
    for poly in [[(43,29),(49,25),(53,32)],[(144,35),(150,32),(153,39)],[(78,72),(83,68),(82,76)],[(132,74),(137,72),(139,78)]]:
        d.polygon(xy(poly), fill=(113,103,88,65))
    # Atenuar suavemente los extremos para integrar la grieta al suelo.
    arr = im.getchannel("A")
    mask = Image.new("L", im.size)
    mp = mask.load()
    for y in range(im.height):
        for x in range(im.width):
            edge = min(x/22, (im.width-1-x)/22, y/14, (im.height-1-y)/14, 1)
            mp[x,y] = int(max(0,min(255,edge*255)))
    im.putalpha(ImageChops.multiply(arr,mask))
    return im.resize((192,96),Image.Resampling.LANCZOS)


def render_frame() -> Image.Image:
    im = Image.new("RGBA", (192*3,128*3))
    d = ImageDraw.Draw(im)
    # Bisel de hierro y bronce; el rectángulo interior queda transparente.
    # Todo detalle de esquina cabe en los 32 px reservados para el 9-slice.
    s=3
    def rect(box, fill=None, outline=None, width=1):
        b=tuple(round(v*s) for v in box)
        d.rectangle(b,fill=fill,outline=outline,width=width*s)
    rect((2,2,190,126),fill=(45,43,46,255),outline=INK,width=2)
    rect((6,6,186,122),fill=(108,87,62,255),outline=(197,151,82,255),width=2)
    rect((11,11,181,117),fill=(51,48,48,255),outline=(40,34,43,255),width=2)
    # Apertura transparente de 150×86; bisel interior simple para que no se empaste al estirar.
    d.rectangle((21*s,21*s,171*s,107*s),fill=(0,0,0,0))
    d.line([(16*s,16*s),(176*s,16*s)],fill=(222,178,104,255),width=2*s)
    d.line([(16*s,112*s),(176*s,112*s)],fill=(96,72,53,255),width=2*s)
    d.line([(16*s,16*s),(16*s,112*s)],fill=(169,126,70,255),width=2*s)
    d.line([(176*s,16*s),(176*s,112*s)],fill=(91,72,58,255),width=2*s)
    # Placas compactas y un remache por esquina: todos los adornos quedan en el margen fijo de 32 px.
    for x in (8,184):
        for y in (8,120):
            sx = 1 if x < 96 else -1
            sy = 1 if y < 64 else -1
            d.polygon(scale_polygon([(x,y+sy*1),(x+sx*10,y),(x,y+sy*10),(x-sx*10,y)]),fill=(141,103,65,255),outline=INK)
            d.line(scale_polygon([(x,y+sy*2),(x+sx*7,y),(x,y+sy*7)]),fill=(234,193,120,255),width=2)
            d.ellipse(((x-2)*s,(y-2)*s,(x+2)*s,(y+2)*s),fill=(242,210,151,255),outline=(43,34,51,255),width=s)
    return im.resize((192,128),Image.Resampling.LANCZOS)


def tint_burst(im: Image.Image, color: tuple[int,int,int]) -> Image.Image:
    # Multiplicación de color de enemigo; neutral cálido preserva polvo y brillo.
    rgba=im.copy(); px=rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            r,g,b,a=px[x,y]
            if a:
                px[x,y]=(int(r*color[0]/255),int(g*color[1]/255),int(b*color[2]/255),a)
    return rgba


def nine_slice(source: Image.Image, size: tuple[int,int], inset: int=32) -> Image.Image:
    w,h=size; sw,sh=source.size; c=inset
    xs=[(0,c),(c,sw-c),(sw-c,sw)]; ys=[(0,c),(c,sh-c),(sh-c,sh)]
    widths=[c,w-2*c,c]; heights=[c,h-2*c,c]
    out=Image.new("RGBA",size)
    for iy,(y0,y1) in enumerate(ys):
        for ix,(x0,x1) in enumerate(xs):
            cell=source.crop((x0,y0,x1,y1)).resize((widths[ix],heights[iy]),Image.Resampling.LANCZOS)
            out.alpha_composite(cell,(sum(widths[:ix]),sum(heights[:iy])))
    return out


def main():
    frames=[render_burst_frame(i) for i in range(8)]
    atlas=Image.new("RGBA",(1024,512))
    for i,frame in enumerate(frames): atlas.paste(frame,((i%4)*256,(i//4)*256))
    atlas.save(ART/"boss_burst.png",optimize=True)
    tint_specs=[("carmesi",(186,64,62)),("azul",(97,137,183)),("verde",(112,157,82))]
    for name,color in tint_specs:
        tint_burst(frames[3],color).save(ART/f"burst_{name}.png",optimize=True)
    render_crack().save(ART/"boss_crack.png",optimize=True)
    render_frame().save(ART/"boss_card_frame.png",optimize=True)
    # Hojas de revisión a 100 % y a 34 px, sobre una pradera de muestra.
    sheet=Image.new("RGBA",(4*272,2*282),(107,126,77,255))
    sd=ImageDraw.Draw(sheet)
    for i,frame in enumerate(frames):
        col,row=i%4,i//4; x,y=col*272,row*282
        sd.rectangle((x,y,x+271,y+281),fill=(112,130,80),outline=(42,39,42),width=2)
        # Marco a cuadros suave para distinguir áreas transparentes.
        for yy in range(y,y+256,32):
            for xx in range(x,x+256,32):
                if ((xx-x)//32+(yy-y)//32)%2:
                    sd.rectangle((xx,yy,xx+31,yy+31),fill=(119,137,83))
        sheet.alpha_composite(frame,(x,y))
        # Pivote visible como guía, siempre en la coordenada aprobable (128,176).
        px,py=x+128,y+176
        sd.line((px-6,py,px+6,py),fill=(255,240,191),width=1)
        sd.line((px,py-6,px,py+6),fill=(255,240,191),width=1)
        sd.text((x+8,y+258),f"Cuadro {i+1} · apoyo 128,176",font=font(12),fill=(244,232,204))
    sheet.save(ART/"burst_contact_100.png",optimize=True)
    small=Image.new("RGBA",(4*112,2*88),(112,130,80,255)); smd=ImageDraw.Draw(small)
    boss_ref=Image.open(ROOT/"assets/sprites/enemies/rendered/boss.png").convert("RGBA").resize((34,34),Image.Resampling.LANCZOS)
    for i,frame in enumerate(frames):
        col,row=i%4,i//4; x,y=col*112,row*88
        smd.rectangle((x,y,x+111,y+87),fill=(112,130,80),outline=(42,39,42),width=1)
        rendered=frame.resize((34,34),Image.Resampling.LANCZOS)
        small.alpha_composite(rendered,(x+10,y+3))
        smd.ellipse((x+26,y+25,x+28,y+27),fill=(255,240,191),outline=(43,34,51))
        if i==0: small.alpha_composite(boss_ref,(x+67,y+3))
        smd.text((x+5,y+43),f"{i+1} · 34 px"+("  /  Jefe" if i==0 else ""),font=font(9),fill=(245,232,206))
    small.save(ART/"burst_contact_34.png",optimize=True)
    # Exportar GIF de revisión a 11.43 fps; sin cuadro vacío final en el bucle.
    frames[0].save(ART/"boss_burst_preview.gif",save_all=True,append_images=frames[1:],duration=88,loop=0,disposal=2,optimize=True)
    # Las capturas de T368 se ejecutan abajo y se usan como fondo de las composiciones.
    refs=ART/"references"

    # La escena se capturó con Godot mediante la herramienta canónica de T368.
    # Estas composiciones ponen el PNG propuesto detrás del HUD y conservan jefe/UI
    # del fotograma real; sirven para juzgar posición, no sustituyen una ejecución de T369.
    if (refs/"gameplay_pc_provisional.png").exists():
        for device,anchor,ui in [
            ("pc",(100,158),( (0,0,1280,46),(360,56,920,164),(0,625,1280,720) )),
            ("celular",(100,159),( (0,0,1280,64),(360,70,920,164),(0,625,1280,720) )),
        ]:
            ref=refs/({"pc":"gameplay_pc_clear_provisional.png","celular":"gameplay_mobile_clear_provisional.png"}[device])
            if not ref.exists(): continue
            base=Image.open(ref).convert("RGBA")
            frame_ids=range(8) if device=="pc" else [3]
            for i in frame_ids:
                frame=frames[i]
                composition=base.copy()
                # Posición medida visualmente en la captura; pivote centrado en los pies.
                composition.alpha_composite(tint_burst(frame,(186,64,62)),(anchor[0]-128,anchor[1]-176))
                # Reponer el jefe con el cuadro 1 de boss_walk.png (escala y anclaje del mapa)
                # para que el polvo quede detrás de la criatura y la captura conserve sus pies.
                walk=Image.open(ROOT/"assets/sprites/enemies/rendered/boss_walk.png").convert("RGBA").crop((0,0,256,256))
                walk=walk.resize((115,115),Image.Resampling.LANCZOS)
                composition.alpha_composite(walk,(anchor[0]-58,anchor[1]-86))
                # La barra, la tarjeta y los botones de interfaz permanecen delante del efecto.
                for box in ui: composition.alpha_composite(base.crop(box),box[:2])
                composition.save(refs/f"level1_{device}_frame_{i+1:02d}.png",optimize=True)
            if device=="pc":
                Image.open(refs/"level1_pc_frame_04.png").save(ART/"level1_burst_desktop.png",optimize=True)
            else:
                composition=Image.open(refs/"level1_celular_frame_04.png").convert("RGBA")
                mobile=Image.new("RGBA",(2400,1080),(27,28,31,255))
                mobile.alpha_composite(composition.resize((1920,1080),Image.Resampling.LANCZOS),(240,0))
                mobile.save(ART/"level1_burst_mobile.png",optimize=True)

    def compose_card(base: Image.Image, top: int) -> Image.Image:
        card=base.copy(); origin=(280,top)
        card.alpha_composite(Image.new("RGBA",(720,120),(35,34,36,255)),origin)
        frame=nine_slice(Image.open(ART/"boss_card_frame.png").convert("RGBA"),(720,120))
        card.alpha_composite(frame,origin)
        portrait=Image.open(ROOT/"assets/sprites/enemies/rendered/boss.png").convert("RGBA").resize((96,96),Image.Resampling.LANCZOS)
        card.alpha_composite(portrait,(294,top+12))
        cd=ImageDraw.Draw(card)
        for y,text_,size,bold,color in [
            (top+21,"¡Llega el Jefe!",20,True,(242,204,136)),
            (top+41,"Jefe",20,True,(248,235,208)),
            (top+61,"Mucha vida y armadura; el Hielo lo frena",20,False,(233,222,202)),
            (top+81,"a medias. ¡Si llega, quita 10 vidas!",20,False,(233,222,202)),
        ]:
            cd.text((405,y),text_,font=font(size,bold),fill=color,stroke_width=1,stroke_fill=(43,34,51))
        return card

    pc_base=refs/"gameplay_pc_clear_provisional.png"
    mobile_base=refs/"gameplay_mobile_clear_provisional.png"
    if pc_base.exists():
        compose_card(Image.open(pc_base).convert("RGBA"),56).save(ART/"level1_card_desktop.png",optimize=True)
    if mobile_base.exists():
        mobile_card=compose_card(Image.open(mobile_base).convert("RGBA"),72)
        mobile=Image.new("RGBA",(2400,1080),(27,28,31,255))
        mobile.alpha_composite(mobile_card.resize((1920,1080),Image.Resampling.LANCZOS),(240,0))
        mobile.save(ART/"level1_card_mobile_150.png",optimize=True)

    files=[
        "boss_burst.png","boss_crack.png","boss_card_frame.png","boss_burst_preview.gif",
        "burst_contact_100.png","burst_contact_34.png","burst_carmesi.png","burst_azul.png","burst_verde.png",
        "level1_burst_desktop.png","level1_burst_mobile.png","level1_card_desktop.png","level1_card_mobile_150.png",
        "comparison.html","prompts.md","sources/render_sample.py",
        "references/gameplay_pc_provisional.png","references/gameplay_celular_provisional.png",
        "references/gameplay_pc_clear_provisional.png","references/gameplay_mobile_clear_provisional.png",
    ]+[f"references/level1_pc_frame_{i:02d}.png" for i in range(1,9)]+["references/level1_celular_frame_04.png"]
    outputs={}
    for rel in files:
        path=ART/rel
        if not path.exists(): continue
        entry={"bytes":path.stat().st_size,"sha256":hashlib.sha256(path.read_bytes()).hexdigest()}
        if path.suffix==".png":
            with Image.open(path) as img: entry.update({"size_px":list(img.size),"mode":img.mode})
        outputs[rel]=entry
    manifest={
        "tarea":"T367 · Arte de entrada de jefes (M66)",
        "estado":"muestra para revisión; pendiente de aprobación de Lucas; no integrada en assets/",
        "origen":"sources/render_sample.py (Pillow; geometría nativa, sin generación externa)",
        "destello":{"archivo":"boss_burst.png","ruta_final_prevista":"assets/sprites/effects/jefe/boss_burst.png","formato":"PNG RGBA con alfa real","cuadro_px":[256,256],"atlas_px":[1024,512],"cuadros":8,"disposicion":"4 columnas × 2 filas","anclaje_pies_px":[128,176],"duracion_s":0.7,"cuadro_8":"transparente","margen_minimo_px":8,"mipmaps":False,"peso_maximo_bytes":250000},
        "grieta":{"archivo":"boss_crack.png","ruta_final_prevista":"assets/sprites/effects/jefe/boss_crack.png","formato":"PNG RGBA con alfa real","size_px":[192,96],"teñible":False,"mipmaps":False,"peso_maximo_bytes":30000},
        "marco":{"archivo":"boss_card_frame.png","ruta_final_prevista":"assets/sprites/effects/jefe/boss_card_frame.png","formato":"PNG RGBA con centro transparente","size_px":[192,128],"nine_slice_inset_px":32,"mipmaps":False,"peso_maximo_bytes":40000},
        "tintes_de_muestra":{"carmesi_jefe":"#ba403e","azul_acero":"#6189b7","verde":"#709d52"},
        "contexto":{"nivel":"level_01","enemigo":"boss","retrato":"assets/sprites/enemies/rendered/boss.png","caminata":"assets/sprites/enemies/rendered/boss_walk.png","dispositivo":"captura real 1280×720; modo móvil simulado en PC"},
        "captura_de_juego":{"engine":"Godot 4.7.2","comando":"godot --path . res://tools/capture_boss_entrance.tscn -- /tmp/t367-live 1280x720","resultado":"las seis capturas de T368 terminaron; muestran el arte provisional existente"},
        "limites_de_validacion":["Las composiciones candidatas son montajes estáticos sobre capturas reales, no una ejecución integrada del PNG.","No se ejecutó la prueba de rendimiento T369 ni se midió APK.","No se probó en un teléfono físico ni se exportó para Android."],
        "salidas":outputs,
    }
    (ART/"manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")


if __name__ == "__main__": main()
