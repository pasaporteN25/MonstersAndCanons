"""Pulido vectorial reproducible; las fuentes anteriores se conservan sin cambios."""
from pathlib import Path
import re, json, hashlib
ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'art/t260-decoration'
NAMES = 'flores bush tree abeto pino rock_a rock_b roca_roja roca_negra roca_nieve cactus columna estatua bloque helecho tronco junco hongo huesos grieta roca_marcada simbolo_ruina sendero poste_cintas herramienta campamento_vacio hito'.split()
for name in NAMES:
    source = ROOT / f'assets/sprites/map/{name}.svg'
    backup = ART / f'sources/before/{name}.svg'
    if not backup.exists():
        backup.write_bytes(source.read_bytes())

def gradient(name, colors):
    return f'<linearGradient id="{name}" x1="0" y1="0" x2=".25" y2="1">' + ''.join(f'<stop offset="{offset}" stop-color="{color}"/>' for offset,color in zip(['0','.52','1'],colors)) + '</linearGradient>'

def svg(comment, body, palettes):
    return f'<!-- {comment}; vista lateral hacia la derecha; fondo transparente. -->\n<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64" stroke-linecap="round" stroke-linejoin="round">\n<defs>' + ''.join(gradient(k,v) for k,v in palettes.items()) + '</defs>\n' + body + '\n</svg>\n'

def shadow(cx=33, y=55, rx=22):
    return f'<ellipse cx="{cx}" cy="{y}" rx="{rx}" ry="4" fill="#2b2233" opacity=".10"/><ellipse cx="{cx}" cy="{y}" rx="{rx-5}" ry="2.4" fill="#2b2233" opacity=".10"/>'

custom = {}
# Los pétalos se agrupan en corolas reconocibles; no se dibuja una isla de suelo bloqueado.
body = shadow(32,55,20)
body += '<g fill="none" stroke="#397437" stroke-width="2"><path d="M15 54Q18 41 14 31M28 55Q25 38 30 25M40 54Q44 42 42 35M49 54Q51 46 52 43M22 54Q22 49 23 44"/></g>'
body += '<g fill="url(#leaf)" stroke="#2b2233" stroke-width=".8"><path d="M17 46Q6 46 7 38Q16 38 17 46ZM27 43Q35 35 37 40Q37 46 27 47ZM42 48Q35 46 33 41Q43 40 42 48ZM24 51Q16 52 15 47Q21 44 24 51ZM49 52Q57 45 58 49Q58 53 49 54Z"/></g>'
for x,y,r,color in [(14,31,5,'pink'),(30,25,6,'gold'),(42,35,5,'violet'),(52,43,4,'white'),(23,44,4,'pink')]:
    body += f'<g transform="translate({x} {y})" fill="url(#{color})" stroke="#2b2233" stroke-width=".8">'
    for angle in [0,72,144,216,288]:
        body += f'<ellipse cx="0" cy="{-r*.52}" rx="{r*.52}" ry="{r*.68}" transform="rotate({angle})"/>'
    body += f'<circle r="{r*.32}" fill="#df9e36"/><path d="M-1 -1.2H.8" stroke="#fff0ad" stroke-width="1"/></g>'
