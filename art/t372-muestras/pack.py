"""Empaqueta las muestras y maquetas sin importar el proyecto del juego.
Requiere Pillow. Ejecutar desde cualquier carpeta con Python 3.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json, re, hashlib
R=Path(__file__).resolve().parent
GAME=R.parents[1]
F='/usr/share/fonts/truetype/dejavu/DejaVuSans'
ICON_NAMES=['map','tower','monster','siege','editor','mobile','book','upgrade']
ICON_LABELS=['Mapa','Torre','Monstruo','Asedio','Editor','Celular','Libro','Mejora']
BG='#0e0f13'; PANEL='#1b1c20'; CREAM='#f4ecd8'; MUTED='#d7c8a5'; BRONZE='#855c2b'
def font(n,b=False):return ImageFont.truetype(F+('-Bold' if b else '')+'.ttf',n)
def write(im,name): im.save(R/name,optimize=True)
def text(draw,xy,t,n=18,fill=CREAM,b=False):draw.text(xy,t,font=font(n,b),fill=fill)
def wrap(t,n,width):
    lines=['']
    for word in t.split():
        trial=(lines[-1]+' '+word).strip()
        if font(n).getlength(trial)>width:lines.append(word)
        else:lines[-1]=trial
    return lines
src=Image.open(R/'sources/header_revised.png').convert('RGB')
# Recorte 4:1 sin deformar cuerpos. La antena alta no forma parte de la información vital.
w,h=src.size; ch=round(w/4); top=190
header=src.crop((0,top,w,top+ch)).resize((1280,320),Image.Resampling.LANCZOS)
# PNG indexado para reducir peso; se conserva la fuente generada sin modificar.
header=header.quantize(colors=256,method=Image.Quantize.MEDIANCUT)
write(header,'news_header_1_0.png')
for name in ['news_header_plain']+['news_icon_'+name for name in ICON_NAMES]:
    im=Image.open(R/(name+'.png'));write(im,name+'.png')
# Los textos salen literalmente de la tabla del borrador, no de una redacción nueva.
spec=(GAME/'specs/01-spec.md').read_text()
rows=[]
for line in spec.splitlines():
    if re.match(r'\| [1-8] \|',line):
        parts=[x.strip() for x in line.strip('|').split('|')]
        if len(parts)==4 and parts[3] in ['mapa','torre','monstruo','asedio','editor','celular','libro','mejora']:
            rows.append((re.sub(r'\*\(solo si entran en la 1.0.0\)\*\s*','',parts[1]),parts[2]))
assert len(rows)==8
icons=[Image.open(R/f'news_icon_{name}.png') for name in ICON_NAMES]
contact=Image.new('RGB',(760,1120),PANEL);d=ImageDraw.Draw(contact)
for k,size in enumerate([96,64,48]):
    x=30+k*245;text(d,(x,14),f'{size} px',20,b=True)
    for j,label in enumerate(ICON_LABELS):
        y=62+j*132; icon=icons[j].resize((size,size),Image.Resampling.LANCZOS)
        contact.paste(icon,(x,y),icon);text(d,(x+110,y+15),label,18)
write(contact,'contact_sheet.png')
def header_preview(width):
    im=Image.new('RGB',(width,round(width/4)),BG);im.paste(header.convert("RGB").resize(im.size,Image.Resampling.LANCZOS));d=ImageDraw.Draw(im)
    y=round(im.height*.62)
    # Soporte oscuro explícito de la maqueta, no pintado dentro de la cabecera.
    d.rounded_rectangle((24,y,width-24,im.height-8),radius=4,fill=PANEL)
    text(d,(36,y+2),'Monsters & Canons 1.0',26,b=True)
    text(d,(36,y+35),'Esto es lo que trae el juego completo.',18)
    return im
for width in [720,880]:write(header_preview(width),f'header_{width}.png')
def mock(mobile=False,real=False,end=False):
    logical_h=576 if real else 720; scale=1.875 if real else 1
    im=Image.new('RGB',(1280,logical_h),BG);d=ImageDraw.Draw(im)
    pw=880 if mobile else 720; x=(1280-pw)//2;y=16;ph=logical_h-32
    d.rounded_rectangle((x,y,x+pw,y+ph),radius=8,fill=PANEL,outline=BRONZE,width=2)
    hero=header_preview(pw-4);im.paste(hero,(x+2,y+2))
    for rx in [x+12,x+pw-12]:d.ellipse((rx-3,y+8,rx+3,y+14),fill='#b17c43')
    hy=y+hero.height+9
    text(d,(x+24,hy),'Versión 1.0.0 · Borrador',18,fill=MUTED)
    area_top=hy+30; bottom=y+ph-(80 if mobile else 68); ah=bottom-area_top
    row_h=106 if mobile else 102; size=64 if mobile else 48;n=20 if mobile else 18
    content=Image.new('RGB',(pw-48,len(rows)*row_h),PANEL);rd=ImageDraw.Draw(content)
    for i,(title,body) in enumerate(rows):
        yy=i*row_h
        rd.line((0,yy+row_h-5,pw-60,yy+row_h-5),fill='#343438')
        icon=icons[i].resize((size,size),Image.Resampling.LANCZOS);content.paste(icon,(0,yy+10),icon)
        text(rd,(size+16,yy+5),title,n,b=True)
        for j,line in enumerate(wrap(body,n,pw-size-84)):
            text(rd,(size+16,yy+34+j*(n+4)),line,n)
    offset=max(0,content.height-ah) if end else 0
    im.paste(content.crop((0,offset,content.width,offset+ah)),(x+24,area_top))
    track=(x+pw-15,area_top,x+pw-10,bottom);d.rounded_rectangle(track,radius=2,fill='#343438')
    th=max(25,round(ah*ah/content.height));ty=bottom-th if end else area_top
    d.rounded_rectangle((track[0],ty,track[2],ty+th),radius=2,fill='#b17c43')
    bh=56 if mobile else 44;by=y+ph-bh-12
    d.rounded_rectangle((x+24,by,x+pw-24,by+bh),radius=6,fill='#27272a',outline=BRONZE,width=2)
    tw=font(22,True).getlength('Entendido');text(d,(x+pw/2-tw/2,by+(bh-27)/2),'Entendido',22,b=True)
    if real:im=im.resize((2400,1080),Image.Resampling.LANCZOS)
    return im
for name,mob,real,end in [('mockup_pc.png',False,False,False),('mockup_mobile.png',True,False,False),('mockup_mobile_real.png',True,True,False),('mockup_pc_end.png',False,False,True),('mockup_mobile_real_end.png',True,True,True)]:write(mock(mob,real,end),name)
# Lista completa para revisar los ocho textos aunque la maqueta muestre un área desplazable.
full=Image.new('RGB',(880,8*106),PANEL); fd=ImageDraw.Draw(full)
for i,(title,body) in enumerate(rows):
    yy=i*106;text(fd,(100,yy+8),title,20,b=True)
    for j,line in enumerate(wrap(body,20,740)):text(fd,(100,yy+37+24*j),line,20)
    ico=icons[i].resize((64,64),Image.Resampling.LANCZOS);full.paste(ico,(20,yy+15),ico)
write(full,'all_rows.png')
def lum(rgb):
    a=[v/255 for v in rgb];a=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in a]
    return .2126*a[0]+.7152*a[1]+.0722*a[2]
fg=lum((244,236,216)); panel_l=lum((27,28,32))
zone=header.convert('RGB').crop((80,205,1200,310)); raw_contrast=min((max(fg,lum(p))+.05)/(min(fg,lum(p))+.05) for p in zone.getdata())
metrics={'title_on_opaque_panel':round((fg+.05)/(panel_l+.05),2),'subtitle_on_opaque_panel':round((lum((215,200,165))+.05)/(panel_l+.05),2),'cream_on_raw_header_worst_pixel_in_text_zone':round(raw_contrast,2),'raw_text_zone':[80,205,1200,310]}
assets=[]
for name,dim,mode,limit in [('news_header_1_0.png',(1280,320),'P',350000),('news_header_plain.png',(1280,160),'RGB',100000),*[(f'news_icon_{name}.png',(96,96),'RGBA',20000) for name in ICON_NAMES]]:
    p=R/name;im=Image.open(p);assert im.size==dim and im.mode==mode and p.stat().st_size<limit
    if mode=='RGBA':assert im.getchannel('A').getextrema()==(0,255)
    assets.append({'file':name,'size':list(dim),'mode':mode,'bytes':p.stat().st_size,'limit_bytes':limit,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'source':('sources/'+name.replace('.png','.svg')) if name!='news_header_1_0.png' else 'sources/header_revised.png','use':ICON_LABELS[ICON_NAMES.index(name[10:-4])] if name.startswith('news_icon_') else 'Cabecera','status':'muestra aprobada según encargo de Lucas' if name in ['news_header_1_0.png','news_header_plain.png','news_icon_map.png','news_icon_tower.png'] else 'nuevo ícono; pendiente de revisión de la hoja completa'})
plain=Image.open(R/'news_header_plain.png');assert list(plain.crop((0,0,1,160)).getdata())==list(plain.crop((1279,0,1280,160)).getdata())
manifest={'task':'T372','stage':'familia completa de ocho íconos; sin integración','source_commit':'ad45a5a','approved_baseline_sha256':{'news_header_1_0.png': 'e840cda891cfb54ec81d0d47954cc7f0ad8b946abff1c300e6a9fd61a9e53a61', 'news_header_plain.png': 'c7dde9c174733a64b775920521ba3a79394ce932b570adef4dd14c4d5eb994ed', 'news_icon_map.png': '343b7760345f7cd3363485b6eca4811736fbf92dc78fb2acba9666398bda4b82', 'news_icon_tower.png': '33491b78b962ddae0fbe9cf01cda0ad36aab697a419ca0fbc1d9b716a65944be', 'sources/news_header_plain.svg': '99a772267f1ca29abeb59f07969a876abc930f49969d1b61d19ab1f7b21ad09e', 'sources/news_icon_map.svg': 'aea34635ae0d4a4628b8a465c2270644180668220de76c1ec1746546a07d01df', 'sources/news_icon_tower.svg': '49179336e946200f7e9e1babb6a3650d62902024c67a32eaf21b66e78a471d79'},'assets':assets,'missing_icons':[],'optional_icons':['upgrade'],'header_crop':[0,top,w,top+ch],'contrast':metrics,'plain_seam':'columnas extremas idénticas; período horizontal 160 px','mobile_real':{'canvas':[2400,1080],'logical_viewport':[1280,576],'scale':1.875},'imported_ctex_bytes':json.loads((R/'import_report.json').read_text())['ctex_bytes'] if (R/'import_report.json').exists() else None}
(R/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(manifest,ensure_ascii=False,indent=2))
# Comparación autónoma de estilo: referencia existente, reducida sin alterar el original.
ref=Image.open(GAME/'assets/intro/07_el_oasis.png').convert('RGB');ref.thumbnail((720,405));write(ref,'intro_reference.png')
style='''body{margin:28px;background:#0e0f13;color:#f4ecd8;font:17px system-ui}h1,h2{color:#edca8b}p{max-width:1000px;line-height:1.5}a{color:#edca8b}figure{margin:12px 0 24px}figcaption{margin:6px 0}.scroll{overflow:auto;border:1px solid #855c2b;padding:12px;background:#1b1c20}img{display:block;max-width:none}button{font:inherit;color:#f4ecd8;background:#27272a;border:2px solid #855c2b;padding:12px 20px;cursor:pointer}.pair{display:flex;gap:24px;align-items:start;flex-wrap:wrap}.hero{position:relative}.safe{position:absolute;bottom:0;height:40%;left:0;right:0;border:1px dashed #f4ecd8;box-sizing:border-box;pointer-events:none}.safe span{background:#1b1c20;font-size:12px}.native{max-width:none}table{border-collapse:collapse}td,th{padding:8px 14px;border:1px solid #855c2b;text-align:left}'''
parts=[f'<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>T372 · Muestras para aprobar</title><style>{style}</style><h1>T372 · Familia completa para revisar</h1>',
'<p>Dos cabeceras y ocho íconos. Lucas aprobó el estilo de las muestras previas y autorizó los seis íconos nuevos. Hoja completa pendiente de revisión, sin integración. Mejora sigue siendo opcional. Los textos son el borrador literal de M67. Abrí esta hoja al 100 % de zoom: las imágenes conservan sus píxeles CSS; si falta ancho, desplazá el contenedor.</p>',
'<p><a href="README.md">Alcance y límites</a> · <a href="prompts.md">Prompts y fuentes</a> · <a href="manifest.json">Medidas y pesos</a> · <a href="validation.json">Validación mecánica</a></p>',
'<h2>Familia visual: intro y cabecera</h2><div class="pair"><figure><img src="intro_reference.png" width="720" height="405" alt="Lámina existente del oasis, referencia de estilo"><figcaption>Intro existente: cuaderno de bitácora. No es una muestra nueva.</figcaption></figure><figure><img src="news_header_1_0.png" width="720" height="180" alt="Cabecera del oasis"><figcaption>Propuesta más luminosa, reducida a 720 px.</figcaption></figure></div>',
'<h2>Íconos a escala real</h2><p>96 px de archivo, 64 px en celular y 48 px en PC. Mismo fondo de hierro del menú.</p><div class="scroll"><img src="contact_sheet.png" width="760" height="1120" alt="Los ocho medallones a 96, 64 y 48 píxeles"></div>',
'<h2>Cabecera y zona de texto</h2><p>El contorno punteado marca el 40 % inferior reservado. El soporte oscuro de las siguientes vistas pertenece a la maqueta, no al PNG.</p>']
for width in [720,880]:
    parts.append(f'<h3>{width} px de ancho</h3><div class="scroll"><div class="hero" style="width:{width}px;height:{width//4}px"><img src="news_header_1_0.png" width="{width}" height="{width//4}" alt="Cabecera sin texto"><div class="safe"><span>40 % inferior</span></div></div><img src="header_{width}.png" width="{width}" height="{width//4}" alt="Título y subtítulo superpuestos"></div>')
parts.append('<h2>Variante sobria repetible</h2><p>Original 1280 × 160. Extremos idénticos, patrón de 160 px. Debajo, repetición a 1600 px; sin texto dentro del archivo.</p><div class="scroll"><img src="news_header_plain.png" width="1280" height="160" alt="Banda de hierro y bronce"><div style="width:1600px;height:160px;margin-top:16px;background:url(news_header_plain.png) repeat-x"></div></div>')
parts.append('<h2>Maquetas: título y botón fijos</h2><p>Alterná entre principio y final de la lista. Esta comparación de imágenes no prueba el desplazamiento del juego. Las ocho filas ya tienen su ícono.</p>')
for name,label,ww,hh,end in [('mockup_pc.png','PC · panel de 720 px',1280,720,'mockup_pc_end.png'),('mockup_mobile.png','Celular · panel de 880 px en 1280 × 720',1280,720,None),('mockup_mobile_real.png','Celular real · 2400 × 1080',2400,1080,'mockup_mobile_real_end.png')]:
    parts.append(f'<h3>{label}</h3>')
    if end:parts.append(f'<button onclick="document.getElementById(\'{name}\').src=\'{name}\'">Inicio</button> <button onclick="document.getElementById(\'{name}\').src=\'{end}\'">Final</button>')
    parts.append(f'<div class="scroll"><img id="{name}" src="{name}" width="{ww}" height="{hh}" alt="Maqueta {label}"></div>')
parts.append('<p>2400 × 1080 no tiene la misma proporción que 1280 × 720. Para mostrar 1,875× sin deformación, la vista real usa 1280 × 576 lógicos: el área desplazable queda más baja. No es una captura de Android.</p><h2>Las ocho filas del borrador</h2><div class="scroll"><img src="all_rows.png" width="880" height="848" alt="Los ocho textos completos con sus íconos"></div>')
parts.append('<h2>Verificación</h2><table><tr><th>Archivo</th><th>Píxeles</th><th>Bytes PNG</th></tr>')
for a in assets:parts.append(f'<tr><td>{a["file"]}</td><td>{a["size"][0]} × {a["size"][1]}</td><td>{a["bytes"]:,}</td></tr>')
parts.append(f'</table><p>Contraste del título crema con soporte #1b1c20: {metrics["title_on_opaque_panel"]}:1. Subtítulo #d7c8a5: {metrics["subtitle_on_opaque_panel"]}:1. Sobre la ilustración sin soporte no se garantiza contraste suficiente; revisar README.</p><p>Sin animación ni cambios de lógica. No se importó ni se ejecutó el juego. La importación de peso se verifica en un proyecto Godot aislado.</p></html>')
(R/'comparison.html').write_text('\n'.join(parts))