custom['flores'] = svg('Flores silvestres con cinco pétalos, hojas y alturas variadas, sin aspecto de obstáculo', body, {'leaf':['#82b967','#4f9a48','#326637'],'pink':['#ffe1eb','#f4a3c4','#be708f'],'gold':['#fff1b8','#ffe27a','#cda951'],'violet':['#e3d5ff','#bfa8f2','#8876b7'],'white':['#ffffff','#eef1ec','#b8c9c2']})
for name in ['tree','bush']:
    tree = name == 'tree'
    body = shadow(y=55 if tree else 53,rx=23)
    if tree:
        body += '<path d="M26 55 29 37 24 30 28 29 33 36 39 29 42 32 36 40 37 55Z" fill="url(#wood)" stroke="#2b2233" stroke-width="2"/><path d="M30 46 29 53M33 40V48" stroke="#c29861" stroke-width="1.3"/>'
        forms = ['M9 37Q2 29 10 20Q9 12 21 12Q25 2 35 5Q46 3 48 15Q59 18 57 29Q62 40 48 44Q39 50 29 43Q17 48 9 37Z','M9 28Q9 17 21 17Q28 12 34 22Q34 31 26 35Q15 39 9 28Z','M24 14Q24 6 34 7Q45 5 46 16Q46 24 36 26Q25 25 24 14Z','M34 31Q35 21 46 21Q56 24 55 34Q52 43 42 42Q32 42 34 31Z']
    else:
        forms = ['M7 45Q2 35 13 28Q16 20 25 25Q30 14 41 21Q49 20 51 30Q62 32 58 44Q52 53 42 50Q31 55 23 50Q12 54 7 45Z','M8 40Q8 29 20 29Q28 28 29 39Q28 48 18 47Q8 49 8 40Z','M24 31Q23 21 35 22Q46 20 47 32Q45 42 34 41Q24 42 24 31Z','M39 42Q38 32 49 32Q58 33 56 43Q53 50 45 48Z']
    body += f'<path d="{forms[0]}" fill="url(#leaf)" stroke="#2b2233" stroke-width="2.2"/>'
    for form in forms[1:]:
        body += f'<path d="{form}" fill="url(#leaf)"/>'
    body += ('<path d="M13 24Q17 19 23 20M28 13Q33 9 39 12M39 29Q44 25 49 28" fill="none" stroke="#91cb73" stroke-width="1.7"/>' if tree else '<path d="M12 36Q15 31 21 33M28 28Q33 24 39 27M44 38Q48 35 52 38" fill="none" stroke="#9bd27f" stroke-width="1.6"/>')
    if not tree:
        for x,y in [(23,37),(36,31),(46,42),(31,45)]:
            body += f'<circle cx="{x}" cy="{y}" r="2.4" fill="url(#berry)" stroke="#2b2233" stroke-width=".8"/>'
    custom[name] = svg('Árbol de copa ramificada y tronco bifurcado' if tree else 'Arbusto bajo de hojas agrupadas y frutos rojos',body,{'leaf':['#6cbc57','#3f8a3a' if tree else '#4c9a3f','#2f6e2c' if tree else '#3b7f32'],'wood':['#ac8050','#7a4f2a','#503622'],'berry':['#fb9690','#e2474f','#a32e43']})
for name in ['pino','abeto']:
    body = shadow(rx=21)
    body += '<path d="M29 56 29 43 36 43 36 56Z" fill="url(#wood)" stroke="#2b2233" stroke-width="2"/>'
    tiers = [(9,27,55,51),(15,16,49,38),(22,6,42,26)] if name == 'pino' else [(7,29,57,51),(13,12,51,38)]
    for left,top,right,bottom in tiers:
        body += f'<path d="M32 {top} {right-6} {bottom-10} {right-9} {bottom-10} {right} {bottom} {right-10} {bottom-1} {right-14} {bottom+2} 32 {bottom} {left+13} {bottom+2} {left+9} {bottom-1} {left} {bottom} {left+9} {bottom-10} {left+6} {bottom-10}Z" fill="url(#leaf)" stroke="#2b2233" stroke-width="2"/>'
        cap_width = (right - 32) * .57
        cap_y = top + (bottom - top) * .55
        body += f'<path d="M32 {top} {32+cap_width} {cap_y} {32+cap_width*.58} {cap_y-1.5} {32+cap_width*.32} {cap_y+2} 32 {cap_y-1} {32-cap_width*.32} {cap_y+2} {32-cap_width*.58} {cap_y-1.5} {32-cap_width} {cap_y}Z" fill="url(#snow)"/>'
        body += f'<path d="M31 {top+3} {32-cap_width*.57} {cap_y-3}" stroke="#ffffff" stroke-width="1.2"/>'
    body += '<path d="M15 54Q19 50 24 53M40 55Q45 50 50 54" fill="none" stroke="#e2edf8" stroke-width="3"/>'
    custom[name] = svg('Pino nevado con tres pisos escalonados' if name=='pino' else 'Abeto joven nevado de copa ancha y dos pisos',body,{'leaf':['#579569','#2f6b4b' if name=='pino' else '#3a7a55','#245a3f'],'wood':['#a47747','#6b4526','#493326'],'snow':['#ffffff','#f6fbff','#bcd2ea']})
# Los otros dibujos conservan su anatomía: el material pasa de plano a volumen suave.
extras = {
'rock_a':'<path d="M17 29 24 22 34 20" fill="none" stroke="#d0cfd4" stroke-width="1.5"/><path d="M14 40 22 43 25 49" fill="#686872" opacity=".45"/>',
'rock_b':'<path d="M14 29 21 24 27 25M37 38 44 34 49 35" fill="none" stroke="#d0cfd4" stroke-width="1.3"/>',
'roca_roja':'<path d="M17 29 24 22 34 20" fill="none" stroke="#efb78b" stroke-width="1.5"/><path d="M14 35 22 36 39 33" fill="none" stroke="#e0a077" stroke-width="1.1"/>',
'roca_negra':'<path d="M17 29 24 22 34 20" fill="none" stroke="#827b96" stroke-width="1.5"/><path d="M41 32 44 39 42 44" fill="none" stroke="#282632" stroke-width="1.2"/>',
'roca_nieve':'<path d="M17 28 24 22 34 20" fill="none" stroke="#ffffff" stroke-width="1.6"/><path d="M14 39 20 42 22 46" fill="none" stroke="#a5b4c8" stroke-width="1.2"/>',
'columna':'<path d="M24 28V33M18 50H28" stroke="#f2ecde" stroke-width="1.3"/><path d="M35 38 39 35 42 36" fill="none" stroke="#7d796e" stroke-width="1.1"/>',
'estatua':'<path d="M29 17 33 15M20 50H29" stroke="#eee8d9" stroke-width="1.2"/><path d="M25 40 27 43 30 43M35 34 37 39" fill="none" stroke="#797469" stroke-width="1.1"/>',
'bloque':'<path d="M9 36H18M33 24 37 20 44 21" stroke="#eee8d9" stroke-width="1.3"/><path d="M10 37 13 40 12 43" fill="none" stroke="#716e65" stroke-width="1.1"/>',
'cactus':'<path d="M33 47 31 51M18 25 18 29M50 20 50 24" stroke="#c7dc93" stroke-width="1.2"/><path d="M31 11Q27 6 30 5Q33 4 34 9Q37 5 39 8Q40 12 35 13Z" fill="#f4a3c4" stroke="#2b2233" stroke-width=".9"/>',
'helecho':'<path d="M29 24 33 20M28 32 34 27M28 40 35 34M18 35 19 30M44 35 45 30" stroke="#285d31" stroke-width="1.2"/>',
'tronco':'<path d="M22 39 27 37 33 39M38 43 45 42 50 44" fill="none" stroke="#483421" stroke-width="1.1"/>',
'junco':'<path d="M29 48 25 41M40 51 45 44" stroke="#adc19a" stroke-width="1.2"/>',
'hongo':'<path d="M23 44 24 49M37 42 38 47" stroke="#d7c8a5" stroke-width="1.2"/>',
'huesos':'<path d="M35 27 32 29 35 32M20 42 22 47" fill="none" stroke="#a99776" stroke-width="1.2"/>',
'grieta':'<path d="M20 40 25 43M40 26 44 30" stroke="#aa6550" stroke-width="1.2"/>',
'roca_marcada':'<path d="M16 27 24 21 35 19" fill="none" stroke="#ece2cc" stroke-width="1.4"/><path d="M44 38 48 43 46 48" fill="none" stroke="#504b43" stroke-width="1.2"/>',
'simbolo_ruina':'<path d="M14 29 20 24 27 24" fill="none" stroke="#e2d6be" stroke-width="1.4"/><path d="M46 39 49 42 47 48" fill="none" stroke="#514b43" stroke-width="1.2"/>',
'sendero':'<path d="M12 45H19M31 37H38M49 47H55" stroke="#504b43" stroke-width="1"/>',
'poste_cintas':'<path d="M34 30 33 39 35 44" fill="none" stroke="#4d392f" stroke-width="1.2"/><path d="M20 22 19 27M47 20 49 24" stroke="#684239" stroke-width="1.1"/><path d="M29 21 35 21M29 23 36 23" stroke="#d5be91" stroke-width="1.4"/>',
'herramienta':'<path d="M48 11 51 15 56 16" fill="none" stroke="#b69b76" stroke-width="1.2"/><path d="M23 44 29 38" stroke="#4d392f" stroke-width="1.1"/>',
'campamento_vacio':'<path d="M30 36 33 40 39 43M44 43 47 46" fill="none" stroke="#583b36" stroke-width="1.2"/><path d="M15 40 18 41M41 39 44 40" stroke="#d4aa8c" stroke-width="1.1"/>',
'hito':'<path d="M40 42 48 44 48 49 40 52Z" fill="#625d53" opacity=".5"/><path d="M39 27 44 31 40 35" fill="none" stroke="#625d53" stroke-width="1.2"/>',
}
for name in NAMES:
    if name in custom:
        result = custom[name]
    else:
        text = (ART / f'sources/before/{name}.svg').read_text()
        comments = re.findall(r'<!--(.*?)-->',text,re.S)
        comment = re.sub(r'\s+',' ',comments[0]).strip().split(':')[0] if comments else name
        text = re.sub(r'<!--.*?-->','',text,flags=re.S)
        text = re.sub(r'<svg[^>]*>', '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64" stroke-linecap="round" stroke-linejoin="round">',text,count=1)
        text = text.replace('stroke="#1c1b22"','stroke="#2b2233"')
        # Cada relleno original conserva su color medio. Contornos y huecos quedan planos.
        colors = sorted(set(re.findall(r'fill="(#[0-9a-fA-F]{6})"',text)) - {'#2b2233','#000000'})
        defs = ''
        for i,color in enumerate(colors):
            rgb = [int(color[j:j+2],16) for j in [1,3,5]]
            light = '#' + ''.join(f'{round(v+(255-v)*.17):02x}' for v in rgb)
            dark = '#' + ''.join(f'{round(v*.80):02x}' for v in rgb)
            defs += gradient(f'material{i}',[light,color,dark])
            text = text.replace(f'fill="{color}"',f'fill="url(#material{i})"')
        text = text.replace('>', '>\n<defs>'+defs+'</defs>',1)
        # Sombra de apoyo escalonada, sin filtros, más tenue que el óvalo anterior.
        text = re.sub(r'<ellipse ([^>]*?)fill="#000000" opacity="0.22"\s*/>', lambda m: '<ellipse '+m[1]+'fill="#2b2233" opacity=".13"/>',text)
        text = text.replace('</svg>', extras.get(name,'')+'\n</svg>')
        result = '<!-- '+comment+'; material pulido, vista lateral hacia la derecha; fondo transparente. -->\n'+text.strip()+'\n'
    result = '\n'.join(line.rstrip() for line in result.splitlines()) + '\n'
    (ROOT / f'assets/sprites/map/{name}.svg').write_text(result)
manifest = []
for i,name in enumerate(NAMES):
    old = ART / f'sources/before/{name}.svg'
    new = ROOT / f'assets/sprites/map/{name}.svg'
    manifest.append({'archivo':f'assets/sprites/map/{name}.svg','posicion':i,'fila':i//7+1,'columna':i%7+1,'antes_sha256':hashlib.sha256(old.read_bytes()).hexdigest(),'despues_sha256':hashlib.sha256(new.read_bytes()).hexdigest()})
(ART/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print(f'{len(NAMES)} SVG pulidos; originales y hashes conservados.')
